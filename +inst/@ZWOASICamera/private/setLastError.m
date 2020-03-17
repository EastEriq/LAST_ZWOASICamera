function setLastError(Z,success,msg)
% helper to set QC.lastError empty or message
    if success
        Z.lastError='';
    else
        Z.lastError=msg;
    end
end
