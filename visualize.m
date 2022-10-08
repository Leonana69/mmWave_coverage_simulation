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
finalPathLoss = [];
mapCount = 2;

for index = 0 : mapCount - 1
    folderName = strcat('results/', mapName, '/map_', int2str(index), '/', opName);
    s = load(strcat(folderName, '/finalPathLoss.mat'));
    finalPathLoss = [finalPathLoss; s.finalPathLoss];
end

locs = finalPathLoss(:, 1:2);
[u_locs, index, J] = unique(locs, 'rows');
uFinalPathLoss = finalPathLoss(index, :);

for cnt = 1:length(uFinalPathLoss)
    subLoc = uFinalPathLoss(cnt, 1:2);
    sameValueId = locs(:, 1) == subLoc(1) & locs(:, 2) == subLoc(2);
    subSet = finalPathLoss(sameValueId, :);
    value = max(subSet(:, 3));
    uFinalPathLoss(cnt, 3) = value;
end

%% calculate SNR
txPower = 28;
txRxAntennaG = 16;
rxNoiseFloor = -174 + 10*log10(100e6) + 10; % noise figure: 10
SNR = txPower + txRxAntennaG - rxNoiseFloor - uFinalPathLoss(:, 3);

%%
viewer = siteviewer("Basemap","openstreetmap");

%%
data_table = table(uFinalPathLoss(:, 1), uFinalPathLoss(:, 2), SNR);
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "Colormap", parula);