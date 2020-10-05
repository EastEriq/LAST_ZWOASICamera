function takeExposure(Z,expTime)
% like startExposure+collectExposure, but the latter is called by a timer, 
%  which collects the image behind the scenes when expTime is past.
% The resulting image goes in QC.LastImage
        if exist('expTime','var')
            Z.ExpTime=expTime;
        end
        
        % last image: empty it when starting, or really keep the last
        % one available till a new is there?
        Z.LastImage=[];
        
        Z.startExposure(Z.ExpTime)
        
        collector=timer('Name','ImageCollector',...
            'ExecutionMode','SingleShot','BusyMode','Queue',...
            'StartDelay',Z.ExpTime,...
            'TimerFcn',@(~,~)collectExposure(Z),...
            'StopFcn',@(mTimer,~)delete(mTimer));
            
        start(collector)
        
end
