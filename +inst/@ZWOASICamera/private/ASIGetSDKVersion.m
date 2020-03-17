function version=ASIGetSDKVersion()
% get version string of SDK
    version=calllib('libASICamera2','ASIGetSDKVersion');
