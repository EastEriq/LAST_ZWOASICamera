function ret=ASIStartExposure(cid,bIsDark)
% Usage:start a single snap shot. Note that there is a setup time for each 
% snap shot, thus you cannot get two snapshots in succession with a shorter
% time span that these values.
% ASI_BOOL bIsDark: means dark frame if there is mechanical shutter on the
% camera. otherwise useless
    if ~exist('bIsDark','var')
        bIsDark=inst.ASI_BOOL.ASI_FALSE;
    end
    ret=calllib('libASICamera2','ASIStartExposure',cid,int32(bIsDark));
    ret=inst.ASI_ERROR_CODE(ret);
