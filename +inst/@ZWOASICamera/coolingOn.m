function coolingOn(Z,temp)
% Turn cooling on and set target temperature, if given
% the default target tempetarure, if not given, is -20°C (arbitrarily)
    if ~exist('temp','var')
        temp=-20;
    end
    ret=ASISetControlValue(Z.camhandle,...
          inst.ASI_CONTROL_TYPE.ASI_COOLER_ON,1);
    Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
        'could not turn off the cooling')
    Z.Temperature=temp;
end