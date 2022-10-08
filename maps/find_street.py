from tokenize import Double
import xml.etree.ElementTree as ET
from ctypes import sizeof
from dis import dis
from math import sin, cos, sqrt, atan2, radians
import sys, os, getopt

# USES DATA IN OSM TO POPULATE TEMP.TXT
def get_intersections(osm):
    """
    This method reads the passed osm file (xml) and finds intersections (nodes that are shared by two or more roads)
    :param osm: An osm file or a string from get_osm()
    """
    intersection_coordinates = []
    tree = ET.parse(osm)
    root = tree.getroot()
    children = list(root)

    counter = {}
    for child in children:
        # get the GPS range of the osm file
        if child.tag == 'bounds':
            global min_lat
            global min_long
            global max_lat
            global max_long
            min_lat = child.attrib['minlat']
            min_long = child.attrib['minlon']
            max_lat = child.attrib['maxlat']
            max_long = child.attrib['maxlon']
        
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

    # Find nodes that are shared with more than one way, which might correspond to intersections
    intersections = { k for k, v in counter.items() if v >= 1 }

    # Extract intersection coordinates
    # You can plot the result using this url.
    # http://www.darrinward.com/lat-long/
    nodeIds = []
    for child in children:
        if child.tag == 'node' and child.attrib['id'] in intersections:
            coordinate = [float(child.attrib['lat']), float(child.attrib['lon'])]
            nodeIds.append(child.attrib['id'])
            intersection_coordinates.append(coordinate)
    print(intersection_coordinates)
    return
    #return intersection_coordinates

    # getting the street names 
    # given a list of nodes numbers
    # ['42432068', '42432071', '42432073', '42432075', '42437074', '42437078', '42437082', '42437084', '3670609093']

    # final return: street 1, street 2, lat, long
    # street 1 and street 2 ordered alphabetically

    intersecount = 0
    final = []
    curr = []
    yes = 0
    for node in nodeIds:
        curr = []
        for child in children:
            if child.tag == 'way':
                for item in child:
                    if item.tag == 'nd' and item.attrib['ref'] == str(node):
                        temp = child.attrib['id']
                        yes = 1
                    if yes == 1:
                        if item.tag == 'tag':
                            if item.attrib['k'] == 'name' and child.attrib['id'] == temp: 
                                curr.append(item.attrib['v'])
        curr = list(set(curr))  
        if len(curr) == 2:

            dest = [curr[0], curr[1]]
            dest.sort()
            toadd_dest = dest[0] + ' and ' + dest[1]

            temp = [toadd_dest, intersection_coordinates[intersecount][0],intersection_coordinates[intersecount][1]]
            
            toadd_dest2 = dest[1] + ' and ' + dest[0]
            temp2 = [toadd_dest2, intersection_coordinates[intersecount][0],intersection_coordinates[intersecount][1]]


            intersecount = intersecount + 1
            final.append(temp)
            final.append(temp2)
                         
    final.sort()

    #print results to temp.txt
    with open("temp.txt", "w") as external_file:
        for i in final: 
            add_text = str(i[0]) + ',' + str(i[1]) + ',' + str(i[2])
            print(add_text, file=external_file)
        external_file.close()
    
    with open('temp.txt', 'r') as f:
        lines = f.readlines()
    f.close()

    with open("temp.txt", "w") as external_file:
        prev_first = lines[0].split()[0]
        prev_second = lines[0].split()[1]
        curr_first = lines[1].split()[0]
        curr_second = lines[1].split()[1]
        if (curr_first == prev_first and curr_second == prev_second):
            add_text= lines[0]
            print(add_text, end = '', file=external_file)

        j = 1

        while j in range(1,len(lines)-2):
            prev_first = lines[j-1].split()[0]
            prev_second = lines[j-1].split()[1]

            curr_first = lines[j].split()[0]
            curr_second = lines[j].split()[1]

            next_first = lines[j+1].split()[0]
            next_second = lines[j+1].split()[1]

            if ((curr_first == prev_first and curr_second == prev_second) or (curr_first == next_first and curr_second == next_second)):
                add_text= lines[j]
                print(add_text, end = '', file=external_file)


            j = j +1
        
        next_first = lines[j+1].split()[0]
        next_second = lines[j+1].split()[1]
        curr_first = lines[j].split()[0]
        curr_second = lines[j].split()[1]
        if (curr_first == next_first and curr_second == next_second):
            add_text= lines[j-1]
            print(add_text, end = '', file=external_file)
    external_file.close()


