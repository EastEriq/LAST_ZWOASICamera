Z=inst.ZWOASICamera

Z.ROI=[-1 -2 Inf Inf]
Z.Binning=3

Z.takeExposure(2);Z.LastError
Z.WaitForIdle(Z.ExpTime);
imagesc(Z.LastImage);axis image; colorbar

tic;imgs=Z.takeExposureSeq(5,.2);toc;Z.LastError
imagesc(imgs{end});axis image; colorbar
