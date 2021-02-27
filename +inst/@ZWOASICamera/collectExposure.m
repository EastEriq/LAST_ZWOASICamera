function img=collectExposure(Z)
% collect the exposed frame, but only if an exposure was started!

    switch Z.CamStatus
        case {'exposing','reading'}
            % make this function blocking: if 'exposing', white
            % indefinitely till status changes to 'reading'. This
            % could be for very long...
            while strcmp(Z.CamStatus,'exposing')
                pause(0.05)
            end
            
            roi=Z.ROI;
            w= roi(3)-roi(1)+1;
            h= roi(4)-roi(2)+1;
            ret=ASIGetDataAfterExp(Z.camhandle,Z.pImg,w*h*Z.BitDepth/8);

            if ret==0
                Z.time_end=now;
                Z.progressive_frame=1;
            else
                Z.time_end=[];
            end

            img=unpackImgBuffer(Z.pImg,w,h,1,Z.BitDepth);

            Z.deallocate_image_buffer

            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                           'could not retrieve exposure from camera');
        otherwise
            Z.LastError='no image to read because exposure not started';
            img=[];
    end
    
    Z.LastImage=img;
    Z.LastImageSaved=false;    
end
