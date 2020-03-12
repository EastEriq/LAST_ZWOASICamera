function pids=ASIGetProductIDs()
  % first call with 0 to get length
  len=calllib('libASICamera2','ASIGetProductIDs',libpointer('int32Ptr',0));
  % then allocate a pointer to an array
  ppids=libpointer('int32Ptr',zeros(1,len,'int32'));
  pids=calllib('libASICamera2','ASIGetProductIDs',ppids);