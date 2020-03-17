function [ret,CameraInfo]=ASIGetCameraProperty(num)
    Pinfo=libstruct('s_ASI_CAMERA_INFO',[]);
    [ret,Cinfo]=calllib('libASICamera2','ASIGetCameraProperty',Pinfo,num);
    ret=inst.ASI_ERROR_CODE(ret);
    CameraInfo=format_CameraInfo(Cinfo);