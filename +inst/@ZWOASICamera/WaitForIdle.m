function WaitForIdle(Z,timeout)
% supposed to be a blocking function, for at most timeout seconds
% Note that we wait for 'idle' strictly. If the ZWO camera started
%  a single exposure, it will stop at 'reading' till the image is read out.
    if ~exist('timeout','var')
        timeout=1;
    end

    t1=now;
    t2=t1;
    while ((t2-t1)*24*3600)<timeout && ~strcmp(Z.CamStatus,'idle')
        pause(0.1)
        t2=now;
    end

    Z.setLastError((t2-t1)*24*3600<timeout,'time out waiting for camera idle status')
end