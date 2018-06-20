import pandas

# Read in dataset containing GEOIDs, Commodities, and Fractional Areas (Sq Mi)
harvest = pandas.read_csv('county_fractional_grain_harvest.csv',
	converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOID column

# Read in USDA to Water Footprint Network (WFN) commodity lookup table
usda_to_wfn = pandas.read_csv('usda_to_wfn.csv')

# Merge dataframes to relate USDA data to WFN commodity names
harvest = harvest.merge(usda_to_wfn,left_on='Commodity',right_on='usda')
harvest = harvest.drop('Commodity',1)

# Select type of water to use for Virtual Water Content (VWC) of commodities in each country
watertype = 'bl' # bl = blue; gn = irrigated green; rf = rainfed green

# Iterate over (GEOID, WFN Code) pairs to retrieve VWC values from VWC csv files
for i,g in harvest.groupby(['GEOID','wfn_code']): # (index: GEOID , group: WFN Code)
	file = 'cwu{0}_{1}_DATA'.format(i[1],watertype) # create correct file name
	path = 'vwc_csvfiles/' + file + '.csv'
	# Read in temporary dataframe for particular filename (based on WFN code and watertype)
	tempdf = pandas.read_csv(path,converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOID column
	# Retrieve VWC average for county in question, and add to new column in dataframe
	vwc = tempdf[tempdf['GEOID'] == i[0]]['MEAN'].values[0] # Mean VWC of county and commodity
	harvest.loc[(harvest['GEOID'] == i[0])&(harvest['wfn_code'] == i[1]),'VWC_m3ha'] = vwc # Add VWC to dataframe

# Output results to csv file
harvest.to_csv('county_storage_vwc.csv',index=False)