# Paul J. Ruess
# University of Illinois at Urbana-Champaign
# Fall 2017
# Personal Research
# US Virtual Water Storage by State

import pandas
import scipy
import os
import itertools
import re

### READ IN RAW DATA ###
class alldata:
    """Class for reading in and cleaning harvest, yield, 
    and storage values from raw USDA data in .csv format"""

    def __init__(self,harvest_path,harvest_cols,yield_path,yield_cols,production_path,production_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,production_trim_list,codes_path,usda_to_wfn_path,states_ignore,year):
        """All 'path' inputs must be strings leading to harvest, 
        yield, and storage data file paths, respectively
        All 'cols' inputs must be lists of strings specifying
        which columns to import for each dataset"""

        # Read in dataset containing state grain harvest values
        self.harvest_data = pandas.read_csv(harvest_path,usecols=harvest_cols)
        self.harvest_data = self.harvest_data.loc[self.harvest_data['Program'] == 'CENSUS']
        del self.harvest_data['Program']

        # Read in dataset containing state grain yield values
        self.yield_data = pandas.read_csv(yield_path,usecols=yield_cols)
        self.yield_data = self.yield_data.loc[self.yield_data['State'] != 'OTHER STATES']

        # Read in dataset containing state grain production values
        self.production_data = pandas.read_csv(production_path,usecols=production_cols)
        self.production_data = self.production_data.loc[self.production_data['Program'] == 'CENSUS']
        del self.production_data['Program']

        # Read in dataset containing state grain storage values
        self.storage_data = pandas.read_csv(storage_path,usecols=storage_cols)

        # Read in USDA to Water Footprint Network (WFN) commodity lookup table
        self.usda_to_wfn = pandas.read_csv(usda_to_wfn_path)

        # Read in year variable
        self.year = year

        # Read in dataset containing all county codes
        self.county_codes = pandas.read_csv(codes_path)

        # Manual cleaning unique to specific datasets
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
        self.clean_data(self.production_data,'Production_Bu')
        self.clean_data(self.storage_data,'Storage_Bu')

        # Replace harvest 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.harvest_data.loc[self.harvest_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
        self.harvest_data.loc[self.harvest_data['Commodity'] == 'SWEET RICE','Commodity'] = 'RICE'
        self.harvest_data['Harvest_Acre'] = self.harvest_data.groupby(['State ANSI','Commodity'])['Harvest_Acre'].transform('sum')
        self.harvest_data = self.harvest_data.drop_duplicates(subset=(['State ANSI','Commodity']))

        # Replace production 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.production_data.loc[self.production_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
        self.production_data.loc[self.production_data['Commodity'] == 'SWEET RICE','Commodity'] = 'RICE'
        self.production_data['Production_Bu'] = self.production_data.groupby(['State ANSI','Commodity'])['Production_Bu'].transform('sum')
        self.production_data = self.production_data.drop_duplicates(subset=(['State ANSI','Commodity']))

        # Convert Rice values to Bu from CWT (1 CWT ~ 2.22 Bu)
        # Conversion info: https://www.omicnet.com/reports/past/archives/ca/tbl-1.pdf
        self.production_data.loc[self.production_data['Commodity'] == 'RICE','Production_Bu'] = self.production_data.loc[self.production_data['Commodity'] == 'RICE','Production_Bu']*2.22

        # Convert Rice yield values to Bu/Acre from Lb/Acre (45 Lbs ~ 1 Bu)
        # Conversion info: ftp://www.ilga.gov/JCAR/AdminCode/008/00800600ZZ9998bR.html 
        self.yield_data.loc[self.yield_data['Commodity'] == 'RICE','Yield_Bu_per_Acre'] = self.yield_data.loc[self.yield_data['Commodity'] == 'RICE','Yield_Bu_per_Acre']/45.

        # Trim to contain only commodities existing for all available data
        self.harvest_data = self.harvest_data[self.harvest_data['Data Item'].isin(harvest_trim_list)]
        self.yield_data = self.yield_data[self.yield_data['Data Item'].isin(yield_trim_list)]       
        self.production_data = self.production_data[self.production_data['Data Item'].isin(production_trim_list)]

        # Make sure harvest and yield data are available for the same commodities
        if len(self.harvest_data['Commodity']) != len(self.yield_data['Commodity']):
            a_list = list( set(self.harvest_data['Commodity']) - set(self.yield_data['Commodity']) )
            b_list = list( set(self.yield_data['Commodity']) - set(self.harvest_data['Commodity']) )
            if len(a_list) > 0:
                for a in a_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
            if len(b_list) > 0:
                for b in b_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # Make sure harvest and production data are available for the same commodities
        if len(self.harvest_data['Commodity']) != len(self.production_data['Commodity']):
            a_list = list( set(self.harvest_data['Commodity']) - set(self.production_data['Commodity']) )
            b_list = list( set(self.production_data['Commodity']) - set(self.harvest_data['Commodity']) )
            if len(a_list) > 0:
                for a in a_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
            if len(b_list) > 0:
                for b in b_list:
                    self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # Get fractional harvest distribution
        self.harvest_data = self.harvest_fraction()

        # Add place-holders for all geoid-commodity pairs not currently represented
        self.harvest_data = self.fill_data(self.harvest_data,'harvest','filled_harvest_data_{0}.csv'.format(self.year))
        self.yield_data = self.fill_data(self.yield_data,'yield','filled_yield_data_{0}.csv'.format(self.year))
        self.production_data = self.fill_data(self.production_data,'production','filled_production_data_{0}.csv'.format(self.year))

        # Retrieve VWC values
        self.vwc_data = self.get_vwc('bl','vwc_data.csv') # bl = blue; gn = irrigated green; rf = rainfed green       
        
        # Create comprehensive database for all data
        summarydf = self.summary_df('summary_data_{0}.csv'.format(self.year))

        # Calculate VWS
        vws = self.calculate_vws(summarydf,'final_data_{0}.csv'.format(self.year))

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

    # Convert harvest values to state-wide fractional harvest
    # Note: This function removes any rows with '(D)' values. These are added in later as empty rows (because no data is available anyway)
    def harvest_fraction(self):

        # Collect percentage of all area harvested by commodity for each state pair
        self.harvest_data['Percent_Harvest'] = self.harvest_data['Harvest_Acre'] # initialize new column
        df = self.harvest_data.groupby(['State','State ANSI','Commodity','Harvest_Acre'])['Percent_Harvest'].sum() #sum
        harvest = df.groupby(['State ANSI']).apply( #percent
        	lambda x: 100 * x / float(x.sum())
        	)
        harvest = harvest.reset_index()
        return harvest

    # Fill dataset with all potential pairs
    def fill_data(self,dataset,datatype,path):
        path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading fill_data file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            return df
        else:
            print 'Creating new fill_data file at {0}'.format(path)
            dataset['State ANSI'] = dataset['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            stateids = sorted(self.county_codes['State ANSI'].unique())
            commodities = sorted(set([re.findall(r'[\w]+',i)[0] for i in yield_trim_list]))
            indices = itertools.product(stateids,commodities)

            # If storage, insert 'Commodity' column
            if 'Commodity' not in dataset.columns:
                dataset['Commodity'] = ''

            # Create empty list and find column index for values
            newrows = []
            s_ix = dataset.columns.get_loc('State ANSI')
            c_ix = dataset.columns.get_loc('Commodity')

            # Iterate over all geoid-commodity pairs and add geoid-commodity as empty column if it does not exist
            for s,c in indices:
                s = '{0:02g}'.format(int(s))
                if not ((dataset['State ANSI'] == s) & (dataset['Commodity'] == c)).any():
                    temprow = [scipy.nan]*len(dataset.columns)
                    temprow[s_ix] = s
                    temprow[c_ix] = c
                    newrows.append(temprow)
            dfnew = dataset.append(pandas.DataFrame(newrows,columns=dataset.columns))
            dfnew = dfnew.sort_values(['State ANSI','Commodity'],ascending=[True,True])
            dfnew.to_csv(path,index=False)
            return dfnew

    # Create VWC dataframe
    def get_vwc(self,watertype,path):
        path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading vwc_data file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            return df
        else:
            print 'Creating new vwc_data file at {0}'.format(path)

            # Create list of (geoid,wfn_code,commodity) pairs to iterate over
            stateids = sorted(self.county_codes['State ANSI'].unique())
            commodities = sorted(set([re.findall(r'[\w]+',i)[0] for i in yield_trim_list]))
            indices = itertools.product(stateids,commodities)

            # Select type of water to use for Virtual Water Content (VWC) of commodities in each state
            watertype = 'bl' # bl = blue; gn = irrigated green; rf = rainfed green
    
            # Add VWC data to dataframe
            # Iterate over (State ANSI, WFN Code) pairs to retrieve VWC values from VWC csv files
            newrows = []
            for s,c in indices:
                s = '{0:02g}'.format(s)
                w = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
                f = 'cwu{0}_{1}'.format(w,watertype) # create correct file name
                data_path = 'vwc_zonal_stats/state_outputs/' + f + '.csv'
                # Read in temporary dataframe for particular filename (based on WFN code and watertype)
                df = pandas.read_csv(data_path,converters={'STATEFP': lambda x: str(x)}) # Retains leading zeros in State ANSI
                tempdf = df

                # Retrieve VWC average for state in question, and add to new column in dataframe
                if ((len(tempdf[tempdf['STATEFP']==s]) == 0) or not (tempdf[tempdf['STATEFP']==s]['mean'].values[0])): 
                    vwc = 'NaN' 
                    aland = 'NaN'
                else: 
                    vwc = tempdf[tempdf['STATEFP'] == s]['mean'].values[0] # Mean VWC of state and commodity
                    aland = tempdf[tempdf['STATEFP'] == s]['ALAND'].values[0] # ALAND in square meters
                temprow = [s,c,vwc,aland]
                newrows.append(temprow)
                print f

            # Create dataframe from newrows data
            cols = ['State ANSI','Commodity','VWC_m3ha','ALAND_sqmeters']
            df = pandas.DataFrame(newrows,columns=cols)
            df.to_csv(path,index=False)
            
        return df

    # Create summary dataframe with all data organized by State ANSI
    def summary_df(self,path):
        path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading summary_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            return df
        else:
            print 'Creating new summary_df file at {0}'.format(path)

            # self.harvest_data = self.harvest_data.groupby(['State ANSI','Commodity'],as_index=False)['Percent_Harvest'].mean()
            self.yield_data = self.yield_data.groupby(['State ANSI','Commodity'],as_index=False)['Yield_Bu_per_Acre'].mean()
            # self.production_data = self.production_data.groupby(['State ANSI','Commodity'],as_index=False)['Production_Bu'].mean()
    
            # Remove 'State' column to clean up merge
            del self.harvest_data['State']
            del self.production_data['State']

            # Merge harvest_data and yield_data
            harvest_yield_data = self.harvest_data.merge(self.yield_data,on=['State ANSI','Commodity'])
            harvest_yield_production_data = harvest_yield_data.merge(self.production_data,on=['State ANSI','Commodity'])
            harvest_yield_production_data = harvest_yield_production_data.drop_duplicates(subset=(['State ANSI','Commodity']))
            # Merge harvest_yield_data with vwc_data
            summarydf = harvest_yield_production_data.merge(self.vwc_data,on=['State ANSI','Commodity'])

            # Add storage data to dataframe
            stateids = sorted(self.county_codes['State ANSI'].unique())
            for s in stateids:
                stor = self.storage_data[self.storage_data['State ANSI'] == s]['Storage_Bu'].values
                if len(stor) == 0: stor = 'NaN'
                summarydf.loc[summarydf['State ANSI']=='{0:02g}'.format(int(s)),'Storage_Bu'] = stor

            summarydf.replace(r'\s+', scipy.nan, regex=True,inplace=True)
            summarydf.replace(0, scipy.nan,inplace=True)
            del summarydf['Data Item']
            summarydf.to_csv(path,index=False)
            
        return summarydf

    # Calculate VW of storage 
    def calculate_vws(self,dataset,path):
        path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading final_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
        else: 
            print 'Creating new final_df file at {0}'.format(path)
            df = dataset.replace(r'\s+', scipy.nan, regex=True)
            df['Harvest_Acre'] = pandas.to_numeric(df['Harvest_Acre'],errors='coerce')
            df['Percent_Harvest'] = pandas.to_numeric(df['Percent_Harvest'],errors='coerce')
            df['Yield_Bu_per_Acre'] = pandas.to_numeric(df['Yield_Bu_per_Acre'],errors='coerce')
            df['Production_Bu'] = pandas.to_numeric(df['Production_Bu'],errors='coerce')
            df['VWC_m3ha']  = pandas.to_numeric(df['VWC_m3ha'],errors='coerce')
            df['Storage_Bu'] = pandas.to_numeric(df['Storage_Bu'],errors='coerce')
            df['VWS_m3_yield'] = df['VWC_m3ha'] * ( 1. / df['Yield_Bu_per_Acre'] ) * df['Storage_Bu'] * df['Percent_Harvest'] * 0.405 # ha/acre
            df['VWS_m3_prod'] = df['VWC_m3ha'] * ( df['Harvest_Acre'] / df['Production_Bu'] ) * df['Storage_Bu'] * df['Percent_Harvest'] * 0.405 # ha/acre
            df.replace(r'\s+', scipy.nan, regex=True,inplace=True)
            df.replace(0, scipy.nan,inplace=True)
            df.to_csv(path,index=False)
        vws = df['VWS_m3_prod'].sum()
        print '{0} Summary...'.format(self.year)
        print '{0} Harvested Area (Acres):       {1:,}'.format(self.year,long(df['Harvest_Acre'].sum()))
        print '{0} Production (Bu):              {1:,}'.format(self.year,long(df['Production_Bu'].sum()))
        print '{0} Yield (Bu/Acre):              {1:,}'.format(self.year,long(df['Yield_Bu_per_Acre'].sum()))
        print '{0} Production/Harvest (Bu/Acre): {1:,}'.format(self.year,long((df['Production_Bu']/df['Harvest_Acre']).sum()))
        print '{0} Storage (Bu):                 {1:,}'.format(self.year,long(df['Storage_Bu'].sum()))
        print '{0} VWC (m3):                     {1:,}'.format(self.year,long(df['VWC_m3ha'].sum()))
        print '{0} Yield-based VWS (m3):         {1:,}'.format(self.year,long(df['VWS_m3_yield'].sum()))
        print '{0} Production-based VWS (m3):    {1:,}'.format(self.year,long(df['VWS_m3_prod'].sum()))
        return vws

if __name__ == '__main__':
    # Select year for analysis
    years_list = ['2002','2007','2012']

    # Iterate over all years and perform analysis
    for year in years_list:
        # All paths and column specifications for data class
        harvest_path = 'usda_nass_data/usda_state_harvest_{0}.csv'.format(year) # Census data more complete than Survey 
        harvest_cols = ['Program','State','State ANSI','Commodity','Data Item','Value']
        yield_path = 'usda_nass_data/usda_state_yield_{0}.csv'.format(year)
        yield_cols = ['State','State ANSI','Commodity','Data Item','Value']
        production_path = 'usda_nass_data/usda_state_production_{0}.csv'.format(year)
        production_cols = ['Program','State','State ANSI','Commodity','Data Item','Value']
        storage_path = 'usda_nass_data/usda_state_off-farm_storage_{0}.csv'.format(year) # Overall grain storage
        storage_cols = ['State','State ANSI','Value']
        codes_path = 'usda_nass_data/county_codes.csv'

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
        production_trim_list = ['BARLEY - PRODUCTION, MEASURED IN BU',
            'CORN, GRAIN - PRODUCTION, MEASURED IN BU',
            'OATS - PRODUCTION, MEASURED IN BU',
            'SORGHUM, GRAIN - PRODUCTION, MEASURED IN BU',
            'RICE - PRODUCTION, MEASURED IN CWT',
            'RYE - PRODUCTION, MEASURED IN BU',
            'WILD RICE - PRODUCTION, MEASURED IN CWT',
            'WHEAT - PRODUCTION, MEASURED IN BU',
            ]
        usda_to_wfn_path = 'usda_to_wfn.csv'
        states_ignore = ['ALASKA','HAWAII']
        data = alldata(harvest_path,harvest_cols,yield_path,yield_cols,production_path,production_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,production_trim_list,codes_path,usda_to_wfn_path,states_ignore,year)
