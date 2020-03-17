function [ret,pin,status,delay,duration]=ASIGetTriggerOutputIOConf(cid,pin)
% automatically generated parsing ASICamera2.h
% Only useful as a template, remove comment when fixed

%Paras:
% int CameraID: this is get from the camera property use the API ASIGetCameraProperty.
% ASI_TRIG_OUTPUT_STATUS pin: Select the pin for getting the configuration
% ASI_BOOL *bPinAHigh: Get the current status of valid level.
% long *lDelay: get the time between the camera receive a trigger signal and the output of the valid level.
% long *lDuration: get the duration time of the valid level output.
    psta=libpointer('int32Ptr',0);
    pdelay=libpointer('longPtr',-1);
    pdur=libpointer('longPtr',-1);
    [ret,status,delay,duration]=...
        calllib('libASICamera2','ASIGetTriggerOutputIOConf',cid,pin,psta,pdelay,pdur);
    ret=inst.ASI_ERROR_CODE(ret);
