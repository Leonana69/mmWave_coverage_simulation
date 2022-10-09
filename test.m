clear;
close all;

viewer = siteviewer("Buildings", "maps/manhattan/osm/map_0.xml", "Basemap", "openstreetmap");
mapName = 'manhattan';
mapIndex = 0;

%%
rxLocs = readmatrix(strcat('maps/', mapName, '/rx_loc/map_', int2str(mapIndex), '_mloc.csv'));

rxLati = rxLocs(3:end, 1);
rxLong = rxLocs(3:end, 2);
rxCount = length(rxLong);

rxSites = rxsite("Name","User locations", ...
    "Latitude", rxLati, ...
    "Longitude", rxLong, ...
    "AntennaHeight", 1.5);
clearMap(viewer);
show(rxSites);
%%
txLocs = readmatrix(strcat('maps/', mapName, '/towers/', 'ver', '.csv'));
txLati = txLocs(:, 1);
txLong = txLocs(:, 2);
txCount = length(txLati);

data_table = table(txLati, txLong, zeros(txCount));
data_table.Properties.VariableNames = {'latitude', 'longitude', 'ss' };
pd = propagationData(data_table);
clearMap(viewer)
plot(pd, "LegendTitle", "Path Loss (dB)", "MarkerSize", 6, "Colors", [0.9, 0.3, 0.3]);

%%
a = finalPathLoss_high(:, 3);
b = finalPathLoss(:, 3);
plot(a-b)