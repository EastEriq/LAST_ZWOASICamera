Z=inst.ZWOASICamera

Z.ROI=[-1 -2 Inf Inf]
Z.binning=3

Z.takeExposure(2);Z.lastError
Z.WaitForIdle(Z.ExpTime);
imagesc(Z.lastImage);axis image; colorbar

tic;imgs=Z.takeExposureSeq(5,.2);toc;Z.lastError
imagesc(imgs{end});axis image; colorbar