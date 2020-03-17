function [ret]=ASIOpenCamera(cid)
% Usage:open camera of a specific camera ID. This will not affect any other camera which is capturing.
% This should be the first call to start up a camera.
    [ret]=calllib('libASICamera2','ASIOpenCamera',cid);
    ret=inst.ASI_ERROR_CODE(ret);
