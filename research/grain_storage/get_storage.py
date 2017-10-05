import pandas

county_storage = pandas.read_csv('state_data_2012/county_storage.csv')
county_fips = pandas.read_csv('state_data_2012/county_fips.csv')

# Create GEOID for all counties
# Get fractionalproduction for each county
# Get virtual water content for all crops in each county location