def final():

    # create OSM FILE
    # THIS PROGRAM PRINTS WHAT SHOULD GO IN MATLAB FILE ie rxRange = lineNbr = ...
    # DATA.TXT IN MATLAB SHOULD BE UPDATED WITH THE CONTENTS OF ALLDATA.TXT

    # MAKE SURE NO UNIQUE FIRST WORDS

    with open('temp.txt', 'r') as f:
        lines = f.readlines()
    f.close()

    curr_first = lines[0].split()[0]
    curr_second = lines[0].split()[1]

    m = len(lines)
    i = 0

    open("alldata.txt", "w").close() #clears alldata.txt first
    alldata = open("alldata.txt", "a")
    while i < m:
        unsorted = []
        ## get the bundle of streets/ ave
        while lines[i].split()[0] == curr_first and lines[i].split()[1] == curr_second:
            data=[e.strip() for e in lines[i].split(',')]
            i = i + 1

            new_unsorted_element = (float(data[1]), float(data[2]))
            unsorted.append(new_unsorted_element)

            if i >= m:
                break

        #sort by lat or long
        a1 = min(unsorted)[0]
        a2 = max(unsorted)[0]
        b1 = min(unsorted, key = lambda t: t[1])[1]
        b2 = max(unsorted, key = lambda t: t[1])[1]

        fsorted = []
        if abs(a1-a2) > abs(b1-b2):
            fsorted = sorted(unsorted)
        else:
            fsorted = sorted(unsorted, key=lambda a:a[1])
        
        rxRange = []
        for j in range(len(fsorted) - 1):
            toadd = [fsorted[j][0], fsorted[j][1], fsorted[j+1][0], fsorted[j+1][1]]
            rxRange.append(toadd)
            toaddinfile = str(toadd[0]) + "\t" + str(toadd[1]) + "\t" + str(toadd[2]) + "\t" + str(toadd[3])
            alldata.write(toaddinfile + "\n")
        
        if i >= m:
            alldata.close()
            break
        curr_first = lines[i + 1].split()[0]
        curr_second = lines[i + 1].split()[1]

    count = 0
    dist = []
    numpoints = []
    with open('alldata.txt', 'r') as f2:
        lines = f2.readlines()
        lineNbr = len(lines)
    for i in lines:

        data=[e.strip() for e in i.split('\t')]

        lat1, lon1, lat2, lon2 = radians(float(data[0])), radians(float(data[1])), radians(float(data[2])), radians(float(data[3]))
        # approximate radius of earth in km
        R = 6373.0

        dlon = lon2 - lon1
        dlat = lat2 - lat1

        a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))

        distance = int(round(R * c * 1000))
        points = int(round(distance / 10))

        dist.append(distance)
        numpoints.append(points)

        count = count + 1

    print("lineNbr = ", lineNbr, ";")
    print("rxNbr = ", numpoints, ";")
    print("rxSpanDis = ", dist, ";")

    f2.close()

def part1():
    f = open('part1.txt', 'r')
    file_contents = f.read()
    print (file_contents)
    f.close()

def part2():
    f = open('part2.txt', 'r')
    file_contents = f.read()
    print (file_contents)
    f.close()

def part3():
    f = open('part3.txt', 'r')
    file_contents = f.read()
    print (file_contents)
    f.close()

# Script that compiles and executes a .cpp file
# Usage:
# python run_cpp.py -i <filename> (without .cpp extension)

def main(argv):
    get_intersections('new_haven.osm')
    # part1()
    # final()
    # part2()
    # cpp_file = ''
    # exe_file = ''
    # try:
    #     opts, args = getopt.getopt(argv, "hi:",["help",'ifile='])
    # except getopt.GetoptError as err:
    #     # print help information and exit
    #     print("error", err)      
    #     usage()
    #     sys.exit(2)
    # for o, a in opts:
    #     if o in ("-h", "--help"):
    #         usage()
    #         sys.exit()
    #     elif o in ("-i", "--ifile"):
    #         cpp_file = a + '.cpp'
    #         exe_file = a + '.exe'
    #         run(cpp_file, exe_file)
    # part3()

def usage():
    print('run_cpp.py -i <filename> (without .cpp extension)')

def run(cpp_file, exe_file):
    os.system('g++ -o range2 range2.cpp')
    global min_lat
    global min_long
    global max_lat
    global max_long
    to_run = './range2' + ' ' + str(min_lat) + ' ' + str(min_long) + ' ' + str(max_lat) + ' ' + str(max_long)
    os.system(to_run)

if __name__=='__main__':
    main(sys.argv[1:])