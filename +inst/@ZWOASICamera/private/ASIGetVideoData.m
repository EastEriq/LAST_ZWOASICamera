function [ret,data]=ASIGetVideoData(cid,pdata,bufsize,waitms)
% after ASIStartVideoCapture (), call this function repeatedly to get images on a continuous basis.
% The function resets the capture to the next frame so you cannot get the same frame
% twice if the function is called two times in very short succession.
%  Waitms: timeout wait time, unit is ms, -1 means wait forever
%  suggested waitms value: exposure_time*2 + 500ms
% Notes:
%  If read out speed isn't fast enough, new frame is discarded,
%  it is best to create a circular buffer for
%  holding the imagery to operate on the frames asynchronously.
%
% bufSize Byte length:for RAW8 and Y8,bufSize >= image_width*image_height; for RAW16,
%  bufSize >= image_width*image_height*2; for RGB8,bufSiz >= image_width*image_height*3
    if ~exist('waitms','var')
        waitms=500;
    end
    % the pointer pdata is allocated externally in order to reduce the overhead for
    %  repeated calls
    % pdata=libpointer('uint8Ptr',zeros(1,bufsize,'uint8'));
    
    % maybe we can omit the copy of the output data, just rely on the
    %  buffer to be filled, and keep track only of its pointer
    if nargout<2
        ret=calllib('libASICamera2','ASIGetVideoData',cid,pdata,bufsize,waitms);
    else
        [ret,data]=calllib('libASICamera2','ASIGetVideoData',cid,pdata,bufsize,waitms);
    end
    ret=inst.ASI_ERROR_CODE(ret);
