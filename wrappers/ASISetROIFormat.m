function [ret]=ASISetROIFormat(cid,width,height,binning,type)
% set region of interest (ROI) size, binning, and image type
% Notes: In general make sure width%8=0, height%2=0
% For the USB2.0 camera ASI120, make
%  sure width*height%1024=0 ,otherwise the call will result is an error code.
    [ret]=calllib('libASICamera2','ASISetROIFormat',...
                   cid,width,height,binning,int32(type));
    ret=inst.ASI_ERROR_CODE(ret);
    