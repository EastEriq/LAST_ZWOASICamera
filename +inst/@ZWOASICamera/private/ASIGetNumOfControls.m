function [ret,noc]=ASIGetNumOfControls(cid)
% get the number of control types for the specific camera ID
    pnoc=libpointer('int32Ptr',-1);
    [ret,noc]=calllib('libASICamera2','ASIGetNumOfControls',cid,pnoc);
    ret=inst.ASI_ERROR_CODE(ret);
