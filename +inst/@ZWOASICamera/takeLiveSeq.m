function imgs=takeLiveSeq(Z,num,expTime)
% blocking function, take N images in Live mode;
    if nargout>0
        imgs=cell(1,num);
    end
    if exist('expTime','var')
        Z.ExpTime=expTime;
    end

    Z.LastError='';
    
    Z.startLive;

    Z.SequenceLength=num;

    for i=1:num
        if nargout>0
        imgs{i}=collectLiveExposure(Z);
        else
            collectLiveExposure(Z);
        end
    end
    
    ret=ASIStopVideoCapture(Z.camhandle);
    Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                           'could not stop live video mode');
    Z.deallocate_image_buffer
    
    [ret,dropped]=ASIGetDroppedFrames(Z.camhandle);
    Z.report('%d video frames dropped\n',dropped)
end
