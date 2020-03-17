function [ret]=ASIStartVideoCapture(cid)
% start the continuous video capture
    [ret]=calllib('libASICamera2','ASIStartVideoCapture',cid);
    ret=inst.ASI_ERROR_CODE(ret);
