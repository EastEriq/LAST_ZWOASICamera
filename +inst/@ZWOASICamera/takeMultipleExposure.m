function imgs=takeMultipleExposure(Z,num,expTime)
% blocking function, take N images repeatedly as single exposures;
    imgs={};
    
    if exist('expTime','var')
        Z.ExpTime=expTime;
    end

    % a slightly more efficient writeup would allocate only once the image
    %  buffer before the loop and deallocate it at the end, but here we go
    %  for economy of writing, since this is a placeholder

    for i=1:num
        startExposure(Z,expTime)
        
        if ~isempty(Z.lastError)
            return
        end
        
        imgs{i}=collectExposure(Z);
        
        if ~isempty(Z.lastError)
            return
        end
    end
    
end