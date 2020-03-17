classdef ZWOASICamera < handle

    properties
        cameranum
        % read/write properties, settings of the camera, for which
        %  hardware query is involved.
        %  We use getters/setters, even though instantiation
        %   order is not guaranteed. In particular, all parameters
        %   of the camera require that camhandle is obtained first.
        %  Values set here as default won't likely be passed to the camera
        %   when the object is created
        binning=[1,1]; % beware - SDK sets both equal
    end

    properties(Transient)
        lastImage
    end
        
    properties(Dependent = true)
        ExpTime=10;
        Gain=0;
        Temperature
        ROI
        ReadMode
        offset
    end
    
    properties(GetAccess = public, SetAccess = private)
        CameraName
        CamStatus='unknown';
        CoolingStatus
        time_start=[];
        time_end=[];
   end
    
    % Enrico, discretional
    properties(GetAccess = public, SetAccess = private, Hidden)
        physical_size=struct('chipw',[],'chiph',[],'pixelw',[],'pixelh',[],...
                             'nx',[],'ny',[]);
        effective_area=struct('x1Eff',[],'y1Eff',[],'sxEff',[],'syEff',[]);
        overscan_area=struct('x1Over',[],'y1Over',[],'sxOver',[],'syOver',[]);
        readModesList=struct('name',[],'resx',[],'resy',[]);
        lastExpTime=NaN;
        progressive_frame = 0; % image of a sequence already available
        time_start_delta % uncertainty, after-before calling exposure start
    end
    
    % settings which have not been prescribed by the API,
    % but for which I have already made the code
    properties(Hidden)
        color
        bitDepth
    end
    
    properties (Hidden,Transient)
        camhandle   % handle to the camera talked to - no need for the external
                    % consumer to know it
        lastError='';
        verbose=true;
        pImg  % pointer to the image buffer (can we gain anything in going
              %  to a double buffer model?)
              % Shall we allocate it only once on open(QC), or, like now,
              %  every time we start an acquisition?
    end

    methods

       % Constructor
       function Z=ZWOASICamera(cameranum)
           if libisloaded('libASICamera2')
               unloadlibrary('libASICamera2')
           end
           classpath=fileparts(mfilename('fullpath'));
           loadlibrary(fullfile(classpath,'lib/libASICamera2.so'),...
               fullfile(classpath,'lib/ASICamera2.h'))

            % the constructor tries also to open the camera
            if exist('cameranum','var')
                connect(Z,cameranum);
            else
                connect(Z);
            end
       end

       % destructor
       function delete(Z)
            % it shouldn't harm to try to stop the acquisition for good,
            %  even if already stopped - and delete the image pointer QC.pImg
            %abort(Z)
            
            % make sure we close the communication, if not done already
            success=disconnect(Z);
            Z.setLastError(success,'could not close camera')
            if success
                Z.report('Succesfully closed camera\n')
            else
                Z.report('Failed to close camera\n')
            end

           try
               % unloading prevents crashes on exiting matlab
               unloadlibrary('libASICamera2')
           catch
               % unloading ought to fail silently if there are extant objects
               %  depending on the library, which should happen only if
               %  other ZWOCamera objects still exist.
               % Modulo that unload fails for some other weird reason...
           end
       end

    end
    
    methods %getters and setters
        
        function status=get.CamStatus(Z)
            % rely on GetExpStatus to start with
            [ret,ASIstatus]=ASIGetExpStatus(Z.camhandle);
            switch ASIstatus
                case inst.ASI_EXPOSURE_STATUS.ASI_EXP_IDLE
                    status='idle';
                case inst.ASI_EXPOSURE_STATUS.ASI_EXP_WORKING
                    status='exposing';
                case inst.ASI_EXPOSURE_STATUS.ASI_EXP_SUCCESS
                    status='reading';
                case inst.ASI_EXPOSURE_STATUS.ASI_EXP_FAILED
                    status='unknown';
            end
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,'could not read status')
        end
        
        function set.Temperature(Z,Temp)
            % set the target sensor temperature in Celsius
            ret=ASISetControlValue(Z.camhandle,...
                  inst.ASI_CONTROL_TYPE.ASI_TARGET_TEMP,Temp);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not set temperature')
        end
        
        function Temp=get.Temperature(Z)
            % get the actual temperature
            [ret,Temp]=ASIGetControlValue(Z.camhandle,...
                       inst.ASI_CONTROL_TYPE.ASI_TEMPERATURE);
            Temp=Temp/10; % apparently; confirm it.
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not read temperature')
        end

        function status=get.CoolingStatus(Z)
            % Get the current cooling status, by checking the current PWM
            %  applied to the cooler.
            % Could also read the control ASI_COOLER_ON. The two have
            %  different meaning. Cooling may be turned on, but the current
            %  pwm may be zero because the target temperature has been reached
            [ret,pwm]=ASIGetControlValue(Z.camhandle,...
                       inst.ASI_CONTROL_TYPE.ASI_COOLER_POWER_PERC);
            if pwm==0
                status='off';
            elseif pwm<=100
                status='on';
            elseif ret~=inst.ASI_ERROR_CODE.ASI_SUCCESS
                status='unknown';
            end
        end
        
        function set.ExpTime(Z,ExpTime)
            % ExpTime in seconds
            ret=ASISetControlValue(Z.camhandle,...
                  inst.ASI_CONTROL_TYPE.ASI_EXPOSURE,ExpTime*1e6,false);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not set exposure time')
        end
        
        function ExpTime=get.ExpTime(Z)
            % ExpTime in seconds
            [ret,ExpTime]=ASIGetControlValue(Z.camhandle,...
                       inst.ASI_CONTROL_TYPE.ASI_EXPOSURE);
            ExpTime=double(ExpTime)/1e6; % us->s
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not get exposure time')
        end

        function set.Gain(Z,Gain)
            ret=ASISetControlValue(Z.camhandle,...
                  inst.ASI_CONTROL_TYPE.ASI_GAIN,Gain,false);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not set gain')
        end
        
        function Gain=get.Gain(Z)
            [ret,Gain]=ASIGetControlValue(Z.camhandle,...
                       inst.ASI_CONTROL_TYPE.ASI_GAIN);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not get gain')
        end

    end
    
    methods
        
        function listcontrols(Z)
            % list al the supported control capabilities; debug; may be removed later on
            [~,noc]=ASIGetNumOfControls(Z.camhandle);
            for i=0:noc-1
                [~,cap]=ASIGetControlCaps(Z.camhandle,i)
            end
        end
        
    end

end