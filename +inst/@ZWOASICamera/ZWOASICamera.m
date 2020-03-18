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
    end

    properties(Transient)
        lastImage
    end
        
    properties(Dependent = true)
        ExpTime=10;
        Gain=0;
        offset
        Temperature
        ROI
        binning=[1,1]; % beware - SDK sets both equal
        ReadMode
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

        function set.ROI(Z,roi)
            % ROI width has to be multiple of 8 and height multiple of 2.
            % Notes:the position is relative to the image after binning
            x1=roi(1);
            y1=roi(2);
            sx=roi(3)-roi(1)+1;
            sy=roi(4)-roi(2)+1;
            
            % try to clip unreasonable values
            x1=max(min(x1,Z.physical_size.nx-1),0);
            y1=max(min(y1,Z.physical_size.ny-1),0);
            sx=max(min(sx,Z.physical_size.nx-x1),1);
            sy=max(min(sy,Z.physical_size.ny-y1),1);
            
            if Z.bitDepth==16
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW16; % the only ones we work in
            else
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW8; % the only ones we work in
            end
            ret1=ASISetROIFormat(Z.camhandle,sx,sy,max(Z.binning),imgtype);
             % StartPos is called second
             %  "because ASISetROIFormat will change ROI to the center")
            ret2=ASISetStartPos(Z.camhandle,x1,y1);
            
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could not set ROI')
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

        function roi=get.ROI(Z)
            % Notes:the position is relative to the image after binning
            [ret1,w,h,~,~]=ASIGetROIFormat(Z.camhandle);
            [ret2,x1,y1]=ASIGetStartPos(Z.camhandle);
            roi=[x1,y1,x1+w-1,y1+h-1];
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could not set ROI')
        end
        
        function set.offset(Z,offset)
            ret=ASISetControlValue(Z.camhandle,...
                inst.ASI_CONTROL_TYPE.ASI_OFFSET,offset,false);
            Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                'could not set offset')
        end
        
        function offset=get.offset(Z)
            [ret,offset]=ASIGetControlValue(Z.camhandle,...
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
        
        function set.binning(Z,binning)
            % may be tricky: ROI has to take binning into account
            % also, ASI_CONTROL_TYPE.ASI_HARDWARE_BIN and
            % ASI_CONTROL_TYPE.ASI_MONO_BIN (software) could be in the way.
            roi=Z.ROI;
            sx=roi(3)-roi(1)+1;
            sy=roi(4)-roi(2)+1;
            if Z.bitDepth==16
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW16; % the only ones we work in
            else
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW8; % the only ones we work in
            end
            ret1=ASISetROIFormat(Z.camhandle,sx,sy,max(binning),imgtype);
            ret2=ASISetStartPos(Z.camhandle,roi(1),roi(2));           
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could not set ROI to set binning')
        end
        
        function binning=get.binning(Z)
                 [ret,~,~,bin]=ASIGetROIFormat(Z.camhandle);
                 binning=[bin,bin];
                 Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
                     'could not get offset')
        end
        
        function set.bitDepth(Z,BitDepth)
            % BitDepth: 8 or 16 (bit).
            % Constrain BitDepth to 8|16
            % The function which changes the bit depth in the camera is the one
            %  which sets the ROI
            BitDepth=max(min(round(BitDepth/8)*8,16),8);
            if BitDepth==16
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW16; % the only ones we work in
            else
                imgtype=inst.ASI_IMG_TYPE.ASI_IMG_RAW8; % the only ones we work in
            end
            Z.report('setting ROI to set the new bit depth\n')
            % duplicating some set.ROI code here
            roi=Z.ROI;
            sx=roi(3)-roi(1)+1;
            sy=roi(4)-roi(2)+1;
            ret1=ASISetROIFormat(Z.camhandle,sx,sy,max(Z.binning),imgtype);
            ret2=ASISetStartPos(Z.camhandle,roi(1),roi(2));           
            success= (ret1==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      ret2==inst.ASI_ERROR_CODE.ASI_SUCCESS);
            Z.setLastError(success,'could set ROI to set bit depth')
        end

        function bitDepth=get.bitDepth(Z)
            [ret,~,~,~,imgtype]=ASIGetROIFormat(Z.camhandle);
            switch imgtype
                case inst.ASI_IMG_TYPE.ASI_IMG_RAW16
                    bitDepth=16;
                otherwise
                    bitDepth=8;                    
            end
            success= (ret==inst.ASI_ERROR_CODE.ASI_SUCCESS & ...
                      bitDepth==8 | bitDepth==16);
            Z.setLastError(success,'could not get bit depth')
        end

        function set.color(Z,ColorMode)
            % placeholder, let's allow only false, otherwise setting
            %  it would need a cascade of calls setting ROI etc.
            if ColorMode
                msg='only RAW8 and RAW16 monochrome are implemented for now';
                Z.report([msg '\n'])
                Z.setLastError(~ColorMode,msg)
            end
        end
        
        function ColorMode=get.color(Z)
            ColorMode=false;
        end
        
    end

end