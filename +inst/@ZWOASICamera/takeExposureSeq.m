function imgs=takeExposureSeq(Z,num,expTime)
% blocking function, take N images repeatedly as single exposures;
    imgs=cell(1,num);
    
    if exist('expTime','var')
        Z.ExpTime=expTime;
    end

    % a slightly more efficient writeup would allocate only once the image
    %  buffer before the loop and deallocate it at the end, but here we go
    %  for economy of writing, since this is a placeholder

    Z.ProgressiveFrame=0;
    Z.SequenceLength=num;
    for i=1:num
        startExposure(Z,expTime)
        
        if ~isempty(Z.LastError)
            return
        end
        
        imgs{i}=collectExposure(Z);
        
        if ~isempty(Z.LastError)
            return
        end
    end
    
end
