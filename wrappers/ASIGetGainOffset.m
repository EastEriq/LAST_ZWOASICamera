function [ret,]=ASIGetGainOffset()
% automatically generated parsing ASICamera2.h
% Only useful as a template, remove comment when fixed
    [ret,]=calllib('libASICamera2','ASIGetGainOffset',);
    ret=inst.ASI_ERROR_CODE(ret);
