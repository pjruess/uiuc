# Paul J. Ruess
# University of Illinois at Urbana-Champaign
# Fall 2017
# Personal Research
# US Virtual Water Storage by County

import pandas

### READ IN RAW DATA ###
class alldata:
    """Class for reading in and cleaning harvest, yield, 
    and storage values from raw USDA data in .csv format"""

    def __init__(self,harvest_path,harvest_cols,yield_path,yield_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,codes_path,states_ignore):
        """All 'path' inputs must be strings leading to harvest, 
        yield, and storage data file paths, respectively
        All 'cols' inputs must be lists of strings specifying
        which columns to import for each dataset"""

        # Read in dataset containing county grain harvest values
        self.harvest_data = pandas.read_csv(harvest_path,usecols=harvest_cols)

        # Read in dataset containing county grain yield values
        self.yield_data = pandas.read_csv(yield_path,usecols=yield_cols)

        # Read in dataset containing county grain storage values
        self.storage_data = pandas.read_csv(storage_path,usecols=storage_cols)

        # Read in dataset containing all county codes
        self.county_codes = pandas.read_csv(codes_path)

        # Manual cleaning unique to specific datasets
        # Trim to contain only commodities existing for all available data
        self.harvest_data = self.harvest_data[self.harvest_data['Data Item'].isin(harvest_trim_list)]
        self.yield_data = self.yield_data[self.yield_data['Data Item'].isin(yield_trim_list)]       

        # Replace 'WILD RICE' with 'RICE' to simplify comparison with WF data in future
        self.harvest_data.loc[self.harvest_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'

        # Remove summary county codes: 888 (District) and 999 (State)
        self.county_codes = self.county_codes[-self.county_codes['County ANSI'].isin(['888','999'])][:-1]
        
        # Remove empty rows (ie. no data in any columns) originated from reading in codes data from url
        self.county_codes = self.county_codes[pandas.notnull(self.county_codes['County ANSI'])]
        
        # Call cleaning function
        self.clean_data(self.harvest_data,'Harvest_Acre')
        self.clean_data(self.yield_data,'Yield_Bu_per_Acre')
        self.clean_data(self.storage_data,'Storage_Bu')

        # Make sure yield and harvest data are available for the same commodities
        if len(self.harvest_data['Commodity']) != len(self.yield_data['Commodity']):
            a_list = list( set(self.harvest_data['Commodity']) - set(self.yield_data['Commodity']) )
            b_list = list( set(self.yield_data['Commodity']) - set(self.harvest_data['Commodity']) )
            if len(a_list) > 0:
                for a in a_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
            if len(b_list) > 0:
                for b in b_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # Create GEOID column for datasets
        self.create_geoid(self.county_codes)
        self.create_geoid(self.harvest_data)
        self.create_geoid(self.yield_data)
        self.create_geoid(self.storage_data)

        # Stretch yield and harvest data out
        # self.harvest_data = self.stretch(self.harvest_data,'Harvest_Acre') # don't want this
        # self.yield_data = self.stretch(self.yield_data,'Yield_Bu_per_Acre')

        # Get fractional harvest distribution
        self.harvest_data = self.harvest_fraction()

    ### CLEAN UP DATA ###
    def clean_data(self,dataset,value_rename):
        """ Cleans up datasets """
        
        # Rename 'Value' column headers to have meaningful names
        dataset.rename(columns={'Value': value_rename},inplace=True) # Rename column header

        # Remove Alaska and Hawaii
        dataset.drop(dataset[dataset['State'].isin(states_ignore)].index,inplace=True)

        # Convert value columns to numeric by removing thousands' place comma
        # and converting all non-numeric, ie. ' (D)', to 'NaN'
        # Note that ' (D)' means data was 'Withheld to avoid disclosing data for individual operations'
        dataset[[value_rename]] = dataset[[value_rename]].apply(
            lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
                errors='coerce')
            )

    def create_geoid(self,dataset):
        # Create GEOID column for yield data
        dataset['State ANSI'] = dataset['State ANSI'].apply(
            lambda x: '{0:02g}'.format(x) # formats leading zeros while ignoring decimal points
            )
        dataset['County ANSI'] = dataset['County ANSI'].apply(
                lambda x: '{0:03g}'.format(x) # formats leading zeros while ignoring decimal points
            )
        dataset['GEOID'] = dataset['State ANSI'] + dataset['County ANSI']

