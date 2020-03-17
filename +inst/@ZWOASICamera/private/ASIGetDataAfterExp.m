function [ret,data]=ASIGetDataAfterExp(cid,bufsize)
% get image after snap successfully
    % consider allocating externally the pointer to reduce the overhead for
    %  repeated calls
    pdata=libpointer('uint8Ptr',zeros(1,bufsize,'uint8'));
    [ret,data]=calllib('libASICamera2','ASIGetDataAfterExp',cid,pdata,bufsize);
    ret=inst.ASI_ERROR_CODE(ret);
