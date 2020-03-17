function default_values(Z)
% set some initial default values for properties, differentiating
%  between camera models when needed
    Z.ROI=[0,0,Z.physical_size.nx,Z.physical_size.ny];
    Z.ExpTime=10;
    Z.Gain=0;
    Z.offset=1;
    Z.binning=[1,1];
    Z.Temperature=-20; % check if reachable...
    Z.coolingOn
end