#     # Weighted average of land areas for all counties in 'other counties' from yield data
#     def average_other_yields(self):
#         # Remove 'Other counties' sections to determine which counties are accounted for
#         yield_counties = self.yield_data[pandas.notnull(self.yield_data['County ANSI'])]
#         
#         # Create GEOID column for yield data
#         yield_counties.loc[:,'State ANSI'] = yield_counties['State ANSI'].apply(
#             lambda x: str(x).zfill(2)
#             )
#         yield_counties.loc[:,'County ANSI'] = yield_counties['County ANSI'].apply(
#             lambda x: str(int(x)).zfill(3)
#             )
#         yield_counties.loc[:,'GEOID'] = yield_counties['State ANSI'] + yield_counties['County ANSI']
#         
#         # Remove counties included in yield_counties from area list using GEOID
#         area_subset = self.area_data[-self.area_data['GEOID'].isin(yield_counties['GEOID'])]
# 
#         # Add column containing total land area by state
#         area_subset.loc[:,'STATELAND'] = area_subset.groupby(['STATEFP'])['ALAND'].transform('sum')
#         
#         # Add column with fraction of 'other counties' land area made up by each county
#         area_subset.loc[:,'LANDFRACTION'] = area_subset['ALAND']/area_subset['STATELAND']
#         
#         # Save class variables
#         self.area_subset = area_subset
#         self.yield_counties = yield_counties

#     # Use average_other_yields() output to fractionally allocate 'other counties' yield data
#     def stretch_yields(self):
#         pass
#         self.average_other_yields()
#         # Make sure all counties are in yield_data

    # Dis-aggregate data from 'other counties' to all existing counties
    def stretch(self,dataset,value):
        # dataset['STATE-DISTRICT'] = list(zip(dataset['State'], dataset['Ag District']))

        others = dataset[dataset['County ANSI'] == 'nan']
        nonothers = dataset[dataset['County ANSI'] != 'nan']
        # print self.county_codes[(self.county_codes['State ANSI'] == '01') & (self.county_codes['District ANSI'] == 40)]
        # print nonothers[(nonothers['State ANSI'] == '01') & (nonothers['Ag District Code'] == 40)] 

        # print others.head()

        newrows = []

        for i,r in others.iterrows():
            d = nonothers[(nonothers['State'] == r['State']) & (nonothers['Ag District'] == r['Ag District']) & (nonothers['Commodity'] == r['Commodity'])] # dataframe of nonothers matching state-agdist-commodity of current 'others' row
            # state_geoids = self.county_codes[self.county_codes['State ANSI'] == r['State ANSI']]['GEOID'].unique()
            # other_geoids = set(state_geoids) - set(d['GEOID'].values)
            # print d['GEOID'].unique()
            # print d.head()
            a = self.county_codes[(self.county_codes['State ANSI'] == r['State ANSI']) & (self.county_codes['District ANSI'] == r['Ag District Code'])]# dataframe of all counties matching state-agdist-commodity of current 'others' row
            # print a['GEOID'].unique()
            # print a.head()
            nodata_geoids = set(a['GEOID'].unique()) - set(d['GEOID'].unique())
            # df_to_add = dataset[(dataset['GEOID'].isin(nodata_geoids)) & (dataset['Commodity'] == r['Commodity'])]
            # print df_to_add
            
            # For each geoid not represented, copy 'others' data and add row with updated geoid (and county, etc.)
            for g in nodata_geoids:
                temprow = others.loc[i,]
                c = self.county_codes[(self.county_codes['GEOID'] == g) & (self.county_codes['District ANSI'] == r['Ag District Code'])]
                temprow.at['County'] = c['Name'].values[0]
                temprow.at['GEOID'] = g
                temprow.at['County ANSI'] = c['County ANSI'].values[0]
                newrows.append(temprow)
        
        # Create new dataframe 
        dfnew = nonothers.append(pandas.DataFrame(newrows,columns=others.columns)).reset_index() 
        return dfnew

    # Convert harvest values to county-wide fractional harvest
    # Add zero for counties with no harvest in a county
    def harvest_fraction(self):
        # print self.harvest_data[self.harvest_data['GEOID'] == '56015']
        # Collect percentage of all area harvested by commodity for each state-county pair
        self.harvest_data['Percent_Harvest'] = self.harvest_data['Harvest_Acre'] # initialize new column
        df = self.harvest_data.groupby(['GEOID','State','Ag District','County','Commodity','Harvest_Acre'])['Percent_Harvest'].sum() #sum
        harvest = df.groupby(['GEOID']).apply( #percent
        	lambda x: 100 * x / float(x.sum())
        	)
        harvest = harvest.reset_index()
        return harvest
        # print harvest[harvest['GEOID'] == '56015']

    # Create summary dataframe with all data organized by GEOID
    def summary_df(self):
        pass

    # Calculate VW of storage 
    def calculate_vws(self):
        pass

    def scraps(self):
        # Remove NaN values as negligible in Value columns
        # harvest_data = harvest_data[pandas.notnull(harvest_data['Harvest_Acre'])]
        # yield_data = yield_data[pandas.notnull(yield_data['Yield_Bu_per_Acre'])]
        # storage_data = storage_data[pandas.notnull(storage_data['Storage_Bu'])]

        # alldata = harvest_data.merge(
        #   storage_data,on=['State','State ANSI','County','County ANSI'])

        #   yield_data,on=['State','State ANSI','County','County ANSI','Commodity']).merge(
        # alldata = alldata[['']]
        # print harvest_data[harvest_data['County'] == 'AUTAUGA']
        # print yield_data[yield_data['County'] == 'AUTAUGA']
        # print storage_data[storage_data['County'] == 'AUTAUGA']
        # print alldata[alldata['County'] == 'AUTAUGA']

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

