import requests
import cv2

mapName = 'manhattan'
##### block manhattan start #####
# left border, from north to south
city_range = [
    [40.8156, -73.9644, 40.7564, -74.0080],
    [40.7564, -74.0080, 40.703618, -74.019097]]
x_count = [2, 2]
block_size_sets = [[0.012, 0.028], [0.012, 0.023]]
##### block manhattan end #####

# small overlap is enough
overlap = 0.0018
maps = []

def download(flag):
    for index, r in enumerate(city_range):
        block_size = block_size_sets[index]
        tan = (r[3] - r[1]) / abs(r[2] - r[0])
        sign = (r[2] - r[0]) / abs(r[2] - r[0])
        delta_long = tan * (block_size[0] - overlap)
        delta_lati = sign * (block_size[0] - overlap)
        start_long = r[1] + delta_long

        if len(maps) and r[0] > maps[-1][1] + overlap:
            start_lati = maps[-1][1] + overlap
        else:
            start_lati = r[0]

        y_count = int(abs(start_lati - r[2]) / (block_size[0] - overlap)) + 1

        for i in range(y_count):
            long_ = start_long + delta_long * i
            lati_ = start_lati + delta_lati * i
            for j in range(x_count[index]):
                maps.append([long_ + (block_size[1] - overlap) * j, lati_ - block_size[0], long_ + (block_size[1] - overlap) * j + block_size[1], lati_])

    if flag:
        for i, r in enumerate(maps):
            if i < 12:
                continue
            print('downloading map {}...'.format(i))
            file = requests.get("https://www.openstreetmap.org/api/0.6/map?bbox="
                + "{:.4f}".format(r[0]) + "%2C"
                + "{:.4f}".format(r[1]) + "%2C"
                + "{:.4f}".format(r[2]) + "%2C"
                + "{:.4f}".format(r[3]))
            open(mapName + "/osm/map_" + str(i) + ".xml", "wb").write(file.content)

def plot():
    img_range = [-74.0228, 40.6985, -73.9219, 40.8191]
    img = cv2.imread(mapName + '/' + mapName + '.jpg')
    width = img.shape[1]
    height = img.shape[0]
    ratio_w = width / (img_range[2] - img_range[0])
    ratio_h = height / (img_range[3] - img_range[1])
    for r in maps:
        sp = [ratio_w * (r[0] - img_range[0]), ratio_h * (img_range[3] - r[3])]
        ep = [ratio_w * (r[2] - r[0]), ratio_h * (r[3] - r[1])]
        sp[0] = int(sp[0])
        sp[1] = int(sp[1])
        ep[0] = int(ep[0] + sp[0])
        ep[1] = int(ep[1] + sp[1])
        cv2.rectangle(img, (sp[0], sp[1]), (ep[0], ep[1]), (255, 0, 0), 2)

    # write map range list to file
    with open(mapName + '/maps_range_list.txt', 'w') as fp:
        for item in maps:
            fp.write("%f %f %f %f\n" % (item[3], item[2], item[1], item[0]))

    # cv2.namedWindow("output", cv2.WINDOW_NORMAL)
    # cv2.imshow('output', img)
    # cv2.waitKey()
    cv2.imwrite(mapName + '/' + mapName + '_slice.jpg', img)
    return

if __name__=='__main__':
    download(0)
    plot()