import pandas
import matplotlib.pyplot as plt
import os
import numpy

file = 'band_dif.csv'

if not os.path.isfile(file):
	colnames = ['lon','lat','value']
	r4 = pandas.read_csv('l8_summer_rice_band4.csv',names=colnames)
	r5 = pandas.read_csv('l8_summer_rice_band5.csv',names=colnames)
	r6 = pandas.read_csv('l8_summer_rice_band6.csv',names=colnames)

	o4 = pandas.read_csv('l8_summer_other_band4.csv',names=colnames)
	o5 = pandas.read_csv('l8_summer_other_band5.csv',names=colnames)
	o6 = pandas.read_csv('l8_summer_other_band6.csv',names=colnames)

	df = pandas.DataFrame()
	df['lon'] = r4['lon']
	df['lat'] = r4['lat']
	df['rice_band4'] = r4['value']
	df['other_band4'] = o4['value']
	df['rice_band5'] = r5['value']
	df['other_band5'] = o5['value']
	df['rice_band6'] = r6['value']
	df['other_band6'] = o6['value']
	df.to_csv(file,index=False)
	print df.head()
else: 
	df = pandas.read_csv(file)
	df['rice_dif'] = df['rice_band6'] - df['rice_band5']
	df['other_dif'] = df['other_band6'] - df['other_band5']
	print df.head()

box = df.boxplot(['rice_dif','other_dif'],rot=90)#boxplot(['rice_band4','rice_band5','other_band4','other_band5'])
plt.savefig('band_dif.png')