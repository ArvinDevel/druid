#!/usr/bin/python

# Script plots the broker query inter arrival times and broker query times across all brokers

import glob
import numpy as np
import matplotlib.pyplot as plt
import json
import _strptime
from datetime import datetime, timedelta
import re

def plotBrokerQueryTimes():
	# concatenate all workload files
	brFiles = glob.glob("broker-*-query-time.log")
	for fname in brFiles:
		donetime = []
		querytime = []
		firstsample = True
		with open(fname) as f:
			for line in f:
				if firstsample == True:
					firstsample = False
					continue
				l = line.rstrip('\n').split("\t")
				date = l[0]
				if len(l[0].split(".")) != 2:
					time = datetime.strptime(date, '%Y-%m-%d %H:%M:%S')
				else:
					time = datetime.strptime(date, '%Y-%m-%d %H:%M:%S.%f')
				donetime.append(time)
				querytime.append([time , int(float(l[1]))])

		# plot query inter arrival times
		maxqueryinterarrivaltime = 0
		donetime.sort()
		x = []
		y = []
		time = 0
		firstsample = True
		prevtime = datetime.now()
		cumulativetime = 0;
		for t in donetime:
			if firstsample == True:
				time = 0
				firstsample = False
			else:
				time = (t-prevtime).total_seconds()*1000
			cumulativetime = cumulativetime + time
			x.append(cumulativetime/1000)
			y.append(time)
			if time > maxqueryinterarrivaltime:
				maxqueryinterarrivaltime = time
				maxtime = t
			prevtime = t

		plt.plot(x, y, label='inter-arrival time')
		plt.legend(loc='upper right', fontsize = 'small')
		plt.title('broker-'+fname.split("/")[-1].split(".")[0].split("-")[1]+' query inter-arrival time')
		plt.ylabel('Inter-arrival time (ms)')
		plt.xlabel('Time (secs)')
		plt.ylim(0, max(y))
		plt.savefig('broker-'+fname.split("/")[-1].split(".")[0].split("-")[1]+'-query-interarrival-plot.png')
		plt.clf()
		print fname.split("/")[-1]+" :"
		print "  Output plot : broker-"+fname.split("/")[-1].split(".")[0].split("-")[1]+"-query-interarrival-plot.png"
		print "    Median is "+str(np.median(y))
		print "    Max query inter-arrival time is "+str(maxqueryinterarrivaltime)+" at time "+str(maxtime)+" first sample was at time "+str(donetime[0])

		# plot the broker query time
		maxquerytime = 0
		b = []
		b = sorted(querytime,key=lambda t: t[0])
		maxindex, maxquerytime = max(querytime, key=lambda item: item[1])
		plt.plot(x, [row[1] for row in b], label='query time')
		plt.legend(loc='upper right', fontsize = 'small')
		plt.title(fname.split("/")[-1].split(".")[0])
		plt.ylabel('Query processing time (ms)')
		plt.xlabel('Time (secs)')
		plt.ylim(0, max([row[1] for row in b]))
		plt.savefig(fname.split("/")[-1].split(".")[0]+'-plot.png')
		plt.clf()
		print "  Output plot : "+fname.split("/")[-1].split(".")[0]+"-plot.png"
		print "    Median is "+str(np.median([row[1] for row in b]))
		print "    Max query/time is "+str(maxquerytime)+" at time "+str(maxindex)+" very first query time is "+str(querytime[0][0])

def main():
	plotBrokerQueryTimes()

main()

