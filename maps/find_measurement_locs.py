from tokenize import Double
import xml.etree.ElementTree as ET
from ctypes import sizeof
from dis import dis
from math import sin, cos, sqrt, atan2, radians
import sys, os, getopt

if 0:
    mapName = 'manhattan'
    mapCount = 22
else:
    mapName = 'jersey'
    mapCount = 15

margin = 0.0008

def is_in_range(loc):
    x = loc[0]
    y = loc[1]

    if x >= min_lati + margin and x <= max_lati - margin and y >= min_long + margin and y <= max_long - margin:
        return True

    # print(x, y)
    return False

# USES DATA IN OSM TO POPULATE TEMP.TXT
def get_measurement_locs(file_name):
    """
    This method reads the passed osm file (xml) and finds intersections (nodes that are shared by two or more roads)
    :param osm: An osm file or a string from get_osm()
    """
    intersection_coordinates = []
    fileName = mapName + '/osm/' + file_name + '.xml'
    print('=> parse ' + fileName)
    tree = ET.parse(fileName)
    root = tree.getroot()
    children = list(root)

    counter = {}
    for child in children:
        # get the GPS range of the osm file
        if child.tag == 'bounds':
            global min_lati
            global min_long
            global max_lati
            global max_long
            min_lati = float(child.attrib['minlat'])
            min_long = float(child.attrib['minlon'])
            max_lati = float(child.attrib['maxlat'])
            max_long = float(child.attrib['maxlon'])
        
        if child.tag == 'way':
            # Check if the way represents a "highway (road)"
            road = False
            road_types = {'primary', 'secondary', 'residential', 'tertiary', 'service', 'unclassified', 'primary_link', 'secondary_link', 'tertiary_link', 'service'}
            for item in child:
                if item.tag == 'tag' and item.attrib['k'] == 'highway' and item.attrib['v'] in road_types: 
                    road = True

            if not road:
                continue

            for item in child:
                if item.tag == 'nd':
                    nd_ref = item.attrib['ref']
                    if not nd_ref in counter:
                        counter[nd_ref] = 0
                    counter[nd_ref] += 1

    road_nodes = { k for k, v in counter.items() if v >= 1 }

    # Extract intersection coordinates
    # You can plot the result using this url.
    # http://www.darrinward.com/lat-long/
    nodeIds = []
    for child in children:
        if child.tag == 'node' and child.attrib['id'] in road_nodes:
            coordinate = [float(child.attrib['lat']), float(child.attrib['lon'])]
            nodeIds.append(child.attrib['id'])
            if is_in_range(coordinate):
                intersection_coordinates.append(coordinate)
            counter[child.attrib['id']] = coordinate

    # counter: node_id -> [longitude, latitude]
    for child in children:
        if child.tag == 'way':
            # Check if the way represents a "highway (road)"
            road = False
            road_types = {'primary', 'secondary', 'residential', 'tertiary', 'service', 'unclassified', 'primary_link', 'secondary_link', 'tertiary_link', 'service'}
            for item in child:
                if item.tag == 'tag' and item.attrib['k'] == 'highway' and item.attrib['v'] in road_types: 
                    road = True

            if not road:
                continue

            node_list = []
            for item in child:
                if item.tag == 'nd':
                    nd_ref = item.attrib['ref']
                    node_list.append(nd_ref)

            loc_list = [counter.get(k) for k in node_list]
            loc_list.sort(key=compare)

            for i in range(len(loc_list) - 1):
                loc1 = loc_list[i]
                loc2 = loc_list[i + 1]
                # insert node for every 2e-4 GPS distance
                if dis(loc1, loc2) > 2e-4:
                    split_num = int(dis(loc1, loc2) / 2e-4)
                    inc_lati = (loc2[0] - loc1[0]) / split_num
                    inc_long = (loc2[1] - loc1[1]) / split_num
                    for j in range(split_num):
                        coordinate = [loc1[0] + (j + 1) * inc_lati, loc1[1] + (j + 1) * inc_long]
                        if is_in_range(coordinate):
                            intersection_coordinates.append(coordinate)

    with open(mapName + '/rx_loc/' + file_name + '_mloc.csv', 'w') as f:
        rp_1 = str(min_lati) + ',' + str(min_long)
        rp_2 = str(max_lati) + ',' + str(max_long)
        print(rp_1, file = f)
        print(rp_2, file = f)
        for i in intersection_coordinates:
            add_text = str(i[0]) + ',' + str(i[1])
            print(add_text, file = f)

def compare(e):
    return abs(e[0]) + abs(e[1])

def dis(a, b):
    return sqrt((a[0] - b[0])**2 + (a[1] - b[1])**2)

def main():
    for i in range(mapCount):
        get_measurement_locs('map_' + str(i))

if __name__=='__main__':
    main()