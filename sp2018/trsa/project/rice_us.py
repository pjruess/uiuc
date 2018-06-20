import pandas

df = pandas.read_csv('FAOSTAT_all_all.csv')

df = df[df['Element'] == 'Area harvested']

df = df[(df['Area Code'] < 5000)] # & (df['Area Code'] < 5700) & (df['Area Code']%100 != 0)]

print df.head()

# print df[df['Item'] == 'Rice, paddy']

# df = df.groupy('Item',as_index=False).sum()

years = ['Y{0}'.format(i) for i in range(1961,2017)]

years = ['Y2016']

# for y in years:
# 	df = df.groupby('Item',as_index=False).sum()

for y in years:
	df[y].fillna(value=0, inplace=True)

	us = df[df['Area'] == 'United States of America']
	us = us.groupby('Item',as_index=False).sum()
	us['fraction'] = us[y] / us[y].sum() * 100
	print us[us['Item'] == 'Rice, paddy']

	world = df.groupby('Item',as_index=False).sum()
	world['{0}_Frac'.format(y)] = world[y] / world[y].sum() * 100
	print world[world['Item'] == 'Rice, paddy']