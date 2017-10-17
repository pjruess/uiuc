import pandas

# Read in dataset containing county grain harvest values
harvest_data = pandas.read_csv(
	'state_data_2012/county_harvest_census_2012.csv',
	usecols=['State','State ANSI','County','County ANSI','Commodity','Value']
	)
harvest_data.rename(columns={'Value': 'Harvest [Acre]'},inplace=True) # Rename column header

# Read in dataset containing county grain yield values
yield_data = pandas.read_csv(
	'state_data_2012/county_yield_2012.csv',
	usecols=['State','State ANSI','County','County ANSI','Commodity','Value']
	)
yield_data.rename(columns={'Value': 'Yield [Bu/Acre]'},inplace=True) # Rename column header

# Read in dataset containing county grain storage values
storage_data = pandas.read_csv(
	'state_data_2012/county_storage_2012.csv',
	usecols=['State','State ANSI','County','County ANSI','Value']
	)
storage_data.rename(columns={'Value': 'Storage [Bu]'},inplace=True) # Rename column header

# print harvest_data
# print yield_data
# print storage_data
alldata = harvest_data.merge(
	yield_data,on=['State','State ANSI','County','County ANSI','Commodity']).merge(
	storage_data,on=['State','State ANSI','County','County ANSI'])
# alldata = alldata[['']]
print harvest_data[harvest_data['County'] == 'AUTAUGA']
print yield_data[yield_data['County'] == 'AUTAUGA']
print storage_data[storage_data['County'] == 'AUTAUGA']
print alldata[alldata['County'] == 'AUTAUGA']
1/0
# Replace 'WILD RICE' with 'RICE' to simplify comparison with WF data in future
cropdata.loc[cropdata['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'

# Remove Alaska and Hawaii
cropdata = cropdata[cropdata['State'] != 'ALASKA']
cropdata = cropdata[cropdata['State'] != 'HAWAII']

# Convert value columns to numeric by removing thousands' place comma
# and converting all non-numeric, ie. ' (D)', to 'NaN'
# Note that ' (D)' means data was 'Withheld to avoid disclosing data for individual operations'
cropdata[['Value','CV(%)']] = cropdata[['Value','CV(%)']].apply(
	lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
		errors='coerce')
	)

# Remove NaN values as negligible in 'Value' section
cropdata = cropdata[pandas.notnull(cropdata['Value'])]

# Create GEOID column
cropdata['State_ANSI'] = cropdata['State_ANSI'].apply(
	lambda x: str(x).zfill(2)
	)
cropdata['County_ANSI'] = cropdata['County_ANSI'].apply(
	lambda x: str(int(x)).zfill(3)
	)
cropdata['GEOID'] = cropdata['State_ANSI'] + cropdata['County_ANSI']

# Convert '(D)' to NaN in storage dataframe
storage['Grain_Storage_Capacity_Bushels'] = storage['Grain_Storage_Capacity_Bushels'].apply(
	lambda x: pandas.to_numeric(x,errors='coerce')
	)

# Make Country and State names uppercase in storage dataframe
storage['State_Upper'] = storage['State_Name'].str.upper()
storage['County_Upper'] = storage['County'].str.upper()

# Merge cropdata with storage to add storage values to dataframe
harvest_storage = cropdata.merge(storage,left_on=['State','County'],right_on=['State_Upper','County_Upper'])

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