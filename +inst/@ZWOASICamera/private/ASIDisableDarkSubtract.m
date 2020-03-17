function ret=ASIDisableDarkSubtract(cid)
% disable dark subtraction function
    ret=calllib('libASICamera2','ASIDisableDarkSubtract',cid);
    ret=inst.ASI_ERROR_CODE(ret);
