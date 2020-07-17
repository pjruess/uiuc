#oPaul J. Ruess
# University of Illinois at Urbana-Champaign
# Fall 2017
# Personal Research
# US Virtual Water Storage for Counties and States

import pandas
import scipy
import os
import itertools

### Initiate class to calculate virtual water of grain storage (VWS) in the US
class VWS:
    """ Class for calculating VWS for US Counties and States """

    def __init__(self, year, harv_path, prod_path, stor_path, precip_path, codes_path, bu_conv_path, harv_prod_cols, stor_cols, states_ignore, geo = 'STATE', by = 'State ANSI', wd = 'final_results'):
        """ 
        year: the year,
        harv_path: file directory location for harvest data, 
        prod_path: file directory location for production data, 
        stor_path: file directory location for storage data, 
        precip_path: file directory location for precipitation data,
        codes_path: file directory location for county and state codes, 
        usda_to_wfn_path: file directory location for cross-walk between USDA and WFN commodities,
        states_ignore: states to ignore in analysis
        geo: 'STATE' or 'COUNTY' to designate state or county-level analysis desired
        """
        
        # Initiate variables
        self.year = year
        self.geo = geo
        self.wd = wd
        self.by = by

        ### Read in Datasets ###

        # Collect storage data
        self.stor = self.read_usda_data(path=stor_path, cols=stor_cols)
        
        # Collect harvest data
        self.harv = self.read_usda_data(path=harv_path.format(self.year), cols=harv_prod_cols)

        # Collect harvest 2000 data
        self.harv2000 = pandas.read_csv('raw_data/harvest_2000.csv', usecols=harv_prod_cols)
        self.harv2000 = self.harv2000[ self.harv2000['Geo Level'] == self.geo ]
        self.harv2000.drop( ['Year', 'Geo Level'], axis = 1, inplace = True )

        # Production
        self.prod = self.read_usda_data(path=prod_path.format(self.year), cols=harv_prod_cols)

        # Crop Water Use (CWU)
        self.cwu = pandas.DataFrame()
        if self.geo == 'STATE':
            path = '{0}/cwu_state.csv'.format(self.wd)
            if os.path.isfile(path):
                self.cwu = pandas.read_csv(path)
            else:
                self.cwu = pandas.read_excel('raw_data/USA-high-resolution-water-footprint-database.xlsx', sheet_name = 'Table 1b. Crop (State)', skiprows = 3, usecols = 'A:J' )
                self.cwu.drop( ['State Name','State','Unnamed: 4'], axis = 1, inplace = True )
                self.cwu['Crop'] = self.cwu['Crop'].str.strip() # strip trailing spaces
                self.cwu.rename(columns={'State FIPS': 'State ANSI', 'Crop': 'Commodity', 'Irrigated Crops -Groundwater': 'Irrigated Crops - Groundwater'},inplace=True) # Rename column headers
                self.cwu.replace('-',scipy.nan,inplace=True)
                self.cwu.to_csv(path,index=False)
        if self.geo == 'COUNTY':
            path = '{0}/cwu_county.csv'.format(self.wd)
            if os.path.isfile(path):
                self.cwu = pandas.read_csv(path)
            else:
                self.cwu = pandas.read_excel('raw_data/USA-high-resolution-water-footprint-database.xlsx', sheet_name = 'Table 1a. Crop (County)', skiprows = 3, usecols = 'A:L' )
                self.cwu.drop( ['State Name','State','County Name','Unnamed: 6'], axis = 1, inplace = True )
                self.cwu['Crop'] = self.cwu['Crop'].str.strip() # strip trailing spaces
                self.cwu.rename(columns={'State FIPS': 'State ANSI', 'FIPS': 'GEOID', 'Crop': 'Commodity', 'Irrigated Crops -Groundwater': 'Irrigated Crops - Groundwater'},inplace=True) # Rename column headers
                self.cwu.replace('-',scipy.nan,inplace=True)
                self.cwu.to_csv(path,index=False)
        
        # Precipitation data
        new_pcp_path = pcp_path.format(self.year, self.geo.lower())
        self.pcp = pandas.read_csv( new_pcp_path )
        if self.geo == 'STATE':
            self.pcp.drop( ['NAME','sum'], axis = 1, inplace = True )
            self.pcp.rename(columns={'STATEFP': 'State ANSI', 'mean': 'Precipitation_mm', 'count': 'Precipitation_Pixel_Count'}, inplace=True)
        if self.geo == 'COUNTY':
            self.pcp.drop( ['STATEFP','COUNTYFP','NAME','sum'], axis = 1, inplace = True )
            self.pcp.rename(columns={'mean': 'Precipitation_mm', 'count': 'Precipitation_Pixel_Count'}, inplace=True) # Rename column headers

        # Production unit conversion data
        self.bu_conv = pandas.read_csv( bu_conv_path , usecols = ['Commodity','Conversion'] )

        # Read in county codes
        self.codes = pandas.read_csv(codes_path)
        self.codes = self.codes[self.codes['County ANSI'] != 0]

        ### Clean datasets ###

        # Storage
        if self.geo == 'STATE': 
            self.stor = self.stor[ (self.stor['Data Item'] == 'GRAIN STORAGE CAPACITY, OFF FARM - CAPACITY, MEASURED IN BU') & (self.stor['Program'] == 'SURVEY') ]
        elif self.geo == 'COUNTY': 
            self.stor = self.stor[ (self.stor['Data Item'] == 'GRAIN STORAGE CAPACITY, ON FARM - CAPACITY, MEASURED IN BU') & (self.stor['Program'] == 'CENSUS') ]
        self.stor.drop( ['Program', 'Period', 'Data Item'], axis = 1, inplace = True )

        # Harvest
        self.harv = self.harv.loc[self.harv['Program'] == 'CENSUS']
        self.harv['Commodity'] = self.harv['Data Item'].str.split(' -').str[0]
        self.harv.drop( ['Program', 'Data Item'], axis = 1, inplace = True )

        # Harvest 2000
        self.harv2000 = self.harv2000.loc[self.harv2000['Program'] == 'SURVEY']
        self.harv2000['Commodity'] = self.harv2000['Data Item'].str.split(' -').str[0]
        self.harv2000.drop( ['Program', 'Data Item'], axis = 1, inplace = True )

        # Production
        self.prod = self.prod.loc[self.prod['Program'] == 'CENSUS']
        self.prod['Commodity'] = self.prod['Data Item'].str.split(' -').str[0]
        self.prod.drop( ['Program', 'Data Item'], axis = 1, inplace = True )

        # Clean datasets
        self.stor = self.clean_data( self.stor, 'Storage_Bu', states_ignore )
        self.harv = self.clean_data( self.harv, 'Harvest_Ac', states_ignore )
        self.harv2000 = self.clean_data( self.harv2000, 'Harvest_Ac', states_ignore )
        self.prod = self.clean_data( self.prod, 'Production_Bu', states_ignore )

        # Add IDs (State ANSI or GEOID)
        self.stor = self.add_id(self.stor)
        self.harv = self.add_id(self.harv)
        self.harv2000 = self.add_id(self.harv2000)
        self.prod = self.add_id(self.prod)
        self.cwu = self.add_id(self.cwu)
        self.codes = self.add_id(self.codes)
        if self.geo == 'STATE': 
            self.cwu = self.format_stateid(self.cwu)
            self.pcp = self.format_stateid(self.pcp)
        elif self.geo == 'COUNTY': 
            self.cwu = self.format_geoid(self.cwu)
            self.pcp = self.format_geoid(self.pcp)

        ### Convert all production values to Bushels ###
        self.prod = pandas.merge( self.prod, self.bu_conv, on = 'Commodity', how = 'outer' )
        if 'State ANSI' in self.prod.columns: self.prod = self.prod.sort_values(['State ANSI','Commodity'])
        if 'GEOID' in self.prod.columns: self.prod = self.prod.sort_values(['GEOID','Commodity'])
        self.prod['Production_Bu'] = self.prod['Production_Bu'] * self.prod['Conversion'].fillna(1)
        self.prod.drop( 'Conversion', axis = 1, inplace = True )

        ### Add Production Sum Column
        #self.prod['Production_Sum_Bu'] = self.prod['Production_Bu'].groupby(self.prod[by]).transform('sum')

        ### Calculate Rainfed harvest (total minus irrigated) ###
        self.harv['Water Type'] = scipy.where( self.harv['Commodity'].str.split(', ').str[-1] == 'IRRIGATED', 'IRRIGATED', 'TOTAL' ) # create Water Type column with IRRIGATED or TOTAL 
        self.harv['Commodity'] = self.harv['Commodity'].apply( lambda x: x if x.split(', ')[-1] != 'IRRIGATED' else (', ').join( x.split(', ')[:-1]) ) # remove 'IRRIGATED' in 'Commodity' column

        self.harv.rename(columns={'Harvest_Ac': 'Harvest_Ac_Old'},inplace=True) # change header names

        self.harv['Harvest_Ac_Rainfed'] = self.harv['Harvest_Ac_Old'].diff(-1).mul(self.harv['Water Type'].shift(-1) == 'IRRIGATED').replace(0,scipy.nan) # calculate rainfed harvest as total minus irrigated

        # Check for negative harvest values
        neg_harv = self.harv[(self.harv[['Harvest_Ac_Rainfed']] < 0).all(1)]['Harvest_Ac_Rainfed']
        if len(neg_harv) > 0:
            print '{0} negative harvest values'.format( len(neg_harv) )

        # Remove negative harvest from total minus irrigated calculation
        self.harv['Harvest_Ac_Rainfed'] = self.harv['Harvest_Ac_Rainfed'].abs()

        self.harv['Harvest_Ac'] = scipy.where( self.harv['Harvest_Ac_Rainfed'].isnull(), self.harv['Harvest_Ac_Old'], self.harv['Harvest_Ac_Rainfed'] ) # create 'Harvest_Ac' column summarizing both types
        self.harv['Water Type'] = scipy.where( self.harv['Water Type'] == 'TOTAL', 'RAINFED', 'IRRIGATED' ) # change Water Type TOTAL to RAINFED 
        self.harv.drop( ['Harvest_Ac_Old','Harvest_Ac_Rainfed'], axis = 1, inplace = True )

        # Calculate fractional harvest
        self.harv = self.harvest_fraction( self.harv, self.by )

        ### FOR YEAR 2000 DATA: Calculate Rainfed harvest (total minus irrigated) ###
        self.harv2000['Water Type'] = scipy.where( self.harv2000['Commodity'].str.split(', ').str[-1] == 'IRRIGATED', 'IRRIGATED', 'TOTAL' ) # create Water Type column with IRRIGATED or TOTAL 
        self.harv2000['Commodity'] = self.harv2000['Commodity'].apply( lambda x: x if x.split(', ')[-1] != 'IRRIGATED' else (', ').join( x.split(', ')[:-1]) ) # remove 'IRRIGATED' in 'Commodity' column

        self.harv2000.rename(columns={'Harvest_Ac': 'Harvest_Ac_Old'},inplace=True) # change header names

        self.harv2000['Harvest_Ac_Rainfed'] = self.harv2000['Harvest_Ac_Old'].diff(-1).mul(self.harv2000['Water Type'].shift(-1) == 'IRRIGATED').replace(0,scipy.nan) # calculate rainfed harvest as total minus irrigated

        # Check for negative harvest values
        neg_harv = self.harv2000[(self.harv2000[['Harvest_Ac_Rainfed']] < 0).all(1)]['Harvest_Ac_Rainfed']
        if len(neg_harv) > 0:
            print '{0} negative harvest values'.format( len(neg_harv) )

        # Remove negative harvest from total minus irrigated calculation
        self.harv2000['Harvest_Ac_Rainfed'] = self.harv2000['Harvest_Ac_Rainfed'].abs()

        self.harv2000['Harvest_Ac'] = scipy.where( self.harv2000['Harvest_Ac_Rainfed'].isnull(), self.harv2000['Harvest_Ac_Old'], self.harv2000['Harvest_Ac_Rainfed'] ) # create 'Harvest_Ac' column summarizing both types
        self.harv2000['Water Type'] = scipy.where( self.harv2000['Water Type'] == 'TOTAL', 'RAINFED', 'IRRIGATED' ) # change Water Type TOTAL to RAINFED 
        self.harv2000.drop( ['Harvest_Ac_Old','Harvest_Ac_Rainfed'], axis = 1, inplace = True )

        # Rename Harv2000 column headers to differentiate from Harv in current year
        self.harv2000.rename(columns={'Harvest_Ac': 'Harvest_Ac_2000'},inplace=True) # Rename column header
        
        ### Merge datasets ###
        self.merged_usda = self.merge_data( self.stor, self.harv, self.harv2000, self.prod , self.by )
        print self.merged_usda.head()
        1/0

        # Disaggregate Production to rainfed & irrigated
        self.merged_usda = self.production_split(self.merged_usda)
    
        # Calculate yield
        #self.merged_usda['Yield_Bu_per_Acre'] = self.merged_usda['Production_Bu'] / self.merged_usda['Harvest_Ac'] * 1.
        #self.merged_usda[self.merged_usda['Yield_Bu_per_Acre'] == float('+inf')] = scipy.nan # replace infinity (when have production but no harvest data) with zero

        # Merge CWU with other data
        self.merged_cwu = self.get_cwu( self.merged_usda, self.cwu, self.by )

        # Add in Precipitation
        self.merged = self.get_pcp( self.merged_cwu, self.pcp, self.by )
        
        # Calculate VWS
        self.vws = self.calc_vws(self.merged)

        # Calculate Capture Efficiency
        self.cap_eff = self.calc_capeff(self.vws)

        # Calculate Yield
        self.yld = self.calc_yield(self.cap_eff)

        # Split Irrigated and Rainfed Harvest Data
        self.final = self.split_harvest(self.yld)

        # Remove non-grain commodities
        self.final.dropna(subset=['Storage_Bu'],inplace=True)

        # Summarize Results
        self.agg = self.aggregate(self.final)

        # Write results to CSV
        final_path = '{0}/final_{1}_{2}.csv'.format( self.wd, self.geo.lower(), self.year )
        self.final['Commodity'] = self.final['Commodity'].str.replace(' ','')
        self.final.to_csv( final_path, index = False )

    # Read in USDA data
    def read_usda_data(self, path, cols):
        item = path.split('/')[1].split('_')[0].split('.')[0]
        new_path = '{0}/{1}_{2}_{3}.csv'.format(self.wd, item, self.geo.lower(), self.year)
        df = pandas.DataFrame()
        if os.path.isfile(new_path):
            df = pandas.read_csv(new_path)
        else: 
            df = pandas.read_csv(path, usecols=cols)
            df = df[ (df['Year'] == int(self.year)) & (df['Geo Level'] == self.geo) ]
            df.drop( ['Year', 'Geo Level'], axis = 1, inplace = True )
            df.to_csv(new_path, index=False)
        return df

    # Clean datasets
    def clean_data(self, df, value_rename, states_ignore):
        """ Cleans up datasets """
        
        # Rename 'Value' column headers to have meaningful names
        df.rename(columns={'Value': value_rename},inplace=True) # Rename column header

        # Remove Alaska and Hawaii
        df.drop(df[df['State ANSI'].isin(states_ignore)].index,inplace=True)

        # Convert value columns to numeric by removing thousands' place comma
        # and converting all non-numeric, ie. ' (D)', to 'NaN'
        # Note that ' (D)' means data was 'Withheld to avoid disclosing data for individual operations'
        df[[value_rename]] = df[[value_rename]].apply(
            lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
                errors='coerce')
            )
        return df

    def add_id(self, df):
        df = self.format_stateid(df)
        if self.geo == 'COUNTY': 
            df = self.format_geoid(df)
            if 'State ANSI' in df.columns: df.drop( 'State ANSI', axis = 1, inplace = True)
        if 'County ANSI' in df.columns: df.drop( 'County ANSI', axis = 1, inplace = True)
        return df
    
    def format_stateid(self, df):
        # Format State ANSI
        if df['State ANSI'].dtype != scipy.float64: df['State ANSI'] = df['State ANSI'].astype(scipy.float64)
        df['State ANSI'] = df['State ANSI'].apply( lambda x: '{0:02g}'.format(x) )
        return df

    def format_geoid(self, df):
        # Create GEOID
        if 'GEOID' in df.columns: 
            if df['GEOID'].dtype != scipy.float64: df['GEOID'] = df['GEOID'].astype(scipy.float64)
            df['GEOID'] = df['GEOID'].apply( lambda x: '{0:05g}'.format(x) )
        else:
            df['County ANSI'] = df['County ANSI'].apply( lambda x: '{0:03g}'.format(x) )
            df['GEOID'] = df['State ANSI'] + df['County ANSI']
        return df

    # Convert harvest values to county-wide fractional harvest
    def harvest_fraction(self,df,by):
        df['Percent_Harvest'] = df['Harvest_Ac'] # initialize new column
        df = df.groupby([by,'Commodity','Water Type','Harvest_Ac'])['Percent_Harvest'].sum()
        df = df.groupby([by]).apply( lambda x: 100 * x / float(x.sum()) ) # percent calculation
        df = df.reset_index()
        return df

    def production_split(self,df):
        # Split production data into rainfed and irrigated components
        df['Production_Bu_Rainfed'] = (df['Production_Bu'] * df['Harvest_Ac']  / ( df['Harvest_Ac'].shift(1) + df['Harvest_Ac'] ) * 1.).mul( (df['Water Type'] == 'RAINFED') & (df['Water Type'].shift(1) == 'IRRIGATED') ) 
        df['Production_Bu_Irrigated'] = (df['Production_Bu'] * df['Harvest_Ac']  / ( df['Harvest_Ac'].shift(-1) + df['Harvest_Ac'] ) * 1.).mul( (df['Water Type'].shift(-1) == 'RAINFED') & (df['Water Type'] == 'IRRIGATED') )
        df['Production_Bu_Unspecified'] = scipy.where( (df['Production_Bu_Rainfed'].fillna(0) == 0) & (df['Production_Bu_Irrigated'].fillna(0) == 0), df['Production_Bu'], scipy.nan )
        df['Production_Bu'] = df['Production_Bu_Rainfed'].fillna(0) + df['Production_Bu_Irrigated'].fillna(0) + df['Production_Bu_Unspecified'].fillna(0) 
        df['Production_Bu'].replace(0,scipy.nan,inplace=True)
        df.drop(['Production_Bu_Rainfed','Production_Bu_Irrigated','Production_Bu_Unspecified'], axis = 1, inplace = True)
        return df

    def merge_data(self, stor, harv, harv2000, prod, by):
        df = pandas.merge(stor, harv, on = by, how = 'outer')
        print df.shape
        df = pandas.merge(df, harv2000, on = [by,'Commodity'], how = 'outer')
        print df.shape
        df = pandas.merge(df, prod, on = [by,'Commodity'], how = 'outer')
        print df.shape
        df = df.sort_values( [by, 'Commodity'] )

        return df

    def get_cwu(self, df, cwu, by):

        # Change indices to join dataframes
        df.set_index([by,'Commodity'], inplace=True)
        cwu.set_index([by,'Commodity'],inplace=True)

        # Clean cwu dataset
        cwu.rename(columns={'Rainfed Crops - Green': 'CWU_gn_m3yr'},inplace=True) # Rename column header
        cwu['CWU_bl_m3yr'] = cwu['Irrigated Crops - Green'] + cwu['Irrigated Crops - Blue']
        cwu['CWU_m3yr'] = cwu['CWU_bl_m3yr'] + cwu['CWU_gn_m3yr']
        cwu.drop(['Irrigated Crops - Green','Irrigated Crops - Blue','Irrigated Crops - Groundwater','Irrigated Crops - Surface Water'], axis = 1, inplace = True)

        # Collect mean (stdev) of CWU before filtering regions
        g = cwu.groupby(self.by, as_index=False).agg({'CWU_m3yr':['mean'],'CWU_bl_m3yr':['mean'],'CWU_gn_m3yr':['mean']})
        self.cwu_sum, self.cwu_mean, self.cwu_std = ( float(g['CWU_m3yr'].sum()), float(g['CWU_m3yr'].mean()), float(g['CWU_m3yr'].std()) )
        self.cwu_bl_sum, self.cwu_bl_mean, self.cwu_bl_std = ( float(g['CWU_bl_m3yr'].sum()), float(g['CWU_bl_m3yr'].mean()), float(g['CWU_bl_m3yr'].std()) )
        self.cwu_gn_sum, self.cwu_gn_mean, self.cwu_gn_std = ( float(g['CWU_gn_m3yr'].sum()), float(g['CWU_gn_m3yr'].mean()), float(g['CWU_gn_m3yr'].std()) )

        # Join dataframes
        finaldf = df.join(cwu, how='outer')

        # Remove rows with no storage data
        #finaldf = finaldf[ scipy.isfinite( finaldf['Storage_Bu'] ) ]

        finaldf.reset_index(inplace=True)

        # Calculate CWU total 
        #coms = ['BARLEY','CORN,GRAIN','CORN,SILAGE','OATS','PEAS,DRYEDIBLE','RYE','SORGHUM,GRAIN','SORGHUM,SILAGE','SOYBEANS','SUNFLOWER','WHEAT','SAFFLOWER','CANOLA','MUSTARD,SEED','FLAXSEED','LENTILS','PEAS,AUSTRIANWINTER','RAPESEED']
        #tempdf = finaldf[finaldf['Commodity'].isin(coms)]
        #tempdf.dropna(subset=['CWU_m3yr'],inplace=True)
        #tempdf = tempdf.groupby([by,'Commodity'],as_index=False)['CWU_m3yr'].mean()
        #print 'Total CWU: ', tempdf['CWU_m3yr'].sum()/1.e9

        return finaldf

    def get_pcp(self, df, pcp, by):
        # Merge precipitation data with remaining data
        df = pandas.merge(df, pcp, on = by)

        # Rename land area column
        #df.rename(columns={'ALAND': 'Land_Area_km2'},inplace=True)
        df['Land_Area_km2'] = df['ALAND']/1.e6
        df.drop(['ALAND'],axis=1,inplace=True)

        # Calculate precipitation volume
        df[['Precipitation_mm','Precipitation_Pixel_Count']] = df[['Precipitation_mm','Precipitation_Pixel_Count']].apply(pandas.to_numeric,errors='coerce')

        df['Precipitation_Volume_km3'] = df['Precipitation_mm']/1.e6 * df['Harvest_Ac']*0.0040468564224
        #df['OLD_Precipitation_Total_km3'] = df['Precipitation_mm']/1.e6 * df['Precipitation_Pixel_Count'] * 16 # km2 per pixel
        #df['OLD_Precipitation_Volume_km3'] = df['OLD_Precipitation_Total_km3'] * df['Harvest_Ac'] * 0.0040468564224 / df['Land_Area_km2'] # 0.0040468564224 = km2/Ac
        
        #print df[(df['Harvest_Ac'] > 0) & (df['State ANSI'] == '17')]

        # Collect mean (stdev) of pcp before filtering regions
        self.pcp_sum,self.pcp_mean,self.pcp_std = ( float(df['Precipitation_mm'].sum()), float(df['Precipitation_mm'].mean()), float(df['Precipitation_mm'].std()) )
        self.pcp_vol_sum,self.pcp_vol_mean,self.pcp_vol_std = ( float((df['Precipitation_Volume_km3']*1.e9).sum()), float((df['Precipitation_Volume_km3']*1.e9).mean()), float((df['Precipitation_Volume_km3']*1.e9).std()) )

        return df

    def calc_vws(self, df):
        # Calculate irrigated and rainfed VWS
        df['VWS_ir_m3'] = ( df['Storage_Bu'] / df['Production_Bu'] * df['CWU_bl_m3yr'] * df['Percent_Harvest'] / 100 ).mul( df['Water Type'] == 'IRRIGATED' )
        df['VWS_rf_m3'] = ( df['Storage_Bu'] / df['Production_Bu'] * df['CWU_gn_m3yr'] * df['Percent_Harvest'] / 100 ).mul( df['Water Type'] == 'RAINFED' )

        # Sum all VWS columns together
        df.replace(scipy.nan,0,inplace=True)
        df['VWS_m3'] = df['VWS_ir_m3'] + df['VWS_rf_m3']

        # Remove inf and zeros
        df.replace(float('+inf'),scipy.nan,inplace=True)
        df.replace(0,scipy.nan,inplace=True)

        # Remove rows with no calculated VWS
        #df.dropna(subset=['VWS_m3'],inplace=True)
        #df = df[pandas.notna(df['VWS_m3'])]

        return df

    def calc_yield(self,df):
        df['Yield_Bu_per_Ac'] = df['Production_Bu'] / df['Harvest_Ac'] * 1.
        return df

    # Calculate Capture Efficiency
    def calc_capeff(self,df):

        #df = df.groupby([by],as_index=False).agg({'CWU_gn_m3yr':'sum','Harvest_Ac':'sum','Precipitation_mm':'mean','Precipitation_Volume_km3':'sum','VWS_rf_m3':'sum'})
        df['Capture_Efficiency'] = 100.* df['VWS_rf_m3'] / ( df['Precipitation_Volume_km3'] * 1.e9 ).mul(~df['VWS_rf_m3'].isnull())

        #df['CapEff_LN'] = scipy.log(df.Capture_Efficiency)

        #df.to_csv('new_capeff_{0}_test.csv'.format(by),index=False)

        return df

    def split_harvest(self,df):
        df['Harvest_Ac_rf'] = scipy.where( df['Water Type'] == 'RAINFED', df['Harvest_Ac'], scipy.nan )
        df['Harvest_Ac_ir'] = scipy.where( df['Water Type'] == 'IRRIGATED', df['Harvest_Ac'], scipy.nan )
        return df

    def aggregate(self,df):
        # Mean +/- Std Dev
        f = {'Harvest_Ac':['sum'],'Harvest_Ac_rf':['sum'],'Harvest_Ac_ir':['sum'],'Production_Bu':['sum'],'Storage_Bu':['mean'],'CWU_bl_m3yr':['sum'],'CWU_gn_m3yr':['sum'],'VWS_ir_m3':['sum'],'VWS_rf_m3':['sum'],'VWS_m3':['sum'],'Land_Area_km2':['mean'],'Precipitation_mm':['mean'],'Precipitation_Volume_km3':['sum'],'Capture_Efficiency':['sum']}
        df = df.groupby(self.by,as_index=False).agg(f)
        
        #if self.by == 'GEOID':
        #    df.columns = df.columns.droplevel(1)
        #    f2 = {'Harvest_Ac':['sum'],'Harvest_Ac_rf':['sum'],'Harvest_Ac_ir':['sum'],'Production_Bu':['sum'],'Storage_Bu':['sum'],'CWU_bl_m3yr':['sum'],'CWU_gn_m3yr':['sum'],'VWS_ir_m3':['sum'],'VWS_rf_m3':['sum'],'VWS_m3':['sum'],'Land_Area_km2':['mean'],'Precipitation_mm':['mean'],'Precipitation_Volume_km3':['sum'],'Capture_Efficiency':['sum']}
        #    df['State.ANSI'] = df['GEOID'].str[:2]
        #    df = df.groupby('State.ANSI',as_index=False).agg(f2)

        # Clean up df
        cols = ['Harvest_Ac','Harvest_Ac_rf','Harvest_Ac_ir','Production_Bu','Storage_Bu','CWU_bl_m3yr','CWU_gn_m3yr','VWS_ir_m3','VWS_rf_m3','VWS_m3','Land_Area_km2','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency'] 
        df = df[cols]

        # Calculate Yield for Aggregated Data
        df = self.calc_yield(df)

        # Calculate results
        self.harv_sum, self.harv_mean, self.harv_std = ( float(df['Harvest_Ac'].sum()), float(df['Harvest_Ac'].mean()), float(df['Harvest_Ac'].std()) )
        self.harv_ir_sum, self.harv_ir_mean, self.harv_ir_std = ( float(df['Harvest_Ac_ir'].sum()), float(df['Harvest_Ac_ir'].mean()), float(df['Harvest_Ac_ir'].std()) )
        self.harv_rf_sum, self.harv_rf_mean, self.harv_rf_std = ( float(df['Harvest_Ac_rf'].sum()), float(df['Harvest_Ac_rf'].mean()), float(df['Harvest_Ac_rf'].std()) )
        self.prod_sum, self.prod_mean, self.prod_std = ( float(df['Production_Bu'].sum()), float(df['Production_Bu'].mean()), float(df['Production_Bu'].std()) )
        self.yield_sum, self.yield_mean, self.yield_std = ( float(df['Yield_Bu_per_Ac'].sum()), float(df['Yield_Bu_per_Ac'].mean()), float(df['Yield_Bu_per_Ac'].std()) )
        self.stor_sum, self.stor_mean, self.stor_std = ( float(df['Storage_Bu'].sum()), float(df['Storage_Bu'].mean()), float(df['Storage_Bu'].std()) )
        self.capeff_sum, self.capeff_mean, self.capeff_std = ( float(df['Capture_Efficiency'].sum()), float(df['Capture_Efficiency'].mean()), float(df['Capture_Efficiency'].std()) )
        self.vws_sum, self.vws_mean, self.vws_std = ( float(df['VWS_m3'].sum()), float(df['VWS_m3'].mean()), float(df['VWS_m3'].std()) )
        self.vws_ir_sum, self.vws_ir_mean, self.vws_ir_std = ( float(df['VWS_ir_m3'].sum()), float(df['VWS_ir_m3'].mean()), float(df['VWS_ir_m3'].std()) )
        self.vws_rf_sum, self.vws_rf_mean, self.vws_rf_std = ( float(df['VWS_rf_m3'].sum()), float(df['VWS_rf_m3'].mean()), float(df['VWS_rf_m3'].std()) )
        return df

    def print_results(self):
        # Print results
        print 'Results for {0}, {1}: Mean (Std Dev) - Sum'.format(self.geo,self.year)
        print '{0} Total Volumetric Precipitation (km3):{1:.2f}'.format(self.year,self.pcp_vol_sum)
        print '{0} Harvest (Ac):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.harv_mean,self.harv_std,self.harv_sum)
        print '{0} Irrigated Harvest (Ac):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.harv_ir_mean,self.harv_ir_std,self.harv_ir_sum)
        print '{0} Rainfed Harvest (Ac):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.harv_rf_mean,self.harv_rf_std, self.harv_rf_sum)
        print '{0} Production (Bu):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.prod_mean,self.prod_std,self.prod_sum)
        print '{0} Yield (Bu/Ac):{1:.2f} ({2:.2f}) - {3:1.2e}'.format(self.year,self.yield_mean,self.yield_std,self.yield_sum)
        print '{0} Storage (Bu):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.stor_mean,self.stor_std,self.stor_sum)
        print '{0} CWU, Blue (m3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.cwu_bl_mean,self.cwu_bl_std,self.cwu_bl_sum)
        print '{0} CWU, Green (m3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.cwu_gn_mean,self.cwu_gn_std,self.cwu_gn_sum)
        print '{0} Precipitation, Volume (km3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.pcp_vol_mean,self.pcp_vol_std,self.pcp_vol_sum)
        print '{0} Capture Efficiency (%):{1:.2f} ({2:.2f}) - {3:1.2e}'.format(self.year,self.capeff_mean,self.capeff_std,self.capeff_sum)
        print '{0} VWS, Irrigated (m3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.vws_ir_mean,self.vws_ir_std,self.vws_ir_sum)
        print '{0} VWS, Rainfed (m3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.vws_rf_mean,self.vws_rf_std,self.vws_rf_sum)
        print '{0} VWS, Total (m3):{1:1.2e} ({2:1.2e}) - {3:1.2e}'.format(self.year,self.vws_mean,self.vws_std,self.vws_sum)
        print 'Total Blue VWS (km3): {0:.2f}'.format(self.vws_ir_sum/1.e9)
        print 'Total Green VWS (km3): {0:.2f}'.format(self.vws_rf_sum/1.e9)
        print 'Total VWS (km3): {0:.2f}'.format(self.vws_sum/1.e9)
        print '--- End of Report ---'

