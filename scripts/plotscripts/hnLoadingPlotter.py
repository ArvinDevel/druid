#!/usr/bin/python

# Script plots the historical node loading (HN queue size + HN active threads)
# for all HNs. It also plots the broker query start time at y_axis = 5 units

import glob
import numpy as np
import matplotlib.pyplot as plt
import json
import _strptime
from datetime import datetime, timedelta
import re

# resolution in milliseconds, value 250 aggregates for 250ms
resolution = 500

def getBrokerActivityData():
	global resolution
					
	# concatenate all broker files
	brokerFiles = glob.glob("broker-*-query-time.log")
	data = []
	y = []
	for fname in brokerFiles:
		with open(fname) as f:
			firstline = True
			for line in f:
				# skip the first query time since it is for a dummy query
				if firstline == True:
					firstline = False
					continue

				l = line.rstrip('\n').split('\t')
				time = datetime.now()
				if len(l[0].split(".")) != 2:
					time = datetime.strptime(l[0], '%Y-%m-%d %H:%M:%S')
				else:
					time = datetime.strptime(l[0], '%Y-%m-%d %H:%M:%S.%f')
				time = time - timedelta(milliseconds=int(float(l[1])))
                                data.append(time)
				y.append(5)

	data.sort()
	x = []
	time = 0
	prevtime = data[0]
	for point in data:
		currtime = point
		time = time + (currtime - prevtime).total_seconds()*1000/resolution
		x.append(time)
		print time
		prevtime = currtime

	return x, y


numbers = re.compile(r'(\d+)')
def numericalSort(value):
    parts = numbers.split(value)
    parts[1::2] = map(int, parts[1::2])
    return parts

def plotHNLoading():
	global resolution
	bx, by = getBrokerActivityData()
	hnFiles = sorted(glob.glob("historical-*-segment-scan-pending.log"), key=numericalSort)
	loop = 0
	numHNPerPlot = 15
        maxPlotValue = 0
	for fname in hnFiles:
		with open(fname) as f:
			x = []
			y = []
			samples = 0
			prevtime = datetime.now()
			loadingSum = 0
			count = 0
			firstsample = True
			time = 0
			for line in f:
				l = line.rstrip('\n').split('\t')
				currtime = datetime.now()

				if len(l[0].split(".")) != 2:
					currtime = datetime.strptime(l[0], '%Y-%m-%d %H:%M:%S')					
				else:
					currtime = datetime.strptime(l[0], '%Y-%m-%d %H:%M:%S.%f')
				
				if firstsample == True :
					x.append(0)
					y.append(float(l[1]))
					firstsample = False
					prevtime = currtime
                                        print currtime
				else:	
					if(currtime-prevtime).total_seconds()*1000 <= resolution:
						loadingSum = loadingSum + float(l[1])
						count = count + 1
					else:
						time = time + (currtime - prevtime).total_seconds()*1000/resolution
						#time = time + 1
						x.append(time)
						if count == 0:
							y.append(float(l[1]))
							maxPlotValue = max(maxPlotValue, float(l[1]))
						else:
							y.append(float(loadingSum)/float(count))
							maxPlotValue = max(maxPlotValue, float(loadingSum)/float(count))
							count  = 1
							loadingSum = float(l[1])
						prevtime = currtime

			plt.plot(x, y, label='hn_'+fname.split("-")[1]+'_loading')
			loop = loop + 1
			if loop % numHNPerPlot == 0:
				plt.plot(bx, by, '.', label='broker query activity')
				if (numHNPerPlot > 5) :
					plt.legend(loc='upper left', fontsize = 'xx-small', ncol=4)
				else:
					plt.legend(loc='upper left', fontsize = 'small')
				plt.ylim(0, int(maxPlotValue))
				plt.title('Historical Node '+str(loop-numHNPerPlot)+' to '+str(loop-1)+' Loading')
				plt.ylabel('Loading (HN queue size + active threads)')
				plt.xlabel('Time (each tick is '+str(resolution)+' ms)')
				plt.savefig('hn_'+str(loop-numHNPerPlot)+'_to_'+str(loop-1)+'_loading.png')
				plt.clf()
				maxPlotValue = 0

def main():
	plotHNLoading()

main()

