import pandas
import geocoder

exp = pandas.read_csv('../../research/landon/port_exports_world_2012_raw.csv')
imp = pandas.read_csv('../../research/landon/port_imports_world_2012_raw.csv')
trans = pandas.read_csv('../../research/landon/SCTG-HS Crosswalk.csv')

# total = total value of goods
# sea = value of trade through vessel ports (seaborne trade)
# air = value of trade through airborne carriers
# van = value of shipments transported in any van-type container (already included in sea)
exp.columns = ['port','commodity','total_exports_$','sea_exports_$','sea_exports_kg','air_exports_$','air_exports_kg','van_exports_$','van_exports_kg']
imp.columns = ['port','commodity','total_imports_$','sea_imports_$','sea_imports_kg','air_imports_$','air_imports_kg','van_imports_$','van_imports_kg']

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

# Gather port data from World Port Index
wpi = pandas.read_csv('../../research/landon/world_port_index_data.csv',usecols=['PORT_NAME','COUNTRY','LATITUDE','LONGITUDE'])#,'LAT_DEG','LAT_MIN','LAT_HEMI','LONG_DEG','LONG_MIN','LONG_HEMI'])
# Look only at ports in the US
wpi = wpi.loc[wpi['COUNTRY'] == 'US']

df.columns = [s1 + '_' + str(s2) for (s1,s2) in df.columns.tolist()]

df.reset_index(inplace=True)

# Clean up port names
# print df.loc[df['port'].str.contains('Airport')]['port'].str.replace(r' \(.*?\)','')

df['port'] = df['port'].str.replace(r' \(.*?\)','')
# df['port'] = df['port'].str.replace(' City','')
df['port'] = 'Port ' + df['port']
# print df

# print df
# df.loc[df['port'].str.contains('Airport'),'port'] = df['port'].replace(r' \(.*?\)','')
# print df
# df.loc[df['port'].str.contains('Airport'), df['port']].str.replace(r' \(.*?\)','')

# for p in df['port'].values:
# 	g = geocoder.google(p).latlng
# 	print g[0]
# 	1/0

# df['coords'] = df['port'].apply(geocoder.google)

# lo = 0
# hi = 10

# df3 = df.ix[lo:hi,:]

# df3 = df3.reset_index()

def write_data(dest,type):
	if type == 'a': geodf = pandas.read_csv('../../research/landon/counties.csv') # Find ports already read, then skip those
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

	print 'FINISHED'

def get_geodata(dest):
	# Check if file exists, then run either as 'write' or 'append'
	import os.path
	if os.path.isfile(dest): write_data(dest,'a')
	else: write_data(dest,'w')

get_geodata('../../research/landon/counties.csv')

geodf = pandas.read_csv('../../research/landon/counties.csv') # Find ports already read, then skip those

finaldf = pandas.merge(df,geodf,on=['port'])

print finaldf

# print geocoder.google('')

# print geodf.loc[(geodf['county'] == 'NoData') & (geodf['lat'] == 'NoData')] # 28 counties with no data

# df3['county'] = df3['port'].apply(lambda x: geocoder.google(x).county if geocoder.google(x) else 'No Data')

# print df3

# df['county'] = df['port'].apply(lambda x: geocoder.google(x).county if geocoder.google(x) else 'No Data')



# Get geocoded coords for each destination
# df['coords'] = df['port'].apply(lambda x: geocoder.google(x).latlng if geocoder.google(x) else ['No Data','No Data'])

# df['lat'], df['lon'] = zip(*[f.latlng for f in df['coords'] if f])

# df['lat'],df['lon'] = zip(*[f if f[0] != 'No Data' else f for f in df['coords']])

# print df

# Write to csv
finaldf.to_csv('../../research/landon/port_statistics_final.csv')

# df3.loc[df3['lat'].isnull()]['port'].replace({' City':''},regex=True,inplace=True) # select problem rows

# print df3.loc[df3['coords'].values == [None,None],'port']# = df3['port'].str.replace(' City','') # select problem rows

# df3.loc[df3['lat'].isnull(),'port'] = df3['port'].str.replace(' City','') # select problem rows

# df3['coords'] = df3.loc[df3['lat'].isnull(),'port'].apply(lambda x: geocoder.google(x).latlng if geocoder.google(x) else [None,None])

# print df3

# print df3.loc[df3['coords'].notnull().values]

# df3.loc[df3['coords'].notnull(),'lat'] = df3.loc[df3['coords'].notnull().values[0]]

# df3.loc[df3['lat'].isnull(),'lat'] = df3['coords'][0]

# df3['lat'],df3['lon'] = zip(*[f if f[0] is not nan else f for f in df3['coords']])


# print df3

# for p in df['port'].values:
	# Having problems with Detour City, MI (port Detour, MI exists)
	# If removing city, Atlantic City Airport fails...
	# print p, geocoder.google(p).latlng

# df['lat'], df['lon'] = zip(*[geocoder.google(p).latlng for p in df['port'].values])
# print df
# df3['coords'] = [geocoder.google(p).latlng for p in df3['port'].values]

# df3['lat'] = df['coords'][0]
# df3['lon'] = df['coords'][1]

# df3['coords'] = df3['port'].apply(geocoder.google)

# [geocoder.google(p).latlng for p in df['port'].values]