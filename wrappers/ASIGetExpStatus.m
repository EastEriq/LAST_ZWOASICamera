function [ret,expstatus]=ASIGetExpStatus(cid)
% automatically generated parsing ASICamera2.h
% Only useful as a template, remove comment when fixed
    ps=libpointer('int32Ptr',0);
    [ret,exps]=calllib('libASICamera2','ASIGetExpStatus',cid,ps);
    ret=inst.ASI_ERROR_CODE(ret);
    expstatus=inst.ASI_EXPOSURE_STATUS(exps);
