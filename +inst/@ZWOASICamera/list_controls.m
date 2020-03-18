function list_controls(Z)
    % list al the supported control capabilities; debug; may be removed later on
    [~,noc]=ASIGetNumOfControls(Z.camhandle);
    for i=0:noc-1
        [~,cap]=ASIGetControlCaps(Z.camhandle,i);
        [~,value,auto]=ASIGetControlValue(Z.camhandle,cap.ControlType);
        if cap.IsAutoSupported==inst.ASI_BOOL.ASI_FALSE
            autosup='NoAuto';
        else
            autosup='<Auto>';
        end
        if cap.IsWritable==inst.ASI_BOOL.ASI_FALSE
            rw='RO';
        else
            rw='RW';
        end
        if auto==inst.ASI_BOOL.ASI_FALSE
            au='Set ';
        else
            au='Auto';
        end
        fprintf('\n%#2d. %-24s %-27s %s, %s\n    "%s"\n    = %d %s = ([%d:%d], default %d)\n',...
            i, cap.Name, cap.ControlType, autosup, rw, cap.Description,...
            value, au, cap.MinValue, cap.MaxValue, cap.DefaultValue);
    end
end
