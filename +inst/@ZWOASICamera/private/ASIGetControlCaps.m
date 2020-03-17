function [ret,capacity]=ASIGetControlCaps(cameraid,controlidx)
% get control type's capacity or range of values for a specific control index
    pcap=libstruct('s_ASI_CONTROL_CAPS',[]);
    [ret,caps]=calllib('libASICamera2','ASIGetControlCaps',cameraid,controlidx,pcap);
    ret=inst.ASI_ERROR_CODE(ret);
    % readable output
    
    capacity=caps;
    capacity.Name=deblank(char(caps.Name));
    capacity.Description=deblank(char(caps.Description));
    capacity.IsAutoSupported=enum_member(caps.IsAutoSupported,'inst.ASI_BOOL');
    capacity.IsWritable=enum_member(caps.IsWritable,'inst.ASI_BOOL');
    capacity.ControlType=enum_member(caps.ControlType,'inst.ASI_CONTROL_TYPE');
    
