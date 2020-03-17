function ret=ASISendSoftTrigger(cid,bStart)
% Send a trigger signal for software simulation. When the bStart is ASI_TRUE,
% the camera will start exposing. For edge trigger, there is no need to send
% ASI_FALSE, and the software will reset itself when the exposure time is over.
% For level trigger, it needs ASI_FALSE to stop the exposure.
    ret=calllib('libASICamera2','ASISendSoftTrigger',cid,bStart);
    ret=inst.ASI_ERROR_CODE(ret);
