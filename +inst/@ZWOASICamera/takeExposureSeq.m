function imgs=takeExposureSeq(Z,num,expTime)
% blocking function, take N images in Live mode;
    imgs={};
    
    if exist('expTime','var')
        Z.ExpTime=expTime;
    end

    Z.lastError='';
    
    ret=ASIStartVideoCapture(Z.camhandle);
    if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
        Z.lastError='could not start live video mode';
        Z.deallocate_image_buffer
        return
    end
            
    Z.allocate_image_buffer
    roi=Z.ROI;
    w= roi(3)-roi(1)+1;
    h= roi(4)-roi(2)+1;

    for i=1:num
                
        ret=ASIGetVideoData(Z.camhandle, Z.pImg,...
                            w*h*Z.bitDepth/8, (2*Z.ExpTime+0.5)*1e6);
        imgs{i}=unpackImgBuffer(Z.pImg,w,h,1,Z.bitDepth);
        
        if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
            Z.lastError='error in retrieving live image';
            Z.deallocate_image_buffer
            return
        end
    end
    
    ret=ASIStopVideoCapture(Z.camhandle);
    Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                           'could not stop live video mode');
    Z.deallocate_image_buffer
end