function [ret,mode]=ASIGetCameraMode(cid)
% Get the current camera (trigger) mode
    pmode=libpointer('int32Ptr',0);
    [ret,mode]=calllib('libASICamera2','ASIGetCameraMode',cid,pmode);
    ret=inst.ASI_ERROR_CODE(ret);
    mode=inst.ASI_CAMERA_MODE(mode);
