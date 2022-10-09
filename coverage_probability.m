clear;
close all;

mapName = 'manhattan';
mapCount = 22;
%% read path loss
opName = ['ver'; 'att'; 'tmb'];

for op = 1:3
    finalPathLoss = [];
    for index = 0 : mapCount - 1
        folderName = strcat('results/', mapName, '/map_', int2str(index), '/', opName(op, :));
        s = load(strcat(folderName, '/idealPathLoss.mat'));
        finalPathLoss = [finalPathLoss; s.idealPathLoss];
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

    switch op
        case 1
            finalPathLoss_ver = uFinalPathLoss;
        case 2
            finalPathLoss_att = uFinalPathLoss;
        case 3
            finalPathLoss_tmb = uFinalPathLoss;
    end
end

maxSNR = 50;
minSNR = -50;

%%
viewer = siteviewer("Basemap","openstreetmap");

%% calculate down-link SNR
txPower = 45;
txRxAntennaG = 16;
rxNoiseFloor = -174 + 10*log10(100e6) + 10; % noise figure: 10
SNR_ver = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_ver(:, 3);
SNR_ver(SNR_ver > maxSNR) = maxSNR;
SNR_ver(SNR_ver < minSNR) = minSNR;
SNR_att = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_att(:, 3);
SNR_att(SNR_att > maxSNR) = maxSNR;
SNR_att(SNR_att < minSNR) = minSNR;
SNR_tmb = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_tmb(:, 3);
SNR_tmb(SNR_tmb > maxSNR) = maxSNR;
SNR_tmb(SNR_tmb < minSNR) = minSNR;
%%
fpl = finalPathLoss_ver;
data_table = table(fpl(:, 1), fpl(:, 2), SNR_ver);
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "LegendTitle", "SNR (dB)", "MarkerSize", 3, "Colormap", "jet");
% contour(pd);

%% calculate up-link SNR
txPower = 15;
txRxAntennaG = 16;
rxNoiseFloor = -174 + 10*log10(100e6) + 8; % noise figure: 8
SNR_ver = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_ver(:, 3);
SNR_ver(SNR_ver > maxSNR) = maxSNR;
SNR_ver(SNR_ver < minSNR) = minSNR;
SNR_att = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_att(:, 3);
SNR_att(SNR_att > maxSNR) = maxSNR;
SNR_att(SNR_att < minSNR) = minSNR;
SNR_tmb = txPower + txRxAntennaG - rxNoiseFloor - finalPathLoss_tmb(:, 3);
SNR_tmb(SNR_tmb > maxSNR) = maxSNR;
SNR_tmb(SNR_tmb < minSNR) = minSNR;
%%
fpl = finalPathLoss_ver;
data_table = table(fpl(:, 1), fpl(:, 2), SNR_ver);
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "LegendTitle", "SNR (dB)", "MarkerSize", 3, "Colormap", "jet");
% contour(pd);

%% path loss
fpl = finalPathLoss_ver;
data_table = table(fpl(:, 1), fpl(:, 2), fpl(:, 3));
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "LegendTitle", "Path Loss (dB)", "MarkerSize", 3, "Colormap", "parula");

%% CDF
x_SNR_t = minSNR:0.1:maxSNR;

y_SNR_cu_ver = sum(SNR_ver > x_SNR_t, 1);
y_SNR_cu_att = sum(SNR_att > x_SNR_t, 1);
y_SNR_cu_tmb = sum(SNR_tmb > x_SNR_t, 1);

y_SNR_cd_ver = sum(SNR_ver + 28 > x_SNR_t, 1);
y_SNR_cd_att = sum(SNR_att + 28 > x_SNR_t, 1);
y_SNR_cd_tmb = sum(SNR_tmb + 28 > x_SNR_t, 1);

figure(1)
hold on
plot(x_SNR_t, y_SNR_cu_ver / length(SNR_ver), 'LineWidth', 2, 'LineStyle', '-');
plot(x_SNR_t, y_SNR_cu_att / length(SNR_att), 'LineWidth', 2, 'LineStyle', '--');
plot(x_SNR_t, y_SNR_cu_tmb / length(SNR_tmb), 'LineWidth', 2, 'LineStyle', ':');
plot(x_SNR_t, y_SNR_cd_ver / length(SNR_ver), 'LineWidth', 2, 'LineStyle', '-');
plot(x_SNR_t, y_SNR_cd_att / length(SNR_att), 'LineWidth', 2, 'LineStyle', '--');
plot(x_SNR_t, y_SNR_cd_tmb / length(SNR_tmb), 'LineWidth', 2, 'LineStyle', ':');
hold off
legend('Verizon UL', 'AT&T UL', 'T-Mobile UL', 'Verizon DL', 'AT&T DL', 'T-Mobile DL');
xlabel("SNR Threshold (dB)");
ylabel("Probability");
xlim([-20, 50]);
ylim([0, 0.9]);