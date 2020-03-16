function CameraInfo=format_CameraInfo(Cinfo)
% make the of ASIGetCameraProperty output readable
    CameraInfo=Cinfo;
    CameraInfo.Name=deblank(char(Cinfo.Name));
    
    CameraInfo.IsColorCam=enum_member(Cinfo.IsColorCam,'inst.ASI_BOOL');
    CameraInfo.BayerPattern=enum_member(Cinfo.BayerPattern,'inst.ASI_BAYER_PATTERN');
    
    CameraInfo.SupportedBins=Cinfo.SupportedBins(Cinfo.SupportedBins~=0);
    
    lastvideoformat=find(Cinfo.SupportedVideoFormat==inst.ASI_IMG_TYPE('ASI_IMG_End'))-1;
    CameraInfo.SupportedVideoFormat=...
        inst.ASI_IMG_TYPE(Cinfo.SupportedVideoFormat(1:lastvideoformat));
    
    CameraInfo.MechanicalShutter=enum_member(Cinfo.MechanicalShutter,'inst.ASI_BOOL');
    CameraInfo.ST4Port=enum_member(Cinfo.ST4Port,'inst.ASI_BOOL');
    CameraInfo.IsCoolerCam=enum_member(Cinfo.IsCoolerCam,'inst.ASI_BOOL');
    CameraInfo.IsUSB3Host=enum_member(Cinfo.IsUSB3Host,'inst.ASI_BOOL');
    CameraInfo.IsUSB3Camera=enum_member(Cinfo.IsUSB3Camera,'inst.ASI_BOOL');
    CameraInfo.IsTriggerCam=enum_member(Cinfo.IsTriggerCam,'inst.ASI_BOOL');
