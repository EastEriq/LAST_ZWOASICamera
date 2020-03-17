addpath wrappers %% worked only till it was moved to +inst/@ZWOASICamera/private
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

ASISetControlValue(Cinfo.CameraID,inst.ASI_CONTROL_TYPE.ASI_EXPOSURE,1e6,false)
ret=ASIStartExposure(Cinfo.CameraID)
[ret,expstatus]=ASIGetExpStatus(Cinfo.CameraID)
ASIStopExposure(Cinfo.CameraID)

[ret,data]=ASIGetDataAfterExp(Cinfo.CameraID,9576*6388);

ASIStartVideoCapture(Cinfo.CameraID)
pause(1)
[ret,data]=ASIGetVideoData(Cinfo.CameraID,9576*6388); ret
ASIStopVideoCapture(Cinfo.CameraID)

[ret,dropped]=ASIGetDroppedFrames(Cinfo.CameraID)

imagesc(reshape(data,9576,6388))

[ret,id]=ASIGetID(Cinfo.CameraID)



[ret]=ASICloseCamera(Cinfo.CameraID)

