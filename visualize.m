clear;
close all;

mapName = 'manhattan';

%% read path loss
operator = 1; % 1: verizon, 2: att, 3: tmobile
switch operator
    case 1
        opName = "ver";
    case 2
        opName = "att";
    otherwise
        opName = "tmb";
end
allPathLoss = [];
mapCount = 2;

for index = 0 : mapCount - 1
    folderName = strcat('results/', mapName, '/map_', int2str(index), '/', opName);
    s = load(strcat(folderName, '/finalPathLoss.mat'));
    allPathLoss = [allPathLoss; s.finalPathLoss];
end
%% calculate SNR
txPower = 28;
txRxAntennaG = 16;
rxNoiseFloor = -174 + 10*log10(100e6) + 10; % noise figure: 10
SNR = txPower + txRxAntennaG - rxNoiseFloor - allPathLoss(:, 3);

%%
viewer = siteviewer("Basemap","openstreetmap");

%%
data_table = table(allPathLoss(:, 1), allPathLoss(:, 2), SNR);
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "Colormap", parula);