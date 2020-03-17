function success=connect(Z,cameranum)
    % Open the connection with a specific camera, and
    %  read from it some basic information like color capability,
    %  physical dimensions, etc.
    %  cameranum: int, number of the camera to open (as enumerated by the SDK)
    %     May be omitted. In that case the last camera is referred to

    Z.lastError='';
    
    num=ASIGetNumOfConnectedCameras;
    Z.report(sprintf('%d ZWO cameras found\n',num));

    if ~exist('cameranum','var')
        Z.cameranum=num; % and thus open the last camera
                         % (TODO, if possible, the first not
                         %  already open)
    else
        Z.cameranum=cameranum;
    end
    [ret,Cinfo]=ASIGetCameraProperty(max(min(Z.cameranum,num)-1,0));

    if ret
        Z.lastError='could not even get one camera id';
        return;
    end
    
    Z.CameraName=Cinfo.Name;
    Z.camhandle=Cinfo.CameraID;
    
    ret=ASIOpenCamera(Z.camhandle);
    if ret
        Z.lastError='could not even get one camera id';
        return;
    else
        Z.report(sprintf('Opened camera "%s"\n',Z.CameraName));
    end

    ASIInitCamera(Z.camhandle);

    % query the camera and populate the QC structures with some
    %  characteristic values

    [ret1,Z.physical_size.chipw,Z.physical_size.chiph,...
        Z.physical_size.nx,Z.physical_size.ny,...
        Z.physical_size.pixelw,Z.physical_size.pixelh,...
                 bp_supported]=GetQHYCCDChipInfo(Z.camhandle);

    [ret2,Z.effective_area.x1Eff,Z.effective_area.y1Eff,...
        Z.effective_area.sxEff,Z.effective_area.syEff]=...
                 GetQHYCCDEffectiveArea(Z.camhandle);

    % warning: this returns strange numbers, which at some point
    %  I've also seen to change (maybe depending on other calls'
    %  order?)
    [ret3,Z.overscan_area.x1Over,Z.overscan_area.y1Over,...
        Z.overscan_area.sxOver,Z.overscan_area.syOver]=...
                      GetQHYCCDOverScanArea(Z.camhandle);

    ret4=IsQHYCCDControlAvailable(Z.camhandle, inst.qhyccdControl.CAM_COLOR);
    colorAvailable=(ret4>0 & ret4<5);

    Z.report(sprintf('%.3fx%.3fmm chip, %dx%d %.2fx%.2fµm pixels, %dbp\n',...
        Z.physical_size.chipw,Z.physical_size.chiph,...
        Z.physical_size.nx,Z.physical_size.ny,...
        Z.physical_size.pixelw,Z.physical_size.pixelh,...
        bp_supported))
    Z.report(sprintf(' effective chip area: (%d,%d)+(%dx%d)\n',...
        Z.effective_area.x1Eff,Z.effective_area.y1Eff,...
        Z.effective_area.sxEff,Z.effective_area.syEff));
    Z.report(sprintf(' overscan area: (%d,%d)+(%dx%d)\n',...
        Z.overscan_area.x1Over,Z.overscan_area.y1Over,...
        Z.overscan_area.sxOver,Z.overscan_area.syOver));
    if colorAvailable, Z.report(' Color camera\n'); end

    [ret5,Nmodes]=GetQHYCCDNumberOfReadModes(Z.camhandle);
    if Z.verbose, Z.report('Read modes:\n'); end
    for mode=1:Nmodes
        [~,Z.readModesList(mode).name]=...
            GetQHYCCDReadModeName(Z.camhandle,mode-1);
        [~,Z.readModesList(mode).resx,Z.readModesList(mode).resy]=...
            GetQHYCCDReadModeResolution(Z.camhandle,mode-1);
        Z.report(sprintf('(%d) %s: %dx%d\n',mode-1,Z.readModesList(mode).name,...
            Z.readModesList(mode).resx,Z.readModesList(mode).resy));
    end

    success = (ret1==0 & ret2==0 & ret3==0);
    
    % TODO perhaps improve granularity of this report
    Z.setLastError(success,'something went wrong when initializing the camera');

    % put here also some plausible parameter settings which are
    %  not likely to be changed

    Z.offset=0;
    colormode=false; % (local variable because no getter)
    Z.color=colormode;

    % USBtraffic value is said to affect glow. 30 is the value
    %   normally found in demos, it may need to be changed, also
    %   depending on USB2/3
    % The SDK manual says:
    %  Used to set camera traffic,the bandwidth setting is only valid
    %  for continuous mode, and the larger the bandwidth setting, the
    %  lower the frame rate, which can reduce the load of the
    %  computer.
    SetQHYCCDParam(Z.camhandle,inst.qhyccdControl.CONTROL_USBTRAFFIC,3);

    % from https://www.qhyccd.com/bbs/index.php?topic=6861
    %  this is said to affect speed, and accepting 0,1,2
    % The SDK manual says:
    %  USB transfer speed,but part of cameras not support
    %  this function.
    SetQHYCCDParam(Z.camhandle,inst.qhyccdControl.CONTROL_SPEED,2);

    % set full area as ROI (?) -- wishful
    if colormode
        Z.ROI=[0,0,Z.physical_size.nx,Z.physical_size.ny];
    else
        % this is problematic in color mode
        SetQHYCCDParam(Z.camhandle,inst.qhyccdControl.CAM_IGNOREOVERSCAN_INTERFACE,1);
        Z.ROI=[Z.effective_area.x1Eff,Z.effective_area.y1Eff,...
                Z.effective_area.x1Eff+Z.effective_area.sxEff,...
                Z.effective_area.y1Eff+Z.effective_area.syEff];
    end
    
    % set default values, perhaps differentiating camera models
    Z.default_values

    Z.CamStatus='idle'; % whishful, if we got till here.
    
end
