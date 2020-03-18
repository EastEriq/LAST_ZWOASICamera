function [ret,data]=ASIGetDataAfterExp(cid,pdata,bufsize)
% get image after snap successfully
    % allocating externally the pointer to reduce the overhead for
    %  repeated calls
    % pdata=libpointer('uint8Ptr',zeros(1,bufsize,'uint8'));
    % maybe we can omit the copy of the output data, just rely on the
    %  buffer to be filled, and keep track only of its pointer
    if nargout<2
        ret=calllib('libASICamera2','ASIGetDataAfterExp',cid,pdata,bufsize);
    else
        [ret,data]=calllib('libASICamera2','ASIGetDataAfterExp',cid,pdata,bufsize);
    end
    ret=inst.ASI_ERROR_CODE(ret);