if __name__ == '__main__':
    # Select year for analysis
    years = ['2002','2007','2012']
    geographies = ['STATE','COUNTY']
    wd = 'final_results'

    # Initialize summary dataframe
    summary = pandas.DataFrame({'Variable':['Harvest_Ac','Harvest_Ac_ir','Harvest_Ac_rf','Production_Bu','Yield_Bu_per_Ac','Storage_Bu','CWU_m3yr','CWU_bl_m3yr','CWU_gn_m3yr','Precipitation_mm','Precipitation_Volume','Capture_Efficiency','VWS_m3','VWS_ir_m3','VWS_rf_m3']})

    # Iterate over all years and perform analysis
    for geo,year in itertools.product(geographies,years):
        # All paths and column specifications for data class
        harv_path = 'raw_data/harvest_all_{0}.csv'
        prod_path = 'raw_data/production_{0}.csv'
        harv_prod_cols = ['Program','Year','Geo Level','State ANSI','County ANSI','Data Item','Value']
        stor_path = 'raw_data/storage.csv'
        stor_cols = ['Program','Year','Period','Geo Level','State ANSI','County ANSI','Data Item','Value']
        pcp_path = 'raw_data/{0}_{1}_precip.csv'
        codes_path = 'raw_data/county_codes.csv'
        bu_conv_path = 'raw_data/other_to_bu.csv'
        states_ignore = []
        #states_ignore = ['02','15'] # 02 = ALASKA, 15 = HAWAII

        # Select identifier
        by = 'UNDEFINED'
        if geo == 'STATE': 
            by = 'State ANSI'
        elif geo == 'COUNTY':
            by = 'GEOID'

        # Create final path and check if dataframe already exists
        vws = VWS(year, harv_path, prod_path, stor_path, pcp_path, codes_path, bu_conv_path, harv_prod_cols, stor_cols, states_ignore, geo, by, wd)

        # Print results
        vws.print_results()

        # Append to summary dataframe
        summary['{0}_{1}_sum'.format(geo.lower(),year)] = [vws.harv_sum,vws.harv_ir_sum,vws.harv_rf_sum,vws.prod_sum,vws.yield_sum,vws.stor_sum,vws.cwu_sum,vws.cwu_bl_sum,vws.cwu_gn_sum,vws.pcp_sum,vws.pcp_vol_sum,vws.capeff_sum,vws.vws_sum,vws.vws_ir_sum,vws.vws_rf_sum]
        summary['{0}_{1}_mean'.format(geo.lower(),year)] = [vws.harv_mean,vws.harv_ir_mean,vws.harv_rf_mean,vws.prod_mean,vws.yield_mean,vws.stor_mean,vws.cwu_mean,vws.cwu_bl_mean,vws.cwu_gn_mean,vws.pcp_mean,vws.pcp_vol_mean,vws.capeff_mean,vws.vws_mean,vws.vws_ir_mean,vws.vws_rf_mean]
        summary['{0}_{1}_std'.format(geo.lower(),year)] = [vws.harv_std,vws.harv_ir_std,vws.harv_rf_std,vws.prod_std,vws.yield_std,vws.stor_std,vws.cwu_std,vws.cwu_bl_std,vws.cwu_gn_std,vws.pcp_std,vws.pcp_vol_std,vws.capeff_std,vws.vws_std,vws.vws_ir_std,vws.vws_rf_std]

    # Write summary to CSV
    summary.to_csv('{0}/summary.csv'.format(wd),index=False)
