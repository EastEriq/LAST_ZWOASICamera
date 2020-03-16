function [ret,modes]=ASIGetCameraSupportMode(cid)
% Get the camera’s supported trigger modes
    pmodes=libstruct('s_ASI_SUPPORTED_MODE',[]);
    [ret,smodes]=calllib('libASICamera2','ASIGetCameraSupportMode',cid,pmodes);
    ret=inst.ASI_ERROR_CODE(ret);
    lastmode=find(smodes.SupportedCameraMode==inst.ASI_CAMERA_MODE('ASI_MODE_END'))-1;
    modes=inst.ASI_CAMERA_MODE(smodes.SupportedCameraMode(1:lastmode));
