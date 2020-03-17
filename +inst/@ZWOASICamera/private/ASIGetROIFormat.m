function [ret,w,h,bin,type]=ASIGetROIFormat(cid)
% get the region of interest (ROI) values for size, binning, and image type
    pw=libpointer('int32Ptr',0);
    ph=libpointer('int32Ptr',0);
    pbin=libpointer('int32Ptr',0);
    pt=libpointer('int32Ptr',0);
    [ret,w,h,bin,type]=calllib('libASICamera2','ASIGetROIFormat',cid,pw,ph,pbin,pt);
    ret=inst.ASI_ERROR_CODE(ret);
    type=inst.ASI_IMG_TYPE(type);
