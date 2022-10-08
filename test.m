clear;
close all;
viewer = siteviewer("Buildings", "maps/osm/map_12.xml", "Basemap","openstreetmap");
% 40.7119471,-74.0112671
%%

rxloc = readmatrix('maps\towers\ver.csv');

%%

rxSites = rxsite("Name","User locations", ...
    "Latitude", rxloc(:, 1), ...
    "Longitude", rxloc(:, 2), ...
    "AntennaHeight", 1.5);
clearMap(viewer);
show(rxSites);