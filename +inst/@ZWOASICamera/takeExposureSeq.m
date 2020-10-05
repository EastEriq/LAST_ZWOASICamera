function imgs=takeExposureSeq(Z,num,expTime)
% blocking function, take N images in Live mode;
    imgs={};
    
    if exist('expTime','var')
        Z.ExpTime=expTime;
    end

    Z.LastError='';
    
    t0=now;
    ret=ASIStartVideoCapture(Z.camhandle);
    t1=now;
    Z.TimeStartDelta=t1-t0;
    if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
        Z.LastError='could not start live video mode';
        Z.deallocate_image_buffer
        return
    else
        Z.TimeStart=t0;
    end
            
    Z.allocate_image_buffer
    roi=Z.ROI;
    w= roi(3)-roi(1)+1;
    h= roi(4)-roi(2)+1;

    for i=1:num
                
        ret=ASIGetVideoData(Z.camhandle, Z.pImg,...
                            w*h*Z.BitDepth/8, (Z.ExpTime+0.5)*1e6);
        
        if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
            Z.LastError='error in retrieving live image';
            Z.deallocate_image_buffer
            return
        else
            Z.TimeEnd=now;
            imgs{i}=unpackImgBuffer(Z.pImg,w,h,1,Z.BitDepth);
        end
    end
    
    ret=ASIStopVideoCapture(Z.camhandle);
    Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                           'could not stop live video mode');
    Z.deallocate_image_buffer
    
    [ret,dropped]=ASIGetDroppedFrames(Z.camhandle);
    Z.report(sprintf('%d video frames dropped\n',dropped))
end
