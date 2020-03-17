function success=disconnect(Z)
    % Close the connection with the camera registered in the
    %  current camera object

    % don't try co lose an invalid camhandle, it would crash matlab
    if ~isempty(Z.camhandle)
        % check this status, which may fail
        success=(ASICloseCamera(Z.camhandle)==inst.ASI_ERROR_CODE.ASI_SUCCESS);
    else
        success=true;
    end
    % null the handle so that other methods can't talk anymore to it
    Z.camhandle=[];
    
    Z.setLastError(success,'could not disconnect camera')

end
