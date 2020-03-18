function img=collectExposure(Z)
% collect the exposed frame, but only if an exposure was started!

    switch Z.CamStatus
        case {'exposing','reading'}
            % collect the image even if exposure not terminated?
            
            roi=Z.ROI;
            w= roi(3)-roi(1)+1;
            h= roi(4)-roi(2)+1;
            ret=ASIGetDataAfterExp(Z.camhandle,Z.pImg,w*h*Z.bitDepth/8);

            if ret==0
                Z.time_end=now;
                Z.progressive_frame=1;
            else
                Z.time_end=[];
            end

            roi=Z.ROI;
            img=unpackImgBuffer(Z.pImg,w,h,1,Z.bitDepth);

            Z.deallocate_image_buffer

            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,'could retrieve exposure from camera');
        otherwise
            Z.lastError='no image to read because exposure not started';
            img=[];
    end
    
    Z.lastImage=img;

end
