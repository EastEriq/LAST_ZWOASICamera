function [ret]=ASISetStartPos(cid,sx,sy)
% set start position of ROI
% Notes:the position is relative to the image after binning. 
% Call this function to change ROI area to the
% origin after ASISetROIFormat, because ASISetROIFormat will change ROI to the center.
    [ret]=calllib('libASICamera2','ASISetStartPos',cid,sx,sy);
    ret=inst.ASI_ERROR_CODE(ret);
    