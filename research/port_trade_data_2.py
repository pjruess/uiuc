import pandas
import geocoder

exp = pandas.read_csv('../../research/port_data/port_exports_world_2012_raw.csv')
imp = pandas.read_csv('../../research/port_data/port_imports_world_2012_raw.csv')
trans = pandas.read_csv('../../research/port_data/SCTG-HS Crosswalk.csv')

# total = total value of goods
# sea = value of trade through vessel ports (seaborne trade)
# air = value of trade through airborne carriers
# van = value of shipments transported in any van-type container (already included in sea)
exp.columns = ['port','commodity','total_exports_$','sea_exports_$','sea_exports_kg','air_exports_$','air_exports_kg','van_exports_$','van_exports_kg']
imp.columns = ['port','commodity','total_imports_$','sea_imports_$','sea_imports_kg','air_imports_$','air_imports_kg','van_imports_$','van_imports_kg']

test = len(exp['port'].unique())
print 'Unique number of ports: {0}'.format(str(test))

# Sum all kg for total mass
exp['total_exports_kg'] = exp['sea_exports_kg'] + exp['air_exports_kg']
imp['total_imports_kg'] = imp['sea_imports_kg'] + imp['air_imports_kg']

# Merge dataframes to join by location and commodity
df = pandas.merge(exp,imp,how='outer')

# Create HS column representing four-digit HS codes
df['hs'] = df['commodity'].str[:4]

# Multiply all hs values less than 100 by 100
trans.loc[trans['hs'] < 100, ['hs']] *= 100

# Add leading zero to all hs values less than 1000
trans['hs'] = trans['hs'].apply('{:0>4}'.format)

# Slice first two digits from hs for trans and df dataframes
trans['hs_edit'] = trans['hs'].str[:2]
df['hs_edit'] = df['hs'].str[:2]

# Drop duplicate 'hs_edit' values to avoid redundancy
trans = trans.drop_duplicates(subset=['hs_edit'])

# Clean up trans
del trans['hs']
del trans['hs_description']

# Associate sctg values in trans with hs values in df
df = pandas.merge(df,trans,on=['hs_edit'])

# Clean up df
del df['hs_edit']

df = df[['port','commodity','total_exports_$','total_exports_kg','total_imports_$','total_imports_kg','hs','sctg']]

# Wrapper for an ugly groupby function to sum x for each port and sctg
def port_sctg(x):
	# x must be taken from df.columns, ie 'total_exports_$'
	# dropna() to remove NaN values
	# reset_index() to create a traditional pandas dataframe
	return df[x].groupby([df['port'],df['sctg']]).sum().dropna().reset_index()

sum_exp_cost = port_sctg('total_exports_$')
sum_exp_mass = port_sctg('total_exports_kg')

sum_imp_cost = port_sctg('total_imports_$')
sum_imp_mass = port_sctg('total_imports_kg')

# Merge all dataframes together to create one summary dataframe
dataframes = [sum_exp_cost,sum_exp_mass,sum_imp_cost,sum_imp_mass]
df = reduce(lambda left,right: pandas.merge(left,right,on=['port','sctg'],how='outer'),dataframes)

# ignore masses for now, since they seem less useful
df = df[['port','sctg','total_exports_$','total_imports_$']]

# Edit columns for readability later
df.columns = ['port','sctg','out($)','in($)']

# Awesome function for converting table format to make more csv-friendly
# Note: This basically does the opposite of the melt function
df = df.pivot_table(values=['out($)','in($)'],index='port',columns='sctg')

df.columns = [s1 + '_' + str(s2) for (s1,s2) in df.columns.tolist()]

df.reset_index(inplace=True)

# Clean up port names to make google geocoding more successful
df['port'] = df['port'].str.replace(r' \(.*?\)','')
df['port'] = 'Port ' + df['port']

def write_data(dest,type):
	if type == 'a': geodf = pandas.read_csv('../../research/port_data/counties.csv') # Find ports already read, then skip those
	else: geodf = pandas.DataFrame(columns=['port','county','lat','lon'])
	finished_ports = geodf['port'].values

	import unicodecsv as csv # Handles unicode characters in port names
	with open(dest, type) as f:
		w = csv.writer(f)
		if type == 'w': w.writerow(['port','county','latitude','longitude'])
		for p in df['port'].values:
			if p not in finished_ports:
				g = geocoder.google(p)
				# Retrieve county information
				try: # retrieve geocode results
					c = g.county
				except ValueError as err: # if none, fill with 'NoData'
					if str(err) == 'ZERO_RESULTS':
						c = 'NoData'
				
				# Retrieve latlon information
				try: # retrieve geocode results
					lat,lon = g.latlng
				except ValueError as err: # if none, fill with 'NoData'
					if str(err) == 'ZERO_RESULTS':
						lat,lon = ['NoData','NoData']
				
				print p, c, lat, lon
				w.writerow([p,c,lat,lon])
		f.close()

def get_geodata(dest):
	# Check if file exists, then run either as 'write' or 'append'
	import os.path
	if os.path.isfile(dest): write_data(dest,'a')
	else: write_data(dest,'w')

get_geodata('../../research/port_data/counties.csv')

geodf = pandas.read_csv('../../research/port_data/counties.csv') # Find ports already read, then skip those

finaldf = pandas.merge(df,geodf,on=['port'])

finaldf['port'] = finaldf['port'].apply(lambda x: x.split(' ',1)[1])

# Fill in empty counties using census api
import requests
def get_fcc_data(data,portlist,latlist,lonlist):
	res = []
	for port,lat,lon in zip(portlist,latlist,lonlist):
		url = 'http://data.fcc.gov/api/block/find?format=json&latitude={0}&longitude={1}'
		response = requests.get(url.format(lat,lon))
		try: 
			county = response.json()['County'][data]
		except: 
			county = 'NoData'
		res.append(county)
		print port,lat,lon,county

	return res

finaldf['ll_county'] = get_fcc_data('name',finaldf['port'],finaldf['latitude'],finaldf['longitude'])
finaldf['ll_fips'] = get_fcc_data('FIPS',finaldf['port'],finaldf['latitude'],finaldf['longitude'])

print finaldf

# print finaldf

# Write to csv
finaldf.to_csv('../../research/port_data/port_statistics_raw.csv',index=False,encoding='utf-8')