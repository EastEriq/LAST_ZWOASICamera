function [ret,expstatus]=ASIGetExpStatus(cid)
% get snap status
% Notes:after snap is started,the status should be checked continuously
    ps=libpointer('int32Ptr',0);
    [ret,exps]=calllib('libASICamera2','ASIGetExpStatus',cid,ps);
    ret=inst.ASI_ERROR_CODE(ret);
    expstatus=inst.ASI_EXPOSURE_STATUS(exps);
