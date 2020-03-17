function [ret,CameraInfo]=ASIGetCameraPropertyByID(cid)
% get the properties of the connected camera by ID, i.e. the number CameraInfo.CameraID
%  retrieved by ASIGetCameraProperty()
    Pinfo=libstruct('s_ASI_CAMERA_INFO',[]);
    [ret,Cinfo]=calllib('libASICamera2','ASIGetCameraPropertyByID',cid,Pinfo);
    ret=inst.ASI_ERROR_CODE(ret);
    CameraInfo=format_CameraInfo(Cinfo);
