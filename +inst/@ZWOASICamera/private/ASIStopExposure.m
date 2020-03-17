function ret=ASIStopExposure(cid)
% Usage:stop a single snap shot, this API can be used for very long
% exposure and you don't want to wait so long such like exposure 5
% minutes and you want to cancel after 1 min, then you can call this API
% Notes:if exposure status is success after stop exposure,image can still
% be read out
    ret=calllib('libASICamera2','ASIStopExposure',cid);
    ret=inst.ASI_ERROR_CODE(ret);
