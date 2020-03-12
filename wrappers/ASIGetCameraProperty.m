function [ret,Cinfo]=ASIGetCameraProperty(num)
    Pinfo=libstruct('s_ASI_CAMERA_INFO',[]);
    [ret,Cinfo]=calllib('libASICamera2','ASIGetCameraProperty',Pinfo,num);