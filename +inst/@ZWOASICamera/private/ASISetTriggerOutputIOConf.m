function ret=ASISetTriggerOutputIOConf(cid,pin,pinHigh,delay,duration)
% Config the output pin (A or B) of Trigger port. If lDuration <= 0, this output pin will be closed. 
%  Only need to call when the IsTriggerCam in the CameraInfo is true 

% Paras:
%  int CameraID: this is get from the camera property use the API ASIGetCameraProperty.
%  ASI_TRIG_OUTPUT_STATUS pin: Select the pin for output
%  ASI_BOOL bPinHigh: If true, the selected pin will output a high level as a signal
%					when it is effective. Or it will output a low level as a signal.
%  long lDelay: the time between the camera receive a trigger signal and the output 
%			of the valid level.From 0 microsecond to 2000*1000*1000 microsecond.
% long lDuration: the duration time of the valid level output.From 0 microsecond to 
%			2000*1000*1000 microsecond.

    [ret,]=calllib('libASICamera2','ASISetTriggerOutputIOConf',cid,pin,pinHigh,delay,duration);
    ret=inst.ASI_ERROR_CODE(ret);
