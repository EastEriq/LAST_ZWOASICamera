function abort(Z)
% call both stopping functions, how could we know
% in which acquisition mode we are?

% stopping single image exposure
    ASIStopExposure(Z.camhandle);
% stopping live mode
    ASIStopVideoCapture(Z.camhandle);

    deallocate_image_buffer(Z)
    
end
