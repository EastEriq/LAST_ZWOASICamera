function [ret,value,auto]=ASIGetControlValue(cid,asi_control_type)
% get a specific control type's value as currently set for a specific camera ID
    pvalue=libpointer('longPtr',0);
    pauto=libpointer('int32Ptr',0);
    [ret,value,auto]=calllib('libASICamera2','ASIGetControlValue',...
        cid,int32(asi_control_type),pvalue,pauto);
    ret=inst.ASI_ERROR_CODE(ret);
