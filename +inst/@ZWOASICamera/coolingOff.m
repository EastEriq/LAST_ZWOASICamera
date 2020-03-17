function coolingOff(Z)
% Turn cooling off
    ret=ASISetControlValue(Z.camhandle,...
          inst.ASI_CONTROL_TYPE.ASI_COOLER_ON,0);
    Z.setLastError(ret==inst.ASI_ERROR_CODE.ASI_SUCCESS,...
        'could not turn off the cooling')
end