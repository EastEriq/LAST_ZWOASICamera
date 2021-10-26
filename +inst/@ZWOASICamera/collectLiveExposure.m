function img=collectLiveExposure(Z)
% collect a frame from an ongoing live take, but only if we are in Live Mode, if
%  exposure was started, and time out if waiting for more than X*texp
 
    timeout=Z.ExpTime+0.5; % in secs
    
    roi=Z.ROI;
    w= roi(3)-roi(1)+1;
    h= roi(4)-roi(2)+1;

    switch Z.CamStatus
        case {'exposing','reading'}  % check what is set as status in Live
            ret=ASIGetVideoData(Z.camhandle, Z.pImg,...
                                 w*h*Z.BitDepth/8, timeout*1e6);
            
            if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
                Z.reportError('error in retrieving live image');
                Z.deallocate_image_buffer
                img=[];
                Z.TimeEnd=[];
                Z.reportError('timed out without reading a Live image, aborting Live!');
                % if this function was called back by an image collector timer
                %  (i.e. if acquisition was started by Z.takeLive),
                %  try to stop that timer. We have not assigned it
                %  to a property, hence try to discover it with timerfind
                collector=timerfind('Name',...
                              sprintf('ImageCollector-%d',Z.CameraNum));
                stop(collector)
                % the timer deletes itself with its stop function.
                return
            else
                if Z.Verbose>1
                    fprintf('got image at time %f\n',toc);
                end
                % do we have a better estimate of TimeStart? this one
                %  will be off of the time it takes ASIGetVideoData to run
                Z.TimeStart=now-Z.ExpTime/86400;
                Z.TimeStartLastImage=Z.TimeStart; % so we know when Z.LastImage was started,
                                                    % even if a subsequent
                                                    % exposure is started
                Z.TimeEnd=now;
                img=unpackImgBuffer(Z.pImg,w,h,1,Z.BitDepth);
                if Z.Verbose>1
                    fprintf('t after unpacking: %f\n',toc);
                end
                Z.ProgressiveFrame=Z.ProgressiveFrame+1;
            end        
        otherwise
            Z.TimeEnd=[];
            Z.reportError('no image to read because exposure not started');
            img=[];
    end
    Z.LastImage=img;
    Z.LastImageSaved=false;

end