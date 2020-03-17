function [ret]=ASISetCameraMode(cid,mode)
% Set a (trigger) mode into the camera
    ret=calllib('libASICamera2','ASISetCameraMode',cid,int32(mode));
    ret=inst.ASI_ERROR_CODE(ret);
