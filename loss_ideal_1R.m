function [loss] = loss_ideal_NLOS(distance)
%% loss_ideal_LOS Summary of this function goes here
% this function use 3GPP UMi Street Canyon model
%   distance: distance of link (m)
%   n: path loss exponents
%   fc: central frequency (Hz)
%   sf: shadow fading (dB)
%   rl: reflection loss (dB)
%   loss: path loss in dB
    n = 2.1;
    fc = 28e9;
    vc = 3e8;
    sf = 4;
    rl = 5.0;
    loss = 10*n*log10(distance) + 20*log10(4*pi*fc/vc) + rl;
end