if __name__ == '__main__':
    # All paths and column specifications for data class
    harvest_path = 'usda_nass_data/usda_county_harvest_census_2012.csv' # Census data is more complete than Survey data
    harvest_cols = ['State','State ANSI','County','County ANSI','Ag District','Ag District Code','Commodity','Data Item','Value']
    yield_path = 'usda_nass_data/usda_county_yield_2012.csv'
    yield_cols = ['State','State ANSI','County','County ANSI','Ag District','Ag District Code','Commodity','Data Item','Value']
    storage_path = 'usda_nass_data/usda_county_storage_2012.csv' # Note: This data is overall grain storage; commodities not specified
    storage_cols = ['State','State ANSI','County','County ANSI','Ag District','Ag District Code','Value']
    codes_path = 'usda_nass_data/county_codes.csv'
    areas_path = 'county_areas.csv'

    # Lists of commodities to trim dataframes to
    harvest_trim_list = ['BARLEY - ACRES HARVESTED',
        'CORN, GRAIN - ACRES HARVESTED',
        'OATS - ACRES HARVESTED',
        'SORGHUM, GRAIN - ACRES HARVESTED',
        'RICE - ACRES HARVESTED',
        'RYE - ACRES HARVESTED',
        'WILD RICE - ACRES HARVESTED', # later combined with rice
        'WHEAT, SPRING, (EXCL DURUM) - ACRES HARVESTED', # later combined to wheat
        'WHEAT, SPRING, DURUM - ACRES HARVESTED', # later combined to wheat
        'WHEAT, WINTER - ACRES HARVESTED' # later combined to wheat
        ]
    yield_trim_list = ['BARLEY - YIELD, MEASURED IN BU / ACRE',
        'CORN, GRAIN - YIELD, MEASURED IN BU / ACRE',
        'OATS - YIELD, MEASURED IN BU / ACRE',
        'SORGHUM, GRAIN - YIELD, MEASURED IN BU / ACRE',
        'RICE - YIELD, MEASURED IN LB / ACRE',
        'RYE - YIELD, MEASURED IN BU / ACRE',
        'WHEAT, SPRING, DURUM - YIELD, MEASURED IN BU / ACRE', # later combined to wheat
        'WHEAT, SPRING, (EXCL DURUM) - YIELD, MEASURED IN BU / ACRE', # later combined to wheat
        'WHEAT, WINTER - YIELD, MEASURED IN BU / ACRE' # later combined to wheat
        ]

    states_ignore = ['ALASKA','HAWAII']

    data = alldata(harvest_path,harvest_cols,yield_path,yield_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,codes_path,states_ignore)
        
    # print '------------------------------------------'
    # print 'harvest coms ',data.harvest_data.Commodity.unique()
    # print 'yield coms ',data.yield_data.Commodity.unique()
    # print '------------------------------------------'
    # print 'harvest data items ',data.harvest_data['Data Item'].unique()
    # print 'yield data items ',data.yield_data['Data Item'].unique()
    # print '------------------------------------------'
