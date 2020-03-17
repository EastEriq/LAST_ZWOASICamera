function [ret,id]=ASIGetID(cid)
% get camera id stored in flash, only available for USB3.0 camera
    pid=libstruct('s_ASI_ID',[]);
    [ret,id]=calllib('libASICamera2','ASIGetID',cid,pid);
    ret=inst.ASI_ERROR_CODE(ret);
    id=deblank(char(id.id));