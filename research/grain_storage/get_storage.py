import pandas

county_storage = pandas.read_csv(
	'state_data_2012/county_storage.csv'
	)
county_fips = pandas.read_csv(
	'state_data_2012/county_fips.csv'
	)
county_harvest = pandas.read_csv(
	'state_data_2012/county_acres_harvested_census.csv'
	)

# Remove Alaska and Hawaii
county_harvest = county_harvest[county_harvest['State'] != 'ALASKA']
county_harvest = county_harvest[county_harvest['State'] != 'HAWAII']

# Convert numeric columns to numeric by removing thousands' place ','
# and converting all non-numeric, ie. ' (D)', to 'NaN'
county_harvest[['Value','CV(%)']] = county_harvest[['Value','CV(%)']].apply(
	lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
		errors='coerce')
	)

# Remove NaN values as negligible in 'Value' section
# NaN came from '(D)': Withheld to avoid disclosing data for individual operations. 
county_harvest = county_harvest[pandas.notnull(county_harvest['Value'])]

# Create GEOID column
county_harvest['State_ANSI'] = county_harvest['State_ANSI'].apply(
	lambda x: str(x).zfill(2)
	)
county_harvest['County_ANSI'] = county_harvest['County_ANSI'].apply(
	lambda x: str(int(x)).zfill(3)
	)
county_harvest['GEOID'] = county_harvest['State_ANSI'] + county_harvest['County_ANSI']

# Collect percentage of all area harvested by commodity for each state-county pair
commodity_sum = county_harvest.groupby(['GEOID','Commodity'])['Value'].sum() #sum
harvest_pcts = commodity_sum.groupby(['GEOID']).apply( #percent
	lambda x: 100 * x / float(x.sum())
	)
harvest_pcts = harvest_pcts.reset_index()
print harvest_pcts

# Get virtual water content for all crops in each county location
# 15 - wheat
# 27 - rice, paddy
# 44 - barley
# 56 - maize
# 71 - rye
# 75 - oats
# 79 - millet
# 83 - sorghum
# 89 - buckwheat
# 97 - triticale
# 103 - mixed grains
# 108 - cereal nes

