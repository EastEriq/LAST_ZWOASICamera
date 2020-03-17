function ret=ASIPulseGuideOn(cid,direction)
% send ST4 guiding pulse, start guiding, only the camera with ST4 port support
    ret=calllib('libASICamera2','ASIPulseGuideOn',cid,int32(direction));
    ret=inst.ASI_ERROR_CODE(ret);
