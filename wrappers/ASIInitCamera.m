function [ret]=ASIInitCamera(cid)
% initialize the specified camera ID, this API only affect the camera you are going to initialize
% and won't affect other cameras. This should be the second call to start up a camera.
    ret=calllib('libASICamera2','ASIInitCamera',cid);
    ret=inst.ASI_ERROR_CODE(ret);
