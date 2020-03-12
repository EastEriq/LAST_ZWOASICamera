function [ret]=ASISetControlValue(cid,asi_control_type,value,auto)
% set a specific control type's value for a specific camera ID
% Notes: when setting to auto adjust(auto=true),the value should be the current value
    if ~exist('auto','var')
        auto=false;
    end
    [ret]=calllib('libASICamera2','ASISetControlValue',...
                  cid,int32(asi_control_type),value,auto);
    ret=inst.ASI_ERROR_CODE(ret);
