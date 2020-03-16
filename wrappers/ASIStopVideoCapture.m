function [ret]=ASIStopVideoCapture(cid)
% stop the continuous video capture
    [ret]=calllib('libASICamera2','ASIStopVideoCapture',cid);
    ret=inst.ASI_ERROR_CODE(ret);
