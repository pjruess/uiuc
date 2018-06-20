import pandas
import matplotlib.pyplot as plt
import os

file = 'results/butte_summary.csv'

if not os.path.isfile(file):
	colnames = ['lon','lat','value']
	r1 = pandas.read_csv('data/l8_summer_rice_band1.csv',names=colnames)
	r2 = pandas.read_csv('data/l8_summer_rice_band2.csv',names=colnames)
	r3 = pandas.read_csv('data/l8_summer_rice_band3.csv',names=colnames)
	r4 = pandas.read_csv('data/l8_summer_rice_band4.csv',names=colnames)
	r5 = pandas.read_csv('data/l8_summer_rice_band5.csv',names=colnames)
	r6 = pandas.read_csv('data/l8_summer_rice_band6.csv',names=colnames)
	r7 = pandas.read_csv('data/l8_summer_rice_band7.csv',names=colnames)
	r8 = pandas.read_csv('data/l8_summer_rice_band8.csv',names=colnames)
	r9 = pandas.read_csv('data/l8_summer_rice_band9.csv',names=colnames)
	r10 = pandas.read_csv('data/l8_summer_rice_band10.csv',names=colnames)
	r11 = pandas.read_csv('data/l8_summer_rice_band11.csv',names=colnames)
	o1 = pandas.read_csv('data/l8_summer_other_band1.csv',names=colnames)
	o2 = pandas.read_csv('data/l8_summer_other_band2.csv',names=colnames)
	o3 = pandas.read_csv('data/l8_summer_other_band3.csv',names=colnames)
	o4 = pandas.read_csv('data/l8_summer_other_band4.csv',names=colnames)
	o5 = pandas.read_csv('data/l8_summer_other_band5.csv',names=colnames)
	o6 = pandas.read_csv('data/l8_summer_other_band6.csv',names=colnames)
	o7 = pandas.read_csv('data/l8_summer_other_band7.csv',names=colnames)
	o8 = pandas.read_csv('data/l8_summer_other_band8.csv',names=colnames)
	o9 = pandas.read_csv('data/l8_summer_other_band9.csv',names=colnames)
	o10 = pandas.read_csv('data/l8_summer_other_band10.csv',names=colnames)
	o11 = pandas.read_csv('data/l8_summer_other_band11.csv',names=colnames)

	df = pandas.DataFrame()
	df['rice_band1'] = r1['value']
	df['other_band1'] = o1['value']
	df['rice_band2'] = r2['value']
	df['other_band2'] = o2['value']
	df['rice_band3'] = r3['value']
	df['other_band3'] = o3['value']
	df['rice_band4'] = r4['value']
	df['other_band4'] = o4['value']
	df['rice_band5'] = r5['value']
	df['other_band5'] = o5['value']
	df['rice_band6'] = r6['value']
	df['other_band6'] = o6['value']
	df['rice_band7'] = r7['value']
	df['other_band7'] = o7['value']
	df['rice_band8'] = r8['value']
	df['other_band8'] = o8['value']
	df['rice_band9'] = r9['value']
	df['other_band9'] = o9['value']
	df['rice_band10'] = r10['value']
	df['other_band10'] = o10['value']
	df['rice_band11'] = r11['value']
	df['other_band11'] = o11['value']
	df.to_csv(file,index=False)
	print df.head()
else: 
	df = pandas.read_csv(file)
	df.drop('rice_band10',axis=1,inplace=True)
	df.drop('other_band10',axis=1,inplace=True)
	df.drop('rice_band11',axis=1,inplace=True)
	df.drop('other_band11',axis=1,inplace=True)
	print df.head()

# rice4 = df.dropna(subset=['rice_band4']) 
# rice5 = df.dropna(subset=['rice_band5']) 
# other4 = df.dropna(subset=['other_band4']) 
# other5 = df.dropna(subset=['other_band5']) 

# all_values = [rice4,rice5,other4,other5]

#fig, ax = plt.subplots()
# fig = plt.figure(1,figsize=(9,6))
# ax=fig.add_subplot(111)

# bp = ax.boxplot(all_values)
# fig.savefig('test.pdf',bbox_inches='tight')

box = df.boxplot(rot=90)#boxplot(['rice_band4','rice_band5','other_band4','other_band5'])
plt.savefig('results/compile_boxplots.png')