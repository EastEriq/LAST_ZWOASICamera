function [ret,SN]=ASIGetSerialNumber(cid)
% Get a serial number from a camera. 
% It is 8 ASCII characters, you need to print it in hexadecimal.
%  ASI_SN* pSN: pointer to SN

% return:
%  ASI_SUCCESS : Operation is successful
%  ASI_ERROR_CAMERA_CLOSED : camera didn't open
%  ASI_ERROR_GENERAL_ERROR : camera does not have Serial Number
    pSN=libstruct('s_ASI_ID',[]);
    [ret,SN]=calllib('libASICamera2','ASIGetSerialNumber',cid,pSN);
    ret=inst.ASI_ERROR_CODE(ret);
    SN=sprintf('%02X',SN.id);