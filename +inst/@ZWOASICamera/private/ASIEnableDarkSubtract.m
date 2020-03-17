function ret=ASIEnableDarkSubtract(cid,path)
% enable dark subtraction function
%  Path: path of dark field image(.bmp)
    ret=calllib('libASICamera2','ASIEnableDarkSubtract',cid,path);
    ret=inst.ASI_ERROR_CODE(ret);
