import re
import pandas

def read_to_csv(file):
	df = pandas.DataFrame()

	crop = file.split('/')[1].split('_')[0]
	loc = file.split('.')[0].split('_')[-1]

	alldata = []
	cols = []

	with open(file, 'r') as f:
		for line in f.readlines()[0].replace(' ','').replace('"','').replace('}','').split('{')[1:-1]:
			l = [i.split(':') for i in filter(None,line.split(','))]
			if len(cols) == 0: cols = ['{0}_{1}_{2}'.format(crop,loc,j[0]) for j in l]
			items = [j[1] for j in l]
			alldata.append(items)
	df = pandas.DataFrame(alldata,columns=cols)
	df.set_index('{0}_{1}_year'.format(crop,loc),inplace=True)
	df = df.apply(pandas.to_numeric)
	df = df.divide(1.e6)
	df['{0}_{1}_total'.format(crop,loc)] = df.sum(axis=1)
	df.to_csv('{0}.csv'.format(file.split('.')[0]))

files = ['data/corn_data_ewg_us.txt','data/corn_data_ewg_il.txt','data/soy_data_ewg_us.txt','data/soy_data_ewg_il.txt']

for file in files:
	read_to_csv(file)

