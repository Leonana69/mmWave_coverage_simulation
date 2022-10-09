clear;
close all;

mapName = 'manhattan';
operator = 1; % 1: verizon, 2: att, 3: tmobile
for mapIndex = 0:0
    %% load map
    mapFileName = strcat('maps/', mapName, '/osm/map_', int2str(mapIndex), '.xml');
    viewer = siteviewer("Buildings", mapFileName, "Basemap", "openstreetmap");
    %% read rx locs
    rxLocs = readmatrix(strcat('maps/', mapName, '/rx_loc/map_', int2str(mapIndex), '_mloc.csv'));
    latiRange = rxLocs(1:2, 1);
    longRange = rxLocs(1:2, 2);
    
    rxLati = rxLocs(3:end, 1);
    rxLong = rxLocs(3:end, 2);
    rxCount = length(rxLong);
    
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
    
    %% save the workspace
    folderName = strcat('results/', mapName, '/map_', int2str(mapIndex), '/', opName);
    if ~exist(folderName, 'dir')
       mkdir(folderName)
    end
    save(strcat(folderName, '/workspace'))
end