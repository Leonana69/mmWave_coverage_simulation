function [loss] = loss_measure_NLOS(distance)
%% loss_ideal_LOS Summary of this function goes here
%   distance: distance of link (m)
%   b: path loss line intercept
%   sf: shadow fading (dB)
%   loss: path loss in dB
    n = 3.4;
    b = 41.9;
    sf = 3.6;
    loss = 10*n*log10(distance) + b;
end
