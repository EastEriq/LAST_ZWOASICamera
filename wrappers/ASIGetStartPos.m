function [ret,sx,sy]=ASIGetStartPos(cid)
% get the region of interest (ROI) values for size, binning, and image type
    px=libpointer('int32Ptr',0);
    py=libpointer('int32Ptr',0);
    [ret,sx,sy]=calllib('libASICamera2','ASIGetStartPos',cid,px,py);
    ret=inst.ASI_ERROR_CODE(ret);
