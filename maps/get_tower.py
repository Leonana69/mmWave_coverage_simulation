# get towers
# https://api.cellmapper.net/v6/getTowers?MCC=311&MNC=480&RAT=LTE&boundsNELatitude=40.71389802220986&boundsNELongitude=-73.99982322285601&boundsSWLatitude=40.69683630486037&boundsSWLongitude=-74.03031766968316&filterFrequency=false&showOnlyMine=false&showUnverifiedOnly=false&showENDCOnly=false
import urllib.request
import json
import csv
import time

mapName = 'manhattan'

map_ranges = []
op = 3
global mcc
global mnc
global file_prefix

def get_tower_raw():
	url_format = 'https://api.cellmapper.net/v6/getTowers?MCC={mcc}&MNC={mnc}&RAT=LTE&boundsNELatitude={lati_max}&boundsNELongitude={long_max}&boundsSWLatitude={lati_min}&boundsSWLongitude={long_min}&filterFrequency=false&showOnlyMine=false&showUnverifiedOnly=false&showENDCOnly=false'
	cnt = 0

	start_index = int(input('Start from: '))
	for index, r in enumerate(map_ranges):
		if index < start_index:
			continue
		ix = input('Enter to start...')
		
		url = url_format.format(mcc = mcc, mnc = mnc, lati_max = r[0], long_max = r[1], lati_min = r[2], long_min = r[3])
		contents = urllib.request.urlopen(url).read()
		with open(mapName + '/towers/' + file_prefix + '-' + str(index) + '-raw-{}-{}-{}-{}.txt'.format(r[0], r[1], r[2], r[3]), 'wb') as f:
			f.write(contents)
		print('write to => towers/' + file_prefix + '-raw-{}-{}-{}-{}.txt'.format(r[0], r[1], r[2], r[3]))

def parsr_tower_location():
	locs = []
	for index, r in enumerate(map_ranges):
		with open(mapName + '/towers/' + file_prefix + '-' + str(index) + '-raw-{}-{}-{}-{}.txt'.format(r[0], r[1], r[2], r[3]), 'rb') as f:
			contents = f.read()

		respond_dict = json.loads(contents.decode('utf-8'))
		data = respond_dict.get("responseData")

		for item in data:
			latitude = item.get("latitude")
			longitude = item.get("longitude")
			locs.append([latitude, longitude])

	if op == 1:
		outputName = mapName + '/towers/ver.csv'
	elif op == 2:
		outputName = mapName + '/towers/att.csv'
	elif op == 3:
		outputName = mapName + '/towers/tmb.csv'
	with open(outputName, 'w', newline='') as csvfile:
		writer = csv.writer(csvfile)
		for item in locs:
			writer.writerow(item)

if __name__=='__main__':
	# 1 version
	# 2 att
	# 3 t-mobile
	if op == 1:
		mcc = 311
		mnc = 480
		file_prefix = 'ver'
	elif op == 2:
		mcc = 310
		mnc = 410
		file_prefix = 'att'
	elif op == 3:
		mcc = 310
		mnc = 260
		file_prefix = 'tmb'
	with open(mapName + '/maps_range_list.txt', 'r') as fp:
		for line in fp.readlines():
			f_list = [float(i) for i in line.split(' ')]
			map_ranges.append([f_list[0], f_list[1], f_list[2], f_list[3]])
	get_tower_raw()
	parsr_tower_location()