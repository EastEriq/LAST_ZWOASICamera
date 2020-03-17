function [ret,dropped]=ASIGetDroppedFrames(cid)
% get dropped frames' count during video capture
    pdropped=libpointer('int32Ptr',0);
    [ret,dropped]=calllib('libASICamera2','ASIGetDroppedFrames',cid,pdropped);
    ret=inst.ASI_ERROR_CODE(ret);
