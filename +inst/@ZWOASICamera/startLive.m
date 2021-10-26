function startLive(Z)
% start live mode exposure (allocating the image buffer)
    t0=now;
    ret=ASIStartVideoCapture(Z.camhandle);
    t1=now;
    Z.TimeStartDelta=t1-t0;
    if ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
        Z.reportError('could not start live video mode');
        Z.deallocate_image_buffer
        return
    else
        Z.TimeStart=t0;
    end
            
    Z.allocate_image_buffer

    Z.ProgressiveFrame=0;
 