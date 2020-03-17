function [ret,sx,sy]=ASIGetStartPos(cid)
% get start position of ROI. The position is relative to the image after binning.
    px=libpointer('int32Ptr',0);
    py=libpointer('int32Ptr',0);
    [ret,sx,sy]=calllib('libASICamera2','ASIGetStartPos',cid,px,py);
    ret=inst.ASI_ERROR_CODE(ret);
