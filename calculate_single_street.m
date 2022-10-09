clear;
close all;

mapName = 'manhattan';
operator = 1; % 1: verizon, 2: att, 3: tmobile
%% load map
mapIndex = 0;
mapFileName = strcat('maps/', mapName, '/osm/map_', int2str(mapIndex), '.xml');
viewer = siteviewer("Buildings", mapFileName, "Basemap", "openstreetmap");
%% read rx locs
rxLati_se = [40.804528, 40.814675];
rxLong_se = [-73.962736, -73.955308];
rxCount = 130;
rxDist = 1.2897e+03;
rxX = rxDist/rxCount : rxDist/rxCount : rxDist;

rxLati = rxLati_se(1):(rxLati_se(2) - rxLati_se(1)) / rxCount : rxLati_se(2);
rxLong = rxLong_se(1):(rxLong_se(2) - rxLong_se(1)) / rxCount : rxLong_se(2);

rxSites = rxsite("Name","User locations", ...
    "Latitude", rxLati, ...
    "Longitude", rxLong, ...
    "AntennaHeight", 1.5);
clearMap(viewer);
show(rxSites);

%% read tx locs
margin = 0.002;

switch operator
    case 1
        opName = "ver";
    case 2
        opName = "att";
    otherwise
        opName = "tmb";
end

txAllLocs = readmatrix(strcat('maps/', mapName, '/towers/', opName, '.csv'));
latiFilter = txAllLocs(:, 1) < latiRange(2) + margin ...
    & txAllLocs(:, 1) > latiRange(1) - margin;
longFilter = txAllLocs(:, 2) < longRange(2) + margin ...
    & txAllLocs(:, 2) > longRange(1) - margin;
txLocs = txAllLocs(latiFilter & longFilter, :);
txLati = txLocs(:, 1);
txLong = txLocs(:, 2);
txCount = length(txLong);

txSites = txsite(...
    "Latitude", txLati, ...
    "Longitude", txLong, ...
    "AntennaHeight", 5, ...
    "TransmitterPower", 45, ...
    "TransmitterFrequency", 28e9);

show(txSites);
%% run raytracing
% the rays depend on tx, rx, map, 
rtpm = propagationModel("raytracing", ...
    "Method", "image", ...
    "MaxNumReflections", 1, ... % one hop
    "BuildingsMaterial","concrete", ...
    "TerrainMaterial","concrete");
rays = raytrace(txSites, rxSites, rtpm);

%%
pathLoss = zeros(1, rxCount);
for rx = 1 : rxCount % for each rx
    pathLoss(rx) = 9e9;
    for tx = 1 : txCount % check all txs
        minDirectDis = 9e9; % 
        minReflectedDis = 9e9;
        tempRay = rays(tx, rx);
        tempRay = tempRay{1};
        % check all links
        if (~isempty(tempRay))
            for p = tempRay
                if p.LineOfSight
                    % shortest LOS path
                    if p.PropagationDistance < minDirectDis
                        minDirectDis = p.PropagationDistance;
                    end
                else
                    % shortest NLOS path
                    if p.PropagationDistance < minReflectedDis
                        minReflectedDis = p.PropagationDistance;
                    end
                end
                
            end
        end
        
        pl1 = -loss_ideal_LOS(minDirectDis);
        pl2 = -loss_ideal_1R(minReflectedDis);
        pl_total = -10 * log10(10^(pl1/10) + 10^(pl2/10));

        if pl_total < pathLoss(rx)
            pathLoss(rx) = pl_total;
        end
    end
end

%%
txPower = 15;
txRxAntennaG = 16;
rxNoiseFloor = -174 + 10*log10(100e6) + 8; % noise figure: 8
SNR_ul = txPower + txRxAntennaG - rxNoiseFloor - pathLoss;
SNR_dl = SNR_ul + 28;
figure(1)
hold on
plot(rxX, SNR_ul, 'LineWidth', 2);
plot(rxX, SNR_dl, 'LineWidth', 2);
hold off
legend('Up-link', 'Down-link')
xlabel("Distance from start point (m)")
ylabel("SNR (dB)")
ylim([-50, 50]);