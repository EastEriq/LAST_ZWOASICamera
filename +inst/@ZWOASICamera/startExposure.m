function startExposure(Z,expTime)
% set up the scenes for taking a single exposure

    switch Z.CamStatus
        % Do we start a new exposure even if an old image is available
        %  but hasn't been read? Shall we try exposing for 'unknown' too?
        case {'idle','reading','unknown'} 
            if exist('expTime','var')
                Z.ExpTime=expTime;
            end

            Z.ProgressiveFrame=0;
            Z.SequenceLength=1;

            Z.allocate_image_buffer

            t0=now;
            ret=ASIStartExposure(Z.camhandle);
            t1=now;
            
            Z.TimeStartDelta=t1-t0;
            
            success=ret==inst.ASI_ERROR_CODE.ASI_SUCCESS;

            Z.setLastError(success,'could not start single exposure');

            if success
                Z.TimeStart=t0;
                Z.lastExpTime=Z.ExpTime;
            else
                Z.TimeStart=NaN;
                Z.lastExpTime=NaN;
                Z.deallocate_image_buffer
            end
        otherwise
            Z.deallocate_image_buffer
            Z.LastError='camera not ready to start a new exposure';
    end

end
