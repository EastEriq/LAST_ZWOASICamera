function [ret,Offset_HighestDR,Offset_UnityGain,...
              Gain_LowestRN,Offset_LowestRN]=ASIGetGainOffset(cid)
% get pre-setting parameters
% Offset_HighestDR: offset at highest dynamic range, 
% Offset_UnityGain: offset at unity gain
% Gain_LowestRN, Offset_LowestRN: gain and offset at lowest read noise
    pOhDR=libpointer('int32Ptr',0);
    pOug=libpointer('int32Ptr',0);
    pGlRN=libpointer('int32Ptr',0);
    pOlRN=libpointer('int32Ptr',0);
    [ret,Offset_HighestDR,Offset_UnityGain,Gain_LowestRN,Offset_LowestRN]=...
         calllib('libASICamera2','ASIGetGainOffset',cid,pOhDR,pOug,pGlRN,pOlRN);
    ret=inst.ASI_ERROR_CODE(ret);
