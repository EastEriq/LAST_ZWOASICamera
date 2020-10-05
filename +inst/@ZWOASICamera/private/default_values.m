function default_values(Z)
% set some initial default values for properties, differentiating
%  between camera models when needed
    Z.Color=false;
    Z.ROI=[0,0,Z.physical_size.nx,Z.physical_size.ny];
    Z.Binning=[1,1];
    Z.BitDepth=16;
    Z.ExpTime=10;
    Z.Gain=0;
    Z.Offset=1;
    Z.Temperature=-15; % seen reachable with ~20°C ambient
    Z.coolingOn
end
