function [ret]=ASICloseCamera(cid)
% close a specific camera ID so that its resources will be released. 
% This should be the last call to shut down a camera
    [ret]=calllib('libASICamera2','ASICloseCamera',cid);
    ret=inst.ASI_ERROR_CODE(ret);
