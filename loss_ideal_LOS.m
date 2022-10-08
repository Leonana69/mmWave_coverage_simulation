function [loss] = loss_ideal_LOS(distance)
%% loss_ideal_LOS Summary of this function goes here
% this function use 3GPP UMi Street Canyon model
%   distance: distance of link (m)
%   n: path loss exponents
%   fc: central frequency (Hz)
%   sf: shadow fading (dB)
%   loss: path loss in dB
    n = 2.1;
    fc = 28e9;
    vc = 3e8;
    sf = 4;
    loss = 10*n*log10(distance) + 20*log10(4*pi*fc/vc);
end

