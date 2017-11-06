# Paul J. Ruess
# University of Illinois at Urbana-Champaign
# Fall 2017
# Personal Research
# US Virtual Water Storage by County

import pandas
import scipy
import os
import itertools
import re

### READ IN RAW DATA ###
class alldata:
    """Class for reading in and cleaning harvest, yield, 
    and storage values from raw USDA data in .csv format"""

    def __init__(self,harvest_path,harvest_cols,yield_path,yield_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,codes_path,usda_to_wfn_path,states_ignore):
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

        # Read in USDA to Water Footprint Network (WFN) commodity lookup table
        self.usda_to_wfn = pandas.read_csv(usda_to_wfn_path)

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

        # Manually add two counties present in harvest data but not present in county_codes database
        self.county_codes = self.county_codes.append(pandas.Series({'State ANSI':46,'District ANSI':70,'County ANSI':102,'Name':'Oglala Lakota','History Flag':0}),ignore_index=True)
        self.county_codes = self.county_codes.append(pandas.Series({'State ANSI':56,'District ANSI':50,'County ANSI':31,'Name':'Platte','History Flag':0}),ignore_index=True)

        # Call cleaning function
        self.clean_data(self.harvest_data,'Harvest_Acre')
        self.clean_data(self.yield_data,'Yield_Bu_per_Acre')
        self.clean_data(self.storage_data,'Storage_Bu')

        # Make sure yield and harvest data are available for the same commodities
        # if len(self.harvest_data['Commodity']) != len(self.yield_data['Commodity']):
        #     a_list = list( set(self.harvest_data['Commodity']) - set(self.yield_data['Commodity']) )
        #     b_list = list( set(self.yield_data['Commodity']) - set(self.harvest_data['Commodity']) )
        #     if len(a_list) > 0:
        #         for a in a_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
        #     if len(b_list) > 0:
        #         for b in b_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # Create GEOID column for datasets
        self.create_geoid(self.county_codes)
        self.create_geoid(self.harvest_data)
        self.create_geoid(self.yield_data)
        self.create_geoid(self.storage_data)

        # Stretch yield and harvest data out
        # self.harvest_data = self.stretch(self.harvest_data,'Harvest_Acre') # don't want this
        self.yield_data = self.stretch(self.yield_data,'Yield_Bu_per_Acre','stretched_yield_data_2012.csv')

        # Get fractional harvest distribution
        self.harvest_data = self.harvest_fraction()

        # Add place-holders for all geoid-commodity pairs not currently represented
        self.harvest_data = self.fill_data(self.harvest_data,'harvest','filled_harvest_data_2012.csv')
        self.yield_data = self.fill_data(self.yield_data,'yield','filled_yield_data_2012.csv')
        # self.storage_data = self.fill_data(self.storage_data,'storage','filled_storage_data_2012.csv')

        # Retrieve VWC values
        self.vwc_data = self.get_vwc('bl','vwc_data.csv') # bl = blue; gn = irrigated green; rf = rainfed green       
        
        # Create comprehensive database for all data
        finaldf = self.summary_df('preliminary_summary_data.csv')

        # Calculate VWS
        vws = self.calculate_vws(finaldf,'vws_all_data.csv')

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

    # Dis-aggregate data from 'other counties' to all existing counties
    def stretch(self,dataset,value,path):
        if os.path.isfile(path):
            print 'Loading stretched_data file found at {0}'.format(path)
            dfnew = pandas.read_csv(path,usecols=dataset.columns)
            dfnew['GEOID'] = dfnew['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return dfnew
        else:
            print 'Creating new stretched_data file at {0}'.format(path)
            others = dataset[dataset['County ANSI'] == 'nan']
            nonothers = dataset[dataset['County ANSI'] != 'nan']
            newrows = []
            for i,r in others.iterrows():
                d = nonothers[(nonothers['State'] == r['State']) & (nonothers['Ag District'] == r['Ag District']) & (nonothers['Commodity'] == r['Commodity'])] # dataframe of nonothers matching state-agdist-commodity of current 'others' row
                a = self.county_codes[(self.county_codes['State ANSI'] == r['State ANSI']) & (self.county_codes['District ANSI'] == r['Ag District Code'])]# dataframe of all counties matching state-agdist-commodity of current 'others' row
                nodata_geoids = set(a['GEOID'].unique()) - set(d['GEOID'].unique())
                
                # For each geoid not represented, copy 'others' data and add row with updated geoid (and county, etc.)
                for g in nodata_geoids:
                    temprow = others.loc[i,]
                    c = self.county_codes[(self.county_codes['GEOID'] == g) & (self.county_codes['District ANSI'] == r['Ag District Code'])]
                    temprow.at['County'] = c['Name'].values[0].upper()
                    temprow.at['GEOID'] = '{0:05g}'.format(int(g))
                    temprow.at['County ANSI'] = c['County ANSI'].values[0]
                    newrows.append(temprow)
        
            # Create new dataframe 
            dfnew = nonothers.append(pandas.DataFrame(newrows,columns=nonothers.columns)) 
            dfnew = dfnew.sort_values(['GEOID','Commodity'],ascending=[True,True])
            dfnew.to_csv(path,index=False)
            return dfnew

    # Convert harvest values to county-wide fractional harvest
    # Note: This function removes any rows with '(D)' values. These are added in later as empty rows (because no data is available anyway)
    def harvest_fraction(self):

        # Collect percentage of all area harvested by commodity for each state-county pair
        self.harvest_data['Percent_Harvest'] = self.harvest_data['Harvest_Acre'] # initialize new column
        df = self.harvest_data.groupby(['GEOID','State','Ag District','County','Commodity','Harvest_Acre'])['Percent_Harvest'].sum() #sum
        harvest = df.groupby(['GEOID']).apply( #percent
        	lambda x: 100 * x / float(x.sum())
        	)
        harvest = harvest.reset_index()
        return harvest
        # print harvest[harvest['GEOID'] == '56015']

    # Fill dataset with all potential pairs
    def fill_data(self,dataset,datatype,path):
        if os.path.isfile(path):
            print 'Loading fill_data file found at {0}'.format(path)
            dfnew = pandas.read_csv(path)
            dfnew['GEOID'] = dfnew['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return dfnew
        else:
            print 'Creating new fill_data file at {0}'.format(path)
            geoids = sorted(self.county_codes['GEOID'].unique())
            commodities = sorted(set([re.findall(r'[\w]+',i)[0] for i in yield_trim_list]))
            indices = itertools.product(geoids,commodities)

            # If storage, insert 'Commodity' column
            if 'Commodity' not in dataset.columns:
                dataset['Commodity'] = ''

            # Create empty list and find column index for values
            newrows = []
            g_ix = dataset.columns.get_loc('GEOID')
            c_ix = dataset.columns.get_loc('Commodity')

            # Iterate over all geoid-commodity pairs and add geoid-commodity as empty column if it does not exist
            for g,c in indices:
                if not ((dataset['GEOID'] == g) & (dataset['Commodity'] == c)).any():
                    temprow = [scipy.nan]*len(dataset.columns)
                    temprow[g_ix] = '{0:05g}'.format(int(g))
                    temprow[c_ix] = c
                    newrows.append(temprow)
            dfnew = dataset.append(pandas.DataFrame(newrows,columns=dataset.columns))
            dfnew = dfnew.sort_values(['GEOID','Commodity'],ascending=[True,True])
            dfnew.to_csv(path,index=False)
            return dfnew

    # Create VWC dataframe
    def get_vwc(self,watertype,path):
        if os.path.isfile(path):
            print 'Loading vwc_data file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['GEOID'] = df['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return df
        else:
            print 'Creating new vwc_data file at {0}'.format(path)
            print path
            # Create list of (geoid,wfn_code,commodity) pairs to iterate over
            geoids = sorted(self.county_codes['GEOID'].unique())
            commodities = sorted(set([re.findall(r'[\w]+',i)[0] for i in yield_trim_list]))
            wfn_codes = []
            for c in commodities:
                wfn = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
                wfn_codes.append(wfn)
            indices = itertools.product(geoids,commodities)
    
            # Select type of water to use for Virtual Water Content (VWC) of commodities in each country
            watertype = 'bl' # bl = blue; gn = irrigated green; rf = rainfed green
    
            # Add VWC data to dataframe
            # Iterate over (GEOID, WFN Code) pairs to retrieve VWC values from VWC csv files
            newrows = []
            for g,c in indices:
                w = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
                # print 'Adding GEOID {0} and Commodity {1}'.format(g,c)
                f = 'cwu{0}_{1}'.format(w,watertype) # create correct file name
                data_path = 'vwc_zonal_stats/output/' + f + '.csv'
                # Read in temporary dataframe for particular filename (based on WFN code and watertype)
                df = pandas.read_csv(data_path,converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOIDs
                tempdf = df
                # Retrieve VWC average for county in question, and add to new column in dataframe
                if ((len(tempdf[tempdf['GEOID']==g]) == 0) or not (tempdf[tempdf['GEOID']==g]['mean'].values[0])): 
                    vwc = 'NaN' 
                else: 
                    vwc = tempdf[tempdf['GEOID'] == g]['mean'].values[0] # Mean VWC of county and commodity
                temprow = [g,c,vwc]
                newrows.append(temprow)
                print f
                print temprow

            # Create dataframe from newrows data
            cols = ['GEOID','Commodity','VWC_m3ha']
            df = pandas.DataFrame(newrows,columns=cols)
            df.to_csv(path,index=False)
            
        return df

    # Create summary dataframe with all data organized by GEOID
    def summary_df(self,path):
        if os.path.isfile(path):
            print 'Loading summary_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['GEOID'] = df['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return df
        else:
            print 'Creating new summary_df file at {0}'.format(path)
            self.yield_data = self.yield_data.groupby(['GEOID','Commodity'],as_index=False)['Yield_Bu_per_Acre'].mean()
            self.harvest_data = self.harvest_data.groupby(['GEOID','Commodity'],as_index=False)['Percent_Harvest'].mean()
    
            # Merge harvest_data and yield_data
            harvest_yield_data = self.harvest_data.merge(self.yield_data,on=['GEOID','Commodity'])
    
            # Merge harvest_yield_data with vwc_data
            finaldf = harvest_yield_data.merge(self.vwc_data,on=['GEOID','Commodity'])
            
            # Add storage data to dataframe
            geoids = sorted(self.county_codes['GEOID'].unique())
            for g in geoids:
                s = self.storage_data[self.storage_data['GEOID'] == g]['Storage_Bu'].values
                if len(s) == 0: s = 'NaN'
                finaldf.loc[finaldf['GEOID']==g,'Storage_Bu'] = s
    
            # # Create list of (geoid,wfn_code) pairs to iterate over
            # commodities = sorted(set([re.findall(r'[\w]+',i)[0] for i in yield_trim_list]))
            # wfn_codes = []
            # for c in commodities:
            #     wfn = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
            #     wfn_codes.append(wfn)
            # indices = itertools.product(geoids,wfn_codes,commodities)
    
            # # Select type of water to use for Virtual Water Content (VWC) of commodities in each country
            # watertype = 'bl' # bl = blue; gn = irrigated green; rf = rainfed green
    
            # # Add VWC data to dataframe
            # # Iterate over (GEOID, WFN Code) pairs to retrieve VWC values from VWC csv files
            # for g,w,c in indices:
            #     f = 'cwu{0}_{1}'.format(w,watertype) # create correct file name
            #     path = 'vwc_zonal_stats/output/' + f + '.csv'
            #     # Read in temporary dataframe for particular filename (based on WFN code and watertype)
            #     tempdf = pandas.read_csv(path,converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOIDs
            #     # Retrieve VWC average for county in question, and add to new column in dataframe
            #     if len(tempdf[tempdf['GEOID']==g]) == 0: vwc = 'NaN' 
            #     else: vwc = tempdf[tempdf['GEOID'] == g]['mean'].values[0] # Mean VWC of county and commodity
            #     finaldf.loc[ (finaldf['GEOID'] == g) & (finaldf['Commodity'] == c), 'VWC_m3ha' ] = vwc # Add VWC to df
    
            finaldf.to_csv(path,index=False)

        return finaldf

    # Calculate VW of storage 
    def calculate_vws(self,dataset,path):
        dataset = dataset.replace(r'\s+', scipy.nan, regex=True)
        dataset['Percent_Harvest'] = pandas.to_numeric(dataset['Percent_Harvest'],errors='coerce')
        dataset['Yield_Bu_per_Acre'] = pandas.to_numeric(dataset['Yield_Bu_per_Acre'],errors='coerce')
        dataset['VWC_m3ha']  = pandas.to_numeric(dataset['VWC_m3ha'],errors='coerce')
        dataset['Storage_Bu'] = pandas.to_numeric(dataset['Storage_Bu'],errors='coerce')
        # dataset = pandas.to_numeric(dataset[['Percent_Harvest','Yield_Bu_per_Acre','VWC_m3ha','Storage_Bu']],errors='coerce')
        dataset['VWS_m3'] = dataset['VWC_m3ha'] * ( 1. / dataset['Yield_Bu_per_Acre'] ) * dataset['Storage_Bu'] * dataset['Percent_Harvest'] * 0.405 # ha/acre
        dataset.to_csv(path,index=False)
        vws = dataset['VWS_m3'].sum()
        print '{0:,}'.format(long(vws))
        return vws

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
    usda_to_wfn_path = 'usda_to_wfn.csv'
    states_ignore = ['ALASKA','HAWAII']

    data = alldata(harvest_path,harvest_cols,yield_path,yield_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,codes_path,usda_to_wfn_path,states_ignore)
