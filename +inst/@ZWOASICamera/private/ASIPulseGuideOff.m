function ret=ASIPulseGuideOff(cid,direction)
% send ST4 guiding pulse,stop guiding,only the camera with ST4 port support
    ret=calllib('libASICamera2','ASIPulseGuideOff',cid,int32(direction));
    ret=inst.ASI_ERROR_CODE(ret);
