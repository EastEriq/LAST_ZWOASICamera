addpath wrappers
Z=inst.ZWOASICamera
num=ASIGetNumOfConnectedCameras
[ret,Cinfo]=ASIGetCameraProperty(num-1)
[ret]=ASIOpenCamera(Cinfo.CameraID)
[ret]=ASIInitCamera(Cinfo.CameraID)
[ret,noc]=ASIGetNumOfControls(Cinfo.CameraID)
for i=1:noc
    [ret,cap]=ASIGetControlCaps(Cinfo.CameraID,i-1)
    [ret,value,auto]=ASIGetControlValue(Cinfo.CameraID,cap.ControlType)
end
[ret]=ASICloseCamera(Cinfo.CameraID)
