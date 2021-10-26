function success=connect(Z,CameraNum)
    % Open the connection with a specific camera, and
    %  read from it some basic information like color capability,
    %  physical dimensions, etc.
    %  CameraNum: int, number of the camera to open (as enumerated by the SDK)
    %     May be omitted. In that case the last camera is referred to
    
    % TODO, matlab crashes if connect() is called on an already connected
    %  camera

    Z.LastError='';
    
    num=ASIGetNumOfConnectedCameras;
    switch num
        case 0
            Z.report('No ZWO camera found\n');
        case 1
            Z.report('One ZWO camera found\n');
        otherwise
            Z.report('%d ZWO cameras found\n',num);
    end

    if ~exist('CameraNum','var')
        Z.CameraNum=num; % and thus open the last camera
                         % (TODO, if possible, the first not
                         %  already open)
    else
        Z.CameraNum=max(min(CameraNum,num),1);
    end
    [ret1,Cinfo]=ASIGetCameraProperty(Z.CameraNum-1);

    if ret1
        Z.reportError('could not even get one camera id');
        return;
    end
    
    Z.camhandle=Cinfo.CameraID;
    
    ret2=ASIOpenCamera(Z.camhandle);
    [~,SN]=ASIGetSerialNumber(Z.camhandle);
    Z.CameraName=[Cinfo.Name ' ' SN];
    if ret2
        Z.reportError('could not open the camera');
        return;
    else
        Z.report('Opened camera "%s"\n',Z.CameraName)
    end
    
    
    ASIInitCamera(Z.camhandle);

    % query the camera and populate the Z structures with some
    %  characteristic values. ZWO's SDK doesn't give all the information,
    %  some we assume.
    Z.physical_size.chipw=Cinfo.PixelSize*Cinfo.MaxWidth/1000;
    Z.physical_size.chiph=Cinfo.PixelSize*Cinfo.MaxHeight/1000;
    Z.physical_size.nx=Cinfo.MaxWidth;
    Z.physical_size.ny=Cinfo.MaxHeight;
    Z.physical_size.pixelw=Cinfo.PixelSize;
    Z.physical_size.pixelh=Cinfo.PixelSize;
  
    % no info on those, assume same as physical
    Z.effective_area.x1Eff=1;
    Z.effective_area.y1Eff=1;
    Z.effective_area.sxEff=Z.physical_size.nx;
    Z.effective_area.syEff=Z.physical_size.ny;
 
    % no info on those as well
    Z.overscan_area.x1Over=[];
    Z.overscan_area.y1Over=[];
    Z.overscan_area.sxOver=[];
    Z.overscan_area.syOver=[];
    
    colorAvailable=Cinfo.IsColorCam==inst.ASI_BOOL.ASI_TRUE;

    Z.report('%.3fx%.3fmm chip, %dx%d %.2fx%.2fµm pixels, %dbp\n',...
        Z.physical_size.chipw,Z.physical_size.chiph,...
        Z.physical_size.nx,Z.physical_size.ny,...
        Z.physical_size.pixelw,Z.physical_size.pixelh,...
        Cinfo.BitDepth)
    Z.report(' effective chip area: (%d,%d)+(%dx%d)\n',...
        Z.effective_area.x1Eff,Z.effective_area.y1Eff,...
        Z.effective_area.sxEff,Z.effective_area.syEff);
    Z.report(' overscan area: (%d,%d)+(%dx%d)\n',...
        Z.overscan_area.x1Over,Z.overscan_area.y1Over,...
        Z.overscan_area.sxOver,Z.overscan_area.syOver);
    if colorAvailable
        Z.report(' Color camera\n');
    end

    if Z.Verbose
        Z.report('No specific info on read modes:\n');
    end
    Z.readModesList(1).name='normal';
    Z.readModesList(1).resx=Z.physical_size.nx;
    Z.readModesList(1).resy=Z.physical_size.ny;
    Z.report('(%d) %s: %dx%d\n',0,Z.readModesList(1).name,...
             Z.readModesList(1).resx,Z.readModesList(1).resy);

    success = (ret1==0 & ret2==0);
    
    % TODO perhaps improve granularity of this report
    Z.setLastError(success,'something went wrong when initializing the camera');
    
    % set default values. Upon reconnecting the camera reverts to its defaults
    %  anyway, not to what was previously set
    Z.default_values

    
end
