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

    def __init__(self,harvest_path,harvest_cols,yield_path,yield_cols,production_path,production_cols,storage_path,storage_cols,harvest_trim_list,yield_trim_list,production_trim_list,codes_path,usda_to_wfn_path,states_ignore,year):
        """All 'path' inputs must be strings leading to harvest, 
        yield, and storage data file paths, respectively
        All 'cols' inputs must be lists of strings specifying
        which columns to import for each dataset"""

        # Read in dataset containing county grain harvest values
        self.harvest_data = pandas.read_csv(harvest_path,usecols=harvest_cols)
        self.harvest_data = self.harvest_data.loc[self.harvest_data['Program'] == 'CENSUS']
        del self.harvest_data['Program']

        # Read in dataset containing county grain yield values
        self.yield_data = pandas.read_csv(yield_path,usecols=yield_cols)

        # Read in dataset containing county grain production values
        self.production_data = pandas.read_csv(production_path,usecols=production_cols)
        self.production_data = self.production_data.loc[self.production_data['Program'] == 'CENSUS']
        del self.production_data['Program']

        # Read in dataset containing county grain storage values
        self.storage_data = pandas.read_csv(storage_path,usecols=storage_cols)

        # Read in dataset containing all county codes
        self.county_codes = pandas.read_csv(codes_path)

        # Read in USDA to Water Footprint Network (WFN) commodity lookup table
        self.usda_to_wfn = pandas.read_csv(usda_to_wfn_path)

        # Read in year variable
        self.year = year

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

        # Create GEOID column for datasets
        self.create_geoid(self.county_codes)
        self.create_geoid(self.harvest_data)
        self.create_geoid(self.yield_data)
        self.create_geoid(self.storage_data)
        self.create_geoid(self.production_data)

        # Replace harvest 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.harvest_data.loc[self.harvest_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
        self.harvest_data.loc[self.harvest_data['Commodity'] == 'SWEET RICE','Commodity'] = 'RICE'
        self.harvest_data['Harvest_Acre'] = self.harvest_data.groupby(['GEOID','Commodity'])['Harvest_Acre'].transform('sum')
        self.harvest_data = self.harvest_data.drop_duplicates(subset=(['GEOID','Commodity']))

        # Replace production 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        # print self.production_data[self.production_data['GEOID'] == '06101']
        self.production_data.loc[self.production_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
        self.production_data.loc[self.production_data['Commodity'] == 'SWEET RICE','Commodity'] = 'RICE'
        self.production_data['Production_Bu'] = self.production_data.groupby(['GEOID','Commodity'])['Production_Bu'].transform('sum')
        self.production_data = self.production_data.drop_duplicates(subset=(['GEOID','Commodity']))

        # Convert Rice production values to Bu from CWT (1 CWT ~ 2.22 Bu)
        # Conversion info: https://www.omicnet.com/reports/past/archives/ca/tbl-1.pdf
        self.production_data.loc[self.production_data['Commodity'] == 'RICE','Production_Bu'] = self.production_data.loc[self.production_data['Commodity'] == 'RICE','Production_Bu']*2.22
        # print self.production_data[self.production_data['GEOID'] == '06101']

        # Convert Rice yield values to Bu/Acre from Lb/Acre (45 Lbs ~ 1 Bu)
        # Conversion info: ftp://www.ilga.gov/JCAR/AdminCode/008/00800600ZZ9998bR.html 
        self.yield_data.loc[self.yield_data['Commodity'] == 'RICE','Yield_Bu_per_Acre'] = self.yield_data.loc[self.yield_data['Commodity'] == 'RICE','Yield_Bu_per_Acre']/45.
        # print self.production_data[self.production_data['GEOID'] == '06101']

        # # Trim to contain only commodities existing for all available data
        # self.harvest_data = self.harvest_data[self.harvest_data['Data Item'].isin(harvest_trim_list)]
        # self.yield_data = self.yield_data[self.yield_data['Data Item'].isin(yield_trim_list)]       
        # self.production_data = self.production_data[self.production_data['Data Item'].isin(production_trim_list)]

        # # Make sure harvest and yield data are available for the same commodities
        # if len(self.harvest_data['Commodity']) != len(self.yield_data['Commodity']):
        #     a_list = list( set(self.harvest_data['Commodity']) - set(self.yield_data['Commodity']) )
        #     b_list = list( set(self.yield_data['Commodity']) - set(self.harvest_data['Commodity']) )
        #     if len(a_list) > 0:
        #         for a in a_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
        #     if len(b_list) > 0:
        #         for b in b_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # # Make sure harvest and production data are available for the same commodities
        # if len(self.harvest_data['Commodity']) != len(self.production_data['Commodity']):
        #     a_list = list( set(self.harvest_data['Commodity']) - set(self.production_data['Commodity']) )
        #     b_list = list( set(self.production_data['Commodity']) - set(self.harvest_data['Commodity']) )
        #     if len(a_list) > 0:
        #         for a in a_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != a]
        #     if len(b_list) > 0:
        #         for b in b_list:
        #             self.harvest_data = self.harvest_data[self.harvest_data['Commodity'] != b]

        # Read in commodities list
        self.commodities = set( list(self.harvest_data['Commodity'].unique()) + list(self.yield_data['Commodity'].unique()) + list(self.production_data['Commodity'].unique()) )

        # Stretch yield and harvest data out
        self.harvest_data = self.stretch(self.harvest_data,'Harvest_Acre','stretched_harvest_data_{0}.csv'.format(self.year))
        self.yield_data = self.stretch(self.yield_data,'Yield_Bu_per_Acre','stretched_yield_data_{0}.csv'.format(self.year))
        self.production_data = self.stretch(self.production_data,'Production_Bu','stretched_production_data_{0}.csv'.format(self.year))

        # Get fractional harvest distribution
        self.harvest_data = self.harvest_fraction()

        # Add place-holders for all geoid-commodity pairs not currently represented
        self.harvest_data = self.fill_data(self.harvest_data,'harvest','filled_harvest_data_{0}.csv'.format(self.year))
        self.yield_data = self.fill_data(self.yield_data,'yield','filled_yield_data_{0}.csv'.format(self.year))
        self.production_data = self.fill_data(self.production_data,'production','filled_production_data_{0}.csv'.format(self.year))
        # self.storage_data = self.fill_data(self.storage_data,'storage','filled_storage_data_{0}.csv'.format(self.year))

        # Retrieve CWU values
        self.cwu_data = self.get_cwu('bl','cwu_data.csv') # bl = blue; gn = irrigated green; rf = rainfed green       
        
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
        path = 'county_outputs/{0}'.format(path)
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
        # print harvest[harvest['GEOID'] == '56015']
        return harvest

    # Fill dataset with all potential pairs
    def fill_data(self,dataset,datatype,path):
        path = 'county_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading fill_data file found at {0}'.format(path)
            dfnew = pandas.read_csv(path)
            dfnew['GEOID'] = dfnew['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return dfnew
        else:
            print 'Creating new fill_data file at {0}'.format(path)
            geoids = sorted(self.county_codes['GEOID'].unique())
            indices = itertools.product(geoids,self.commodities)

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
            dfnew.fillna(value=0,inplace=True)
            dfnew.to_csv(path,index=False)
            return dfnew

    # Create CWU dataframe
    def get_cwu(self,watertype,path):
        path = 'county_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading cwu_data file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['GEOID'] = df['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return df
        else:
            print 'Creating new cwu_data file at {0}'.format(path)
            print path
            # Create list of (geoid,wfn_code,commodity) pairs to iterate over
            geoids = sorted(self.county_codes['GEOID'].unique())
            # wfn_codes = []
            # for c in self.commodities:
            #     wfn = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
            #     wfn_codes.append(wfn)
            indices = itertools.product(geoids,self.commodities)
    
            # Select type of water to use for Virtual Water Content (CWU) of self.commodities in each country
            watertypes = ['bl','gn_ir','gn_rf'] # bl = blue; gn_ir = irrigated green; gn_rf = rainfed green
    
            # Add CWU data to dataframe
            # Iterate over (GEOID, WFN Code) pairs to retrieve CWU values from CWU csv files
            newrows = []
            for g,c in indices:
                w = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
                # print 'Adding GEOID {0} and Commodity {1}'.format(g,c)

                # Iterate over water types
                cwu_list = [] # list of bl, gn_ir, and gn_rf
                for wtype in watertypes:
                    f = 'cwu{0}_{1}'.format(w,wtype) # create correct file name
                    data_path = 'cwu_zonal_stats/county_outputs/' + f + '.csv'
                    # Read in temporary dataframe for particular filename (based on WFN code and watertype)
                    df = pandas.read_csv(data_path,converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOID
                    tempdf = df
                    # Retrieve CWU average for county in question, and add to new column in dataframe
                    if ((len(tempdf[tempdf['GEOID']==g]) == 0) or not (tempdf[tempdf['GEOID']==g]['mean'].values[0])): 
                        cwu_list.append( 'NaN' ) 
                        aland = 'NaN'
                    else: 
                        cwu_list.append( tempdf[tempdf['GEOID'] == g]['mean'].values[0] ) # Mean CWU of county & commodity
                        aland = tempdf[tempdf['GEOID'] == g]['ALAND'].values[0] # ALAND in square meters
                temprow = [g, c, cwu_list[0], cwu_list[1], cwu_list[2], aland]
                newrows.append(temprow)
                print f.split('_')[0]
                print temprow

            # Create dataframe from newrows data
            cols = ['GEOID','Commodity','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','ALAND_sqmeters']
            df = pandas.DataFrame(newrows,columns=cols)
            df.to_csv(path,index=False)
            
        return df

    # Create summary dataframe with all data organized by GEOID
    def summary_df(self,path):
        path = 'county_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading summary_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['GEOID'] = df['GEOID'].apply(lambda x: '{0:05g}'.format(x))
            return df
        else:
            print 'Creating new summary_df file at {0}'.format(path)

            # Take average of duplicates to remove them from database
            self.yield_data = self.yield_data.groupby(['GEOID','Commodity'],as_index=False)['Yield_Bu_per_Acre'].mean()
            self.production_data = self.production_data.groupby(['GEOID','Commodity'],as_index=False)['Production_Bu'].mean()
            self.harvest_data = self.harvest_data.groupby(['GEOID','Commodity','Harvest_Acre'],as_index=False)['Percent_Harvest'].mean()
    
            print '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
            print len(self.yield_data)
            print len(self.production_data)
            print len(self.harvest_data)

            # Merge harvest_data and yield_data
            harvest_yield_data = self.harvest_data.merge(self.yield_data,on=['GEOID','Commodity'])
            harvest_yield_production_data = harvest_yield_data.merge(self.production_data,on=['GEOID','Commodity'])
    
            print len(harvest_yield_data)
            print len(harvest_yield_production_data)

            # Merge harvest_yield_data with cwu_data
            summarydf = harvest_yield_production_data.merge(self.cwu_data,on=['GEOID','Commodity'])
            print len(summarydf)

            # Add storage data to dataframe
            geoids = sorted(self.county_codes['GEOID'].unique())
            for g in geoids:
                s = self.storage_data[self.storage_data['GEOID'] == g]['Storage_Bu'].values
                if len(s) == 0: s = 'NaN'
                summarydf.loc[summarydf['GEOID']==g,'Storage_Bu'] = s
    
            # # Create list of (geoid,wfn_code) pairs to iterate over
            # self.commodities = sorted(set(dataset['Commodity'].unique()))
            # wfn_codes = []
            # for c in self.commodities:
            #     wfn = self.usda_to_wfn[self.usda_to_wfn['usda'] == c]['wfn_code'].values[0]
            #     wfn_codes.append(wfn)
            # indices = itertools.product(geoids,wfn_codes,self.commodities)
    
            # # Select type of water to use for Virtual Water Content (CWU) of self.commodities in each country
            # watertype = 'bl' # bl = blue; gn = irrigated green; rf = rainfed green
    
            # # Add CWU data to dataframe
            # # Iterate over (GEOID, WFN Code) pairs to retrieve CWU values from CWU csv files
            # for g,w,c in indices:
            #     f = 'cwu{0}_{1}'.format(w,watertype) # create correct file name
            #     path = 'cwu_zonal_stats/output/' + f + '.csv'
            #     # Read in temporary dataframe for particular filename (based on WFN code and watertype)
            #     tempdf = pandas.read_csv(path,converters={'GEOID': lambda x: str(x)}) # Retains leading zeros in GEOIDs
            #     # Retrieve CWU average for county in question, and add to new column in dataframe
            #     if len(tempdf[tempdf['GEOID']==g]) == 0: cwu = 'NaN' 
            #     else: cwu = tempdf[tempdf['GEOID'] == g]['mean'].values[0] # Mean CWU of county and commodity
            #     summarydf.loc[ (summarydf['GEOID'] == g) & (summarydf['Commodity'] == c), 'CWU_m3ha' ] = cwu # Add CWU to df
            summarydf.replace(r'\s+', scipy.nan, regex=True,inplace=True)
            summarydf.replace(0, scipy.nan,inplace=True)
            summarydf.to_csv(path,index=False)

        return summarydf

    # Calculate VW of storage 
    def calculate_vws(self,dataset,path):
        path = 'county_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading final_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['GEOID'] = df['GEOID'].apply(lambda x: '{0:05g}'.format(x))
        else: 
            print 'Creating new final_df file at {0}'.format(path)
            df = dataset.replace(r'\s+', scipy.nan, regex=True)
            df['Harvest_Acre'] = pandas.to_numeric(df['Harvest_Acre'],errors='coerce')
            df['Percent_Harvest'] = pandas.to_numeric(df['Percent_Harvest'],errors='coerce')
            df['Yield_Bu_per_Acre'] = pandas.to_numeric(df['Yield_Bu_per_Acre'],errors='coerce')
            df['Production_Bu'] = pandas.to_numeric(df['Production_Bu'],errors='coerce')
            df['CWU_bl_m3ha']  = pandas.to_numeric(df['CWU_bl_m3ha'],errors='coerce')
            df['CWU_gn_ir_m3ha'] = pandas.to_numeric(df['CWU_gn_ir_m3ha'],errors='coerce')
            df['CWU_gn_rf_m3ha'] = pandas.to_numeric(df['CWU_gn_rf_m3ha'],errors='coerce')
            df['Storage_Bu'] = pandas.to_numeric(df['Storage_Bu'],errors='coerce')
            for wtype in ['bl','gn_ir','gn_rf']:
                df['VWS_{0}_m3_yield'.format(wtype)] = df['CWU_{0}_m3ha'.format(wtype)] * ( 1. / df['Yield_Bu_per_Acre'] ) * df['Storage_Bu'] * df['Percent_Harvest'] * 0.405 # ha/acre
                df['VWS_{0}_m3_prod'.format(wtype)] = df['CWU_{0}_m3ha'.format(wtype)] * ( df['Harvest_Acre'] / df['Production_Bu'] ) * df['Storage_Bu'] * df['Percent_Harvest'] * 0.405 # ha/acre

            df['VWS_m3_yield'] = df['VWS_bl_m3_yield'] + df['VWS_gn_ir_m3_yield'] + df['VWS_gn_rf_m3_yield']
            df['VWS_m3_prod'] = df['VWS_bl_m3_prod'] + df['VWS_gn_ir_m3_prod'] + df['VWS_gn_rf_m3_prod']
            df.replace(r'\s+', scipy.nan, regex=True,inplace=True)
            df.replace(0, scipy.nan,inplace=True)
            df.to_csv(path,index=False)

        vws = df['VWS_bl_m3_prod'].sum()
        print '{0} Summary...'.format(self.year)
        print '{0} Harvested Area (Acres):                       \t  {1:,}'.format(self.year,long(df['Harvest_Acre'].sum()))
        print '{0} Production (Bu):                              \t  {1:,}'.format(self.year,long(df['Production_Bu'].sum()))
        print '{0} Yield (Bu/Acre):                              \t  {1:,}'.format(self.year,long(df['Yield_Bu_per_Acre'].sum()))
        print '{0} Production/Harvest (Bu/Acre):                 \t  {1:,}'.format(self.year,long((df['Production_Bu']/df['Harvest_Acre']).sum()))
        print '{0} Storage (Bu):                                 \t  {1:,}'.format(self.year,long(df['Storage_Bu'].sum()))
        print '{0} CWU, Blue (m3):                               \t  {1:,}'.format(self.year,long(df['CWU_bl_m3ha'].sum()))
        print '{0} CWU, Green, Irrigated (m3):                   \t  {1:,}'.format(self.year,long(df['CWU_gn_ir_m3ha'].sum()))
        print '{0} CWU, Green, Rainfed (m3):                     \t  {1:,}'.format(self.year,long(df['CWU_gn_rf_m3ha'].sum()))
        print '{0} Yield-based VWS, Blue (m3):                   \t  {1:,}'.format(self.year,long(df['VWS_bl_m3_yield'].sum()))
        print '{0} Yield-based VWS, Green, Irrigated (m3):       \t  {1:,}'.format(self.year,long(df['VWS_gn_ir_m3_yield'].sum()))
        print '{0} Yield-based VWS, Green, Rainfed (m3):         \t  {1:,}'.format(self.year,long(df['VWS_gn_rf_m3_yield'].sum()))
        print '{0} Production-based VWS, Blue (m3):              \t  {1:,}'.format(self.year,long(df['VWS_bl_m3_prod'].sum()))
        print '{0} Production-based VWS, Green, Irrigated (m3):  \t  {1:,}'.format(self.year,long(df['VWS_gn_ir_m3_prod'].sum()))
        print '{0} Production-based VWS, Green, Rainfed (m3):    \t  {1:,}'.format(self.year,long(df['VWS_gn_rf_m3_prod'].sum()))
        return vws

if __name__ == '__main__':
    # Select year for analysis
    years_list = ['2002','2007','2012']

    # Iterate over all years and perform analysis
    for year in years_list:
        # All paths and column specifications for data class
        harvest_path = 'usda_nass_data/usda_county_harvest_{0}.csv'.format(year) # Census data is more complete than Survey data
        harvest_cols = ['Program','State','State ANSI','County','County ANSI','Ag District','Ag District Code','Commodity','Data Item','Value']
        yield_path = 'usda_nass_data/usda_county_yield_{0}.csv'.format(year)
        yield_cols = ['State','State ANSI','County','County ANSI','Ag District','Ag District Code','Commodity','Data Item','Value']
        production_path = 'usda_nass_data/usda_county_production_{0}.csv'.format(year)
        production_cols = ['Program','State','State ANSI','County','County ANSI','Ag District','Ag District Code','Commodity','Data Item','Value']
        storage_path = 'usda_nass_data/usda_county_storage_{0}.csv'.format(year) # Note: This data is overall grain storage; commodities not specified
        storage_cols = ['State','State ANSI','County','County ANSI','Ag District','Ag District Code','Value']
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
