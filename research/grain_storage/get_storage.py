import pandas

# Read in dataset containing county harvest values
county_harvest = pandas.read_csv(
	'state_data_2012/county_acres_harvested_census.csv'
	)

# Read in dataset containing land area for all counties
# county_area = pandas.read_csv(
# 	'county_area.csv',
# 	converters={'STCOU': lambda x: str(x)},
# 	usecols=['STCOU','LND110210D']) # Retains leading zeros in STCOU column

# Read in dataset containing county grain storage (2012)
county_storage = pandas.read_csv(
	'state_data_2012/county_storage.csv',
	usecols=['State_Name','County','Grain_Storage_Capacity_Bushels']
	)

# Replace 'WILD RICE' with 'RICE' to simplify comparison with WF data in future
county_harvest.loc[county_harvest['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'

# Remove Alaska and Hawaii
county_harvest = county_harvest[county_harvest['State'] != 'ALASKA']
county_harvest = county_harvest[county_harvest['State'] != 'HAWAII']

# Convert value columns to numeric by removing thousands' place comma
# and converting all non-numeric, ie. ' (D)', to 'NaN'
# Note that ' (D)' means data was 'Withheld to avoid disclosing data for individual operations'
county_harvest[['Value','CV(%)']] = county_harvest[['Value','CV(%)']].apply(
	lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
		errors='coerce')
	)

# Remove NaN values as negligible in 'Value' section
county_harvest = county_harvest[pandas.notnull(county_harvest['Value'])]

# Create GEOID column
county_harvest['State_ANSI'] = county_harvest['State_ANSI'].apply(
	lambda x: str(x).zfill(2)
	)
county_harvest['County_ANSI'] = county_harvest['County_ANSI'].apply(
	lambda x: str(int(x)).zfill(3)
	)
county_harvest['GEOID'] = county_harvest['State_ANSI'] + county_harvest['County_ANSI']

# Convert '(D)' to NaN in county_storage dataframe
county_storage['Grain_Storage_Capacity_Bushels'] = county_storage['Grain_Storage_Capacity_Bushels'].apply(
	lambda x: pandas.to_numeric(x,errors='coerce')
	)

# Make Country and State names uppercase in county_storage dataframe
county_storage['State_Upper'] = county_storage['State_Name'].str.upper()
county_storage['County_Upper'] = county_storage['County'].str.upper()

# Merge county_harvest with county_storage to add storage values to dataframe
harvest_storage = county_harvest.merge(county_storage,left_on=['State','County'],right_on=['State_Upper','County_Upper'])

# Fix odd column names
harvest_storage.rename(columns={'State_x': 'State','County_x': 'County'},inplace=True) # Rename column header

# Collect percentage of all area harvested by commodity for each state-county pair
commodity_sum = harvest_storage.groupby(['GEOID','State','County','Commodity','Grain_Storage_Capacity_Bushels'])['Value'].sum() #sum
harvest = commodity_sum.groupby(['GEOID']).apply( #percent
	lambda x: 100 * x / float(x.sum())
	)

# Formatting
harvest = harvest.reset_index() # Makes output CSV pretty
harvest.rename(columns={'Value': 'Percent'},inplace=True) # Rename column header

# Add fractional grain storage to dataframe
harvest['Fractional_Grain_Storage_Bushels'] = harvest['Percent'] * 0.01 * harvest['Grain_Storage_Capacity_Bushels'] # Calculate fractional areas

# Add county land area to dataframe
# harvest = harvest.merge(county_area,left_on='GEOID',right_on='STCOU')
# harvest = harvest.drop('STCOU',1) # remove redundant column
# harvest.rename(columns={'LND110210D': 'LandArea_SqMi'},inplace=True) # Rename column header
# harvest['Fractional_Area_SqMi'] = harvest['Percent'] * 0.01 * harvest['LandArea_SqMi'] # Calculate fractional areas

# Output results to csv file
harvest.to_csv('county_fractional_grain_harvest.csv',index=False)
