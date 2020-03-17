function ret=ASISetID(cid,ID)
% write camera id to flash, only available for USB3.0 camera
% ID is a character array of length up to 8
    pid=libstruct('s_ASI_ID',[]);
    ID=ID(1:min(8,length(ID)));
    ID=pad(ID,8,'right',char(0));
    pid.id=uint8(ID);
    ret=calllib('libASICamera2','ASISetID',cid,pid);
    ret=inst.ASI_ERROR_CODE(ret);
