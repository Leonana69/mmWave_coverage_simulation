function [loss] = loss_measure_LOS(distance)
%% loss_ideal_LOS Summary of this function goes here
%   distance: distance of link (m)
%   b: path loss line intercept
%   sf: shadow fading (dB)
%   loss: path loss in dB
    n = 3.1;
    b = 42.4;
    sf = 4.5;
    loss = 10*n*log10(distance) + b;
end

