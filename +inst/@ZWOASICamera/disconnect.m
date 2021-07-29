function success=disconnect(Z)
    % Close the connection with the camera registered in the
    %  current camera object

    % don't try to close an invalid camhandle (would it really crash matlab?)
    if ~isempty(Z.camhandle) && Z.camhandle>0
        % check this status, which may fail
        success=(ASICloseCamera(Z.camhandle)==inst.ASI_ERROR_CODE.ASI_SUCCESS);
    else
        success=true;
    end
    % invalid the handle so that other methods can't talk anymore to it
    %  and report error
    Z.camhandle=-1;
    
    Z.setLastError(success,'could not disconnect camera')

end
