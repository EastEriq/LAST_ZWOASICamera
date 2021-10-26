function setLastError(Z,success,msg)
% helper to set QC.LastError empty or message
    if success
        Z.LastError='';
    else
        Z.reportError(msg);
    end
end
