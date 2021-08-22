classdef ZWOASICamera < obs.LAST_Handle

    properties
        CameraNum
        % read/write properties, settings of the camera, for which
        %  hardware query is involved.
        %  We use getters/setters, even though instantiation
        %   order is not guaranteed. In particular, all parameters
        %   of the camera require that camhandle is obtained first.
        %  Values set here as default won't likely be passed to the camera
        %   when the object is created
    end

    properties(Transient, SetObservable)
        LastImage
    end
        
    properties(Dependent = true)
        ExpTime
        Gain
        Offset
        Temperature
        ROI
        Binning=[1,1]; % beware - SDK sets both equal
        ReadMode
    end
    
    properties(GetAccess = public, SetAccess = private)
        CameraName
        CamStatus='unknown';
        CoolingStatus
        CoolingPower
        TimeStart=[];
        TimeEnd=[];
        TimeStartLastImage % copy of TimeStart when LastImage is filled, valid until LastImage is not overwritten
   end
    
    % Enrico, discretional
    properties(GetAccess = public, SetAccess = private, Hidden)
        isConnected
        physical_size=struct('chipw',[],'chiph',[],'pixelw',[],'pixelh',[],...
                             'nx',[],'ny',[]);
        effective_area=struct('x1Eff',[],'y1Eff',[],'sxEff',[],'syEff',[]);
        overscan_area=struct('x1Over',[],'y1Over',[],'sxOver',[],'syOver',[]);
        readModesList=struct('name',[],'resx',[],'resy',[]);
        lastExpTime=NaN;
        ProgressiveFrame double % progressive frame number when a sequence of exposures is requested
        SequenceLength double % total number of frames requested for the sequence
        TimeStartDelta % uncertainty, after-before calling exposure start
    end
    
    % settings which have not been prescribed by the API,
    % but for which I have already made the code
    properties(Hidden,Dependent)
        Color
        BitDepth
    end
    
    properties (Hidden,Transient)
        camhandle   % handle to the camera talked to - no need for the external
                    % consumer to know it
        pImg  % pointer to the image buffer (can we gain anything in going
              %  to a double buffer model?)
              % Shall we allocate it only once on open(QC), or, like now,
              %  every time we start an acquisition?
        LastImageSaved=false; % set true by the abstractor when saving the image, reset to false at new exposure
    end

    methods

       % Constructor
       function Z=ZWOASICamera(CameraNum)
           % Class instantiator.
           % Load the library if not already loaded. Only during the
           %  initial development it was helpful to unload it first, to
           %  experiment with header file modifications.
           % Unloading while other ZWO cameras are connected would
           %  crash matlab right away.
           if ~libisloaded('libASICamera2')
               classpath=fileparts(mfilename('fullpath'));
               loadlibrary(fullfile(classpath,'lib/libASICamera2.so'),...
                   fullfile(classpath,'lib/ASICamera2.h'))
           end

            % the constructor tries also to open the camera
            if exist('CameraNum','var')
                connect(Z,CameraNum);
            else
                connect(Z);
            end
       end

       % destructor
       function delete(Z)
           % it shouldn't harm to try to stop the acquisition for good,
           %  even if already stopped - and delete the image pointer QC.pImg
           if ~isempty(Z.camhandle) && Z.camhandle~=-1
               abort(Z)
           end
           
           % make sure we close the communication, if not done already
           success=disconnect(Z);
           Z.setLastError(success,'could not close camera')
           if success
               Z.report('Succesfully closed camera\n')
           else
               Z.report('Failed to close camera\n')
           end
           
           % Don't try to unload the library. If there are other camera
           %  objects using it, matlab just crashes. Unlikely other SDK,
           %  for which unload gives a catchable error, here we would just
           %  pull the rug from under the feet
           try
               % unloadlibrary('libASICamera2')
           catch
               % unloading ought to fail silently if there are extant objects
               %  depending on the library, which should happen only if
               %  other ZWOCamera objects still exist -- but it doesn't
           end
       end

    end
    
    methods %getters and setters
        
        function online=get.isConnected(Z)
            % a way to check if the camera is really still there. If
            %  connection broke, all other getters still report the last
            %  known value, and no error. Such is the SDK.
            % I got the trick from
            % https://bbs.astronomy-imaging-camera.com/viewtopic.php?f=29&t=8231&p=18353#p18353
            ASIGetNumOfConnectedCameras;
            online=(ASIGetNumOfControls(Z.camhandle)==inst.ASI_ERROR_CODE.ASI_SUCCESS);
        end
        
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
            Temp=double(Temp)/10; % apparently; confirm it.
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
        
        function CoolingPower=get.CoolingPower(Z)
            % Get the current cooling power percentage
            [ret,CoolingPower]=ASIGetControlValue(Z.camhandle,...
                       inst.ASI_CONTROL_TYPE.ASI_COOLER_POWER_PERC);
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

        function set.ROI(Z,ROI)
            % ROI width has to be multiple of 8 and height multiple of 2.
            % Notes:the position is relative to the image after binning
            Z.setROIbinDepth(ROI,Z.Binning,Z.BitDepth)
        end

        function ROI=get.ROI(Z)
            % Notes:the position is relative to the image after binning
            [ret1,w,h,~,~]=ASIGetROIFormat(Z.camhandle);
            [ret2,x1,y1]=ASIGetStartPos(Z.camhandle);
            ROI=[x1,y1,x1+w-1,y1+h-1];
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could not set ROI')
        end
        
        function set.Offset(Z,Offset)
            ret=ASISetControlValue(Z.camhandle,...
                inst.ASI_CONTROL_TYPE.ASI_OFFSET,Offset,false);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not set offset')
        end
        
        function Offset=get.Offset(Z)
            [ret,Offset]=ASIGetControlValue(Z.camhandle,...
                inst.ASI_CONTROL_TYPE.ASI_OFFSET);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not get offset')
        end
        
        function set.ReadMode(Z,readMode)
            % this SDK doesn't seem to implement  read modes, ignore
        end
        
        function currentReadMode=get.ReadMode(Z)
            % this SDK doesn't seem to implement  read modes, just return 0
            currentReadMode=0;
        end
        
        function set.Binning(Z,Binning)
            % binning can be a scalar or an array of two elements [binx,biny]
            %  The function however sets binx=biny=max(binx,biny), as this
            %  is the only possibility supported by the SDK.
            % Note that ROI coordinates refer to the binned raster. It is
            %  not possible to set a high binning before reducing the ROI
            %  such that size*binning<sensor_size.
            % 
            % Also, ASI_CONTROL_TYPE.ASI_HARDWARE_BIN and
            % ASI_CONTROL_TYPE.ASI_MONO_BIN (software) could be in the way.
            Z.setROIbinDepth(Z.ROI,Binning,Z.BitDepth)
        end
        
        function Binning=get.Binning(Z)
                 [ret,~,~,bin]=ASIGetROIFormat(Z.camhandle);
                 Binning=[bin,bin];
                 Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                     'could not get offset')
        end
        
        function set.BitDepth(Z,BitDepth)
            % BitDepth: 8 or 16 (bit).
            % Constrain BitDepth to 8|16
            % The function which changes the bit depth in the camera is the one
            %  which sets the ROI
            BitDepth=max(min(round(BitDepth/8)*8,16),8);
            Z.report('setting ROI to set the new bit depth\n')
            Z.setROIbinDepth(Z.ROI,Z.Binning,BitDepth)
        end

        function BitDepth=get.BitDepth(Z)
            [ret,~,~,~,imgtype]=ASIGetROIFormat(Z.camhandle);
            switch imgtype
                case inst.ASI_IMG_TYPE.ASI_IMG_RAW16
                    BitDepth=16;
                otherwise
                    BitDepth=8;                    
            end
            success= (ret==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      BitDepth==8 | BitDepth==16);
            Z.setLastError(success,'could not get bit depth')
        end

        function set.Color(Z,ColorMode)
            % placeholder, let's allow only false, otherwise setting
            %  it would need a cascade of calls setting ROI etc.
            if ColorMode
                msg='only RAW8 and RAW16 monochrome are implemented for now';
                Z.report([msg '\n'])
                Z.setLastError(~ColorMode,msg)
            end
        end
        
        function ColorMode=get.Color(Z)
            ColorMode=false;
        end
        
    end
    
    methods(Access=private)
        
        function setROIbinDepth(Z,ROI,Binning,BitDepth)
            x1=double(ROi(1)); % force double for /binning calculations
            y1=double(ROI(2));
            sx=double(ROI(3)-ROI(1)+1);
            sy=double(ROI(4)-ROI(2)+1);
            b=double(Binning(1));
            
            % try to clip unreasonable values
            x1=max(min(x1,Z.physical_size.nx-1),0);
            y1=max(min(y1,Z.physical_size.ny-1),0);
            sx=max(floor(min(sx,(Z.physical_size.nx-1-x1)/b)/8)*8,8);
            sy=max(floor(min(sy,(Z.physical_size.ny-1-y1)/b)/2)*2,2);
            
            if BitDepth==16
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW16; % the only ones we work in
            else
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW8; % the only ones we work in
            end
            ret1=ASISetROIFormat(Z.camhandle,sx,sy,max(Binning),imgtype);
             % StartPos is called second
             %  "because ASISetROIFormat will change ROI to the center")
            ret2=ASISetStartPos(Z.camhandle,x1,y1);
            
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could not set ROI or Binning')
            if success
                Z.report(sprintf('ROI successfully set to (%d,%d)+(%dx%d)\n',...
                          x1,y1,sx,sy));
            else
                Z.report(sprintf('set ROI to (%d,%d)+(%dx%d) FAILED\n',x1,y1,sx,sy));
                if mod(sx,8)
                    Z.report('ROI width must me a multiple of 8\n')
                end
                if mod(sy,2)
                    Z.report('ROI height must me a multiple of 2\n')
                end
            end
            
        end
        
    end

end
