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

    def __init__(self,harvest_path,irrigated_harvest_path,production_path,harvest_production_cols,storage_path,storage_cols,precipitation_path,codes_path,usda_to_wfn_path,states_ignore,year):
        """All 'path' inputs must be strings leading to harvest, 
	yield, and storage data file paths, respectively
	All 'cols' inputs must be lists of strings specifying
	which columns to import for each dataset"""

	# Read in dataset containing state grain harvest values
	self.harvest_data = pandas.read_csv(harvest_path,usecols=harvest_production_cols)
	self.harvest_data = self.harvest_data.loc[self.harvest_data['Program'] == 'CENSUS']
	del self.harvest_data['Program']
	self.harvest_data['Commodity'] = self.harvest_data['Data Item'].str.split(' -').str[0]
	del self.harvest_data['Data Item']
	# self.harvest_data[pandas.to_numeric(self.harvest_data['Value'], errors='coerce').notnull()]
	
        # Read in dataset containing state grain irrigated harvest values
	self.irrigated_harvest_data = pandas.read_csv(irrigated_harvest_path,usecols=harvest_production_cols)
	self.irrigated_harvest_data = self.irrigated_harvest_data.loc[self.irrigated_harvest_data['Program'] == 'CENSUS']
	del self.irrigated_harvest_data['Program']
	self.irrigated_harvest_data['Commodity'] = self.irrigated_harvest_data['Data Item'].str.split(' -').str[0]
	del self.irrigated_harvest_data['Data Item']
	# self.irrigated_harvest_data = self.irrigated_harvest_data[pandas.to_numeric(self.irrigated_harvest_data['Value'], errors='coerce').notnull()]

        # Read in dataset containing state grain production values
	self.production_data = pandas.read_csv(production_path,usecols=harvest_production_cols)
	self.production_data = self.production_data.loc[self.production_data['Program'] == 'CENSUS']
	del self.production_data['Program']
	self.production_data['Commodity'] = self.production_data['Data Item'].str.split(' -').str[0]
	del self.production_data['Data Item']
	# self.production_data = self.production_data[pandas.to_numeric(self.production_data['Value'], errors='coerce').notnull()]

	# Read in dataset containing state grain storage values
	self.storage_data = pandas.read_csv(storage_path,usecols=storage_cols)

        # Read in precipitation data
        self.precipitation_data = pandas.read_csv(precipitation_path)

	# Read in dataset containing all county codes
	self.county_codes = pandas.read_csv(codes_path)

	# Read in USDA to Water Footprint Network (WFN) commodity lookup table
	self.usda_to_wfn = pandas.read_csv(usda_to_wfn_path)

	# Read in year variable
	self.year = year

        # Manual cleaning unique to specific datasets
	
        # Generalize irrigated dataset t allow merging
	self.irrigated_harvest_data['Commodity'] = self.irrigated_harvest_data['Commodity'].str.replace(', IRRIGATED', '')

        # Remove summary county codes: 888 (District) and 999 (State)
	self.county_codes = self.county_codes[-self.county_codes['County ANSI'].isin(['888','999'])][:-1]
		
	# Remove empty rows (ie. no data in any columns) originated from reading in codes data from url
	self.county_codes = self.county_codes[pandas.notnull(self.county_codes['County ANSI'])]

	# Manually add two counties present in harvest data but not present in county_codes database
	self.county_codes = self.county_codes.append(pandas.Series({'State ANSI':46,'District ANSI':70,'County ANSI':102,'Name':'Oglala Lakota','History Flag':0}),ignore_index=True)
	self.county_codes = self.county_codes.append(pandas.Series({'State ANSI':56,'District ANSI':50,'County ANSI':31,'Name':'Platte','History Flag':0}),ignore_index=True)

        # Convert Values to String type
        self.storage_data['Value'] = self.storage_data['Value'].apply(str)

        # Call cleaning function
	self.harvest_data = self.clean_data(self.harvest_data,'Harvest_Acre')
	self.irrigated_harvest_data = self.clean_data(self.irrigated_harvest_data,'Irrigated_Harvest_Acre')
	self.production_data = self.clean_data(self.production_data,'Production_Bu')
	self.storage_data = self.clean_data(self.storage_data,'Storage_Bu')

	# Replace harvest 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.harvest_data['Harvest_Acre'] = pandas.to_numeric(self.harvest_data['Harvest_Acre'],errors='coerce')
	self.harvest_data.loc[self.harvest_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
	self.harvest_data['Harvest_Acre'] = self.harvest_data.groupby(['State ANSI','Commodity'])['Harvest_Acre'].transform('sum')
	self.harvest_data = self.harvest_data.drop_duplicates(subset=(['State ANSI','Commodity']))

	# Replace irrigated harvest 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.irrigated_harvest_data['Irrigated_Harvest_Acre'] = pandas.to_numeric(self.irrigated_harvest_data['Irrigated_Harvest_Acre'],errors='coerce')
	self.irrigated_harvest_data.loc[self.irrigated_harvest_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
	self.irrigated_harvest_data['Irrigated_Harvest_Acre'] = self.irrigated_harvest_data.groupby(['State ANSI','Commodity'])['Irrigated_Harvest_Acre'].transform('sum')
	self.irrigated_harvest_data = self.irrigated_harvest_data.drop_duplicates(subset=(['State ANSI','Commodity']))

        # Replace production 'WILD RICE' and 'SWEET RICE' with 'RICE' to simplify comparison with WF data in future
        self.production_data['Production_Bu'] = pandas.to_numeric(self.production_data['Production_Bu'],errors='coerce')
	self.production_data.loc[self.production_data['Commodity'] == 'WILD RICE','Commodity'] = 'RICE'
	self.production_data['Production_Bu'] = self.production_data.groupby(['State ANSI','Commodity'])['Production_Bu'].transform('sum')
	self.production_data = self.production_data.drop_duplicates(subset=(['State ANSI','Commodity']))

	# Convert Rice values to Bu from CWT (1 CWT ~ 2.22 Bu)
	# Conversion info: https://www.omicnet.com/reports/past/archives/ca/tbl-1.pdf
        self.production_data['Production_Bu'] = scipy.where(self.production_data['Commodity'] == 'RICE', self.production_data['Production_Bu'] * 2.22, self.production_data['Production_Bu'])

	# Convert Corn Silage production values to Bu from Tons (1 Ton ~ 8 Bu)
	# https://digitalcommons.unl.edu/cgi/viewcontent.cgi?referer=https://www.google.com/&httpsredir=1&article=1349&context=extensionhist
	# http://large.stanford.edu/publications/coal/references/docs/Morrison.pdf
	# https://fyi.uwex.edu/forage/files/2016/10/GrainYieldfromCornSilageII.pdf
	# http://cdp.wisc.edu/jenny/crop/estimating.pdf
        self.production_data['Production_Bu'] = scipy.where(self.production_data['Commodity'] == 'CORN, SILAGE', self.production_data['Production_Bu'] * 8, self.production_data['Production_Bu'])
        self.production_data['Production_Bu'] = scipy.where(self.production_data['Commodity'] == 'SORGHUM, SILAGE', self.production_data['Production_Bu'] * 8, self.production_data['Production_Bu'])

	# Read in commodities list
	self.commodities = sorted( self.harvest_data['Commodity'].unique() ) 

	### DO I NEED TO STRETCH THESE DATASETS??? ###

	# Fill data: add place-holders for all state-commodity pairs not currently represented
	self.harvest_data = self.fill_data(self.harvest_data,'filled_harvest_data_{0}.csv'.format(self.year))
	self.irrigated_harvest_data = self.fill_data(self.irrigated_harvest_data,'filled_irrigated_harvest_data_{0}.csv'.format(self.year))
	self.production_data = self.fill_data(self.production_data,'filled_production_data_{0}.csv'.format(self.year))

	# Calculate non-irrigated harvest area
	rainfed_harvest = self.harvest_data.merge(self.irrigated_harvest_data[['State ANSI','Commodity','Irrigated_Harvest_Acre']],on=['State ANSI','Commodity'])
	rainfed_harvest = rainfed_harvest.loc[:, ~rainfed_harvest.columns.duplicated()]
	rainfed_harvest['Rainfed_Harvest_Acre'] = rainfed_harvest['Harvest_Acre'] - rainfed_harvest['Irrigated_Harvest_Acre']
        # Convert negative rainfed harvest values to zero. This accounts for odd case where harvest is zero and irrigated harvest is positive. Otherwise, assume irrigated harvest is a subset of harvest, and take difference as rainfed harvest. 
        rainfed_harvest.loc[rainfed_harvest['Rainfed_Harvest_Acre'] < 0, 'Rainfed_Harvest_Acre'] = 0 
	rainfed_harvest['Commodity'] = rainfed_harvest['Commodity'] + ', RAINFED'
	rainfed_harvest.drop(['Harvest_Acre'], axis=1, inplace=True)
	rainfed_harvest.drop(['Irrigated_Harvest_Acre'], axis=1, inplace=True)
	rainfed_harvest.rename(columns={'Rainfed_Harvest_Acre':'Harvest_Acre'}, inplace=True)
	rainfed_harvest.to_csv('state_outputs/filled_rainfed_harvest_data_{0}.csv'.format(self.year),index=False)

	# Combine irrigated and non-irrigated harvest into one database
	self.irrigated_harvest_data['Commodity'] = self.irrigated_harvest_data['Commodity'] + ', IRRIGATED'
	self.irrigated_harvest_data.rename(columns={'Irrigated_Harvest_Acre':'Harvest_Acre'}, inplace=True)
	merged_harvest = pandas.concat([rainfed_harvest,self.irrigated_harvest_data])
	merged_harvest.sort_values(['State ANSI','Commodity'],inplace=True)
	merged_harvest['Harvest_Acre'] = merged_harvest['Harvest_Acre'].abs() # Convert two negative values to positive
	merged_harvest.to_csv('state_outputs/filled_merged_harvest_data_{0}.csv'.format(self.year),index=False)

	# Get fractional harvest distribution
	self.fractional_harvest = self.fraction(merged_harvest)
	self.fractional_harvest.to_csv('state_outputs/fractional_harvest_{0}.csv'.format(self.year), index=False)
	self.fractional_harvest_ir = self.fractional_harvest[self.fractional_harvest['Commodity'].str.contains(', IRRIGATED')]
	self.fractional_harvest_rf = self.fractional_harvest[~self.fractional_harvest['Commodity'].str.contains(', IRRIGATED')]
	self.fractional_harvest_ir.to_csv('state_outputs/fractional_harvest_ir_{0}.csv'.format(self.year), index=False)
	self.fractional_harvest_rf.to_csv('state_outputs/fractional_harvest_rf_{0}.csv'.format(self.year), index=False)

	# Retrieve CWU values
	self.cwu_data = self.get_cwu('cwu_data.csv')       

	# Create comprehensive database for all data
	summary_ir = self.summarize('ir','summary_data_ir_{0}.csv'.format(self.year))
	summary_ir.rename(columns={'Harvest_Acre':'Irrigated_Harvest_Acre','Percent_Harvest':'Irrigated_Percent_Harvest'}, inplace=True)
	summary_rf = self.summarize('rf','summary_data_rf_{0}.csv'.format(self.year))
	summary_rf.rename(columns={'Harvest_Acre':'Rainfed_Harvest_Acre','Percent_Harvest':'Rainfed_Percent_Harvest'}, inplace=True)
	summarydf = summary_ir.merge(summary_rf[['State ANSI','Commodity','Rainfed_Harvest_Acre','Rainfed_Percent_Harvest']],on=['State ANSI','Commodity'])

	summarydf.to_csv('state_outputs/summary_data_all_{0}.csv'.format(self.year),index=False)

        # Calculate VWS
        vws = self.calculate_vws(summarydf,'vws_data_{0}.csv'.format(self.year))

        # Calculate Capture Efficiency
        finaldf = self.calculate_capture_efficiency(vws,self.precipitation_data,'final_data_{0}.csv'.format(self.year))

        # Print Summary
        self.finalize(finaldf)

    ### CLEAN UP DATA ###
    def clean_data(self,dataset,value_rename):
        """ Cleans up datasets """
	
        # Remove Alaska and Hawaii
        dataset.drop(dataset[dataset['State'].isin(states_ignore)].index,inplace=True)

	# Remove 'other states' and leave blank
	dataset = dataset.loc[dataset['State'] != 'OTHER STATES']

        # Convert value columns to numeric by removing thousands' place comma
        # and converting all non-numeric, ie. ' (D)', to 'NaN'
        # Note that ' (D)' means data was 'Withheld to avoid disclosing data for individual operations'
	dataset = dataset[pandas.to_numeric(dataset['Value'].str.replace(',',''), errors='coerce').notnull()]
        #dataset[['Value']] = dataset[['Value']].apply(
     	#    lambda x: pandas.to_numeric(x.astype(str).str.replace(',',''),
	#    errors='coerce')
	#    )

        # Rename 'Value' column headers to have meaningful names
        dataset.rename(columns={'Value': value_rename},inplace=True) # Rename column header
        return dataset

    # Convert harvest values to state-wide fractional harvest
    # Note: This function removes any rows with '(D)' values. These are added in later as empty rows (because no data is available anyway)
    def fraction(self,dataset):

        # Collect percentage of all area harvested by commodity for each state pair
        dataset['Percent_Harvest'] = dataset['Harvest_Acre'] # initialize new column
        df = dataset.groupby(['State','State ANSI','Commodity','Harvest_Acre'])['Percent_Harvest'].sum() #sum
        finaldf = df.groupby(['State ANSI']).apply( #percent
            lambda x: 100 * x / float(x.sum())
	    )
	finaldf = finaldf.reset_index()
	return finaldf

    # Fill dataset with all potential pairs
    def fill_data(self,dataset,path):
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
	    indices = itertools.product(stateids,self.commodities)

	    # If storage, insert 'Commodity' column
	    if 'Commodity' not in dataset.columns:
	        dataset['Commodity'] = ''

	    # Create empty list and find column index for values
	    newrows = []
	    s_ix = dataset.columns.get_loc('State ANSI')
	    c_ix = dataset.columns.get_loc('Commodity')

	    # Iterate over all state-commodity pairs and add state-commodity as empty row if it does not exist
	    for s,c in indices:
                s = str(int(s)).zfill(2) # Convert numeric to string, ie. 1.0 --> 01
	        if not ((dataset['State ANSI'] == s) & (dataset['Commodity'] == c)).any():
	            temprow = [scipy.nan]*len(dataset.columns)
		    temprow[s_ix] = '{0:02g}'.format(int(s))
		    temprow[c_ix] = c
		    newrows.append(temprow)
            dfnew = dataset.append(pandas.DataFrame(newrows,columns=dataset.columns))
	    dfnew = dfnew.sort_values(['State ANSI','Commodity'],ascending=[True,True])
	    dfnew.fillna(value=0,inplace=True)
	    dfnew.to_csv(path,index=False)
            dfnew.iloc[:,-1] = pandas.to_numeric(dfnew.iloc[:,-1],errors='coerce')
	    return dfnew

    # Create CWU dataframe
    def get_cwu(self,path):
        path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading cwu_data file found at {0}'.format(path)
	    df = pandas.read_csv(path)
	    df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
	    return df
        else:
            print 'Creating new cwu_data file at {0}'.format(path)

            # Create list of (state_ansi,wfn_code,commodity) pairs to iterate over
            stateids = ['{0:02g}'.format(s) for s in sorted(self.county_codes['State ANSI'].unique())]
	    #commodities = set([i.split(',')[0] for i in self.production_data['Commodity'].unique()])
            commodities = self.production_data['Commodity'].unique()
	    indices = itertools.product(stateids,commodities)

	    # Select type of water to use for Crop Water Content (CWU) of commodities in each state
	    watertypes = ['bl','gn_ir','gn_rf'] # bl = blue; ir = irrigated green; rf = rainfed green
	
            # Read in CWU data
            def clean_cwu(cwu_path,cwu_cols):
                tempdf = pandas.read_csv(cwu_path,usecols=cwu_cols)
                tempdf = tempdf.apply(pandas.to_numeric, errors='coerce')
                tempdf['STATEFP'] = tempdf['STATEFP'].apply(lambda x: '{0:02g}'.format(x)) # fix statefp
                tempdf.rename(columns=lambda x: x.strip(),inplace=True) # remove spaces from column names
                wm = lambda x: scipy.average(x, weights=tempdf.loc[x.index,'ALAND']) # weighted mean func
                f = {'ALAND': 'sum', 'BARLEY': wm, 'BUCKWHEAT': wm, 'CORN, GRAIN': wm, 'CORN, SILAGE': wm, 'MILLET, PROSO': wm, 'OATS': wm, 'RICE': wm, 'RYE': wm, 'SORGHUM, GRAIN': wm, 'SORGHUM, SILAGE': wm, 'TRITICALE': wm, 'WHEAT': wm} # function for groupby aggregates
                tempdf = tempdf.groupby('STATEFP',as_index=False).agg(f)
                return tempdf

            cwu_cols = ['{0} '.format(c) for c in commodities]
            cwu_cols.append('STATEFP')
            cwu_cols.append('ALAND')

            cwu_bl = clean_cwu('cwu_data/marston_cwu_bl.csv',cwu_cols)
            cwu_gn_ir = clean_cwu('cwu_data/marston_cwu_gn_ir.csv',cwu_cols)
            cwu_gn_rf = clean_cwu('cwu_data/marston_cwu_gn_rf.csv',cwu_cols)

            cwu_dfs = [cwu_bl, cwu_gn_ir, cwu_gn_rf]

            # Add CWU data to dataframe
	    # Iterate over (State ANSI, WFN Code) pairs to retrieve CWU values from CWU csv files
	    newrows = []
	    for s,c in indices:
                # Iterate over water types
                cwu_list = [] # list of bl, gn_ir, and gn_rf
                for tempdf in cwu_dfs:
		    # Retrieve CWU average for state in question, and add to new column in dataframe
		    if ((len(tempdf[tempdf['STATEFP']==s]) == 0) or not (tempdf[tempdf['STATEFP']==s][c].values[0])): 
		        cwu_list.append( 'NaN' ) 
			aland = 'NaN'
		    else: 
		        cwu_list.append( tempdf[tempdf['STATEFP'] == s][c].values[0] ) # Mean CWU, state and commodity
			aland = tempdf[tempdf['STATEFP'] == s]['ALAND'].values[0] # ALAND in sq meters
                temprow = [s, c, cwu_list[0], cwu_list[1], cwu_list[2], aland]
		newrows.append(temprow)
                print s 

	    # Create dataframe from newrows data
	    cols = ['State ANSI','Commodity','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','ALAND_sqmeters']
	    dfnew = pandas.DataFrame(newrows,columns=cols)
	    dfnew.to_csv(path,index=False)
			
	return dfnew

    # Create summary dataframe with all data organized by State ANSI
    def summarize(self,harvest_type,path):
	path = 'state_outputs/{0}'.format(path)
	if os.path.isfile(path):
            print 'Loading summary_df file found at {0}'.format(path)
	    df = pandas.read_csv(path)
	    df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
	    return df
	else:
	    print 'Creating new summary_df file at {0}'.format(path)

	    if harvest_type == 'ir':
	        harvest_data = self.fractional_harvest_ir.copy()
		harvest_data = harvest_data.groupby(['State ANSI','Commodity','Harvest_Acre'],as_index=False)['Percent_Harvest'].mean() # removes duplicates from database by averaging together
		harvest_data['Commodity_Merger'] = harvest_data['Commodity'].str.replace(', IRRIGATED', '')
	    elif harvest_type == 'rf':
		harvest_data = self.fractional_harvest_rf.copy()
		harvest_data = harvest_data.groupby(['State ANSI','Commodity','Harvest_Acre'],as_index=False)['Percent_Harvest'].mean() # removes duplicates from database by averaging together
		harvest_data['Commodity_Merger'] = harvest_data['Commodity'].str.replace(', RAINFED', '')

	    # Take average of duplicates to remove them from database
	    production_data = self.production_data.groupby(['State ANSI','Commodity'],as_index=False)['Production_Bu'].mean()
	
            # Merge harvest_data and irrigated_harvest_data
	    production_data['Commodity_Merger'] = production_data['Commodity']
	    harvest_production_data = harvest_data.merge(production_data,on=['State ANSI','Commodity_Merger'])
            # Merge harvest_production_data with cwu_data
	    harvest_production_data['Commodity_Merger'] = harvest_production_data['Commodity_Merger']#.str.split(',').str[0]
	    self.cwu_data['Commodity_Merger'] = self.cwu_data['Commodity']
	    summarydf = harvest_production_data.merge(self.cwu_data,on=['State ANSI','Commodity_Merger'])

	    # Add storage data to dataframe
	    stateids = sorted(self.county_codes['State ANSI'].unique())
	    for s in stateids:
	        stor = self.storage_data[self.storage_data['State ANSI'] == s]['Storage_Bu'].values
		if len(stor) == 0: stor = 'NaN'
		summarydf.loc[summarydf['State ANSI']=='{0:02g}'.format(int(s)),'Storage_Bu'] = stor

	    summarydf.replace(r'\s+', '', regex=True,inplace=True)
	    summarydf.replace('', scipy.nan,inplace=True)
	    #summarydf.fillna(value=0,inplace=True)
	    summarydf.replace(0, scipy.nan,inplace=True)
	    del summarydf['Commodity']
	    del summarydf['Commodity_Merger']
	    del summarydf['Commodity_x']
	    summarydf.rename(columns={'Commodity_y':'Commodity'}, inplace=True)
	    summarydf.to_csv(path,index=False)

	return summarydf

    # Calculate VW of storage 
    def calculate_vws(self,df,path):
	path = 'state_outputs/{0}'.format(path)
	if os.path.isfile(path):
            print 'Loading final_df file found at {0}'.format(path)
	    df = pandas.read_csv(path)
	    df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            return df
	else: 
	    print 'Creating new vws file at {0}'.format(path)
            
            # Clean up database
	    df.fillna(value=0,inplace=True)
            df['Irrigated_Harvest_Acre'] = pandas.to_numeric(df['Irrigated_Harvest_Acre'],errors='coerce')
	    df['Irrigated_Percent_Harvest'] = pandas.to_numeric(df['Irrigated_Percent_Harvest'],errors='coerce')
	    df['Rainfed_Harvest_Acre'] = pandas.to_numeric(df['Rainfed_Harvest_Acre'],errors='coerce')
	    df['Rainfed_Percent_Harvest'] = pandas.to_numeric(df['Rainfed_Percent_Harvest'],errors='coerce')
	    df['Production_Bu'] = pandas.to_numeric(df['Production_Bu'],errors='coerce')
	    df['CWU_bl_m3ha']  = pandas.to_numeric(df['CWU_bl_m3ha'],errors='coerce')
	    df['CWU_gn_ir_m3ha'] = pandas.to_numeric(df['CWU_gn_ir_m3ha'],errors='coerce')
	    df['CWU_gn_rf_m3ha'] = pandas.to_numeric(df['CWU_gn_rf_m3ha'],errors='coerce')
	    df['Storage_Bu'] = pandas.to_numeric(df['Storage_Bu'],errors='coerce')

	    # Calculate yield
	    df['Yield_Bu_per_Acre'] = df['Production_Bu'] / ( df['Irrigated_Harvest_Acre'] + df['Rainfed_Harvest_Acre'] ) * 1. 
	    df[df['Yield_Bu_per_Acre'] == float('+inf')] = scipy.nan # replace infinity (when have production but no harvest data) with zero
            df['CWU_bl_and_gn_ir_m3ha'] = df['CWU_bl_m3ha'] + df['CWU_gn_ir_m3ha']

	    # Create VWS columns
	    df['VWS_ir_m3'] = df['Storage_Bu'] / df['Yield_Bu_per_Acre'] * df['CWU_bl_and_gn_ir_m3ha'] * df['Irrigated_Percent_Harvest'] / 100 * 0.405 # ha/acre
	    df['VWS_rf_m3'] = df['Storage_Bu'] / df['Yield_Bu_per_Acre'] * df['CWU_gn_rf_m3ha'] * df['Rainfed_Percent_Harvest'] / 100 * 0.405 # ha/acre

	    # Clean up infinitys
	    df[df['VWS_ir_m3'] == float('+inf')] = scipy.nan
	    df[df['VWS_rf_m3'] == float('+inf')] = scipy.nan

	    # Sum all VWS columns together
	    df['VWS_m3'] = df['VWS_ir_m3'] + df['VWS_rf_m3']

	    # Remove blanks and zeros
	    df.replace(r'\s+', scipy.nan, regex=True,inplace=True)
	    df.replace(0, scipy.nan,inplace=True)
	    df.dropna(how='all',inplace=True)
	    df.to_csv(path,index=False)
            return df

    # Calculate Capture Efficiency
    def calculate_capture_efficiency(self,df,pcp,path):
	path = 'state_outputs/{0}'.format(path)
        if os.path.isfile(path):
            print 'Loading final_df file found at {0}'.format(path)
            df = pandas.read_csv(path)
            df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
            return df
        else: 
            print 'Creating new final_df file at {0}'.format(path)

            # Rename precipitation column
            pcp['mean'] = pandas.to_numeric(pcp['mean'],errors='coerce')
            pcp['sum'] = pandas.to_numeric(pcp['sum'],errors='coerce')
            pcp['ALAND'] = pcp['ALAND']/1000000. #km conversion
            pcp.rename(columns={'STATEFP':'State ANSI','ALAND':'Land_Area_km2','mean':'Precipitation_mm','sum':'Precipitation_Total_mm'},inplace=True)
            pcp['Precipitation_Volume_km3'] = pcp['Precipitation_Total_mm']/1000000. * 16 # km2 per pixel # * pcp['Land_Area_km2']
            
            # Remove Alaska and Hawaii from precipitation data
            pcp.drop(pcp[pcp['NAME'].isin(states_ignore)].index,inplace=True)

	    pcp['State ANSI'] = pcp['State ANSI'].apply(lambda x: '{0:02g}'.format(x))

            finaldf = df.merge(pcp[['State ANSI','Land_Area_km2','Precipitation_mm','Precipitation_Volume_km3']],on=['State ANSI'])

            finaldf['Capture_Efficiency'] = 100. * finaldf['VWS_rf_m3'] / ( finaldf['Precipitation_Volume_km3'] * 1e9 )
            del finaldf['ALAND_sqmeters']
	    finaldf.replace(0, scipy.nan,inplace=True)
            finaldf.to_csv(path,index=False)
            return finaldf

    def finalize(self,df):
        # Mean +/- Std Dev
        f = {'Irrigated_Harvest_Acre':['sum'],'Rainfed_Harvest_Acre':['sum'],'Production_Bu':['sum'],'Yield_Bu_per_Acre':['mean'],'Storage_Bu':['mean'],'CWU_bl_m3ha':['mean'],'CWU_gn_ir_m3ha':['mean'],'CWU_gn_rf_m3ha':['mean'],'VWS_ir_m3':['sum'],'VWS_rf_m3':['sum'],'VWS_m3':['sum'],'Land_Area_km2':['mean'],'Precipitation_mm':['mean'],'Precipitation_Volume_km3':['mean'],'Capture_Efficiency':['sum']}
        df = df.groupby(['State ANSI'],as_index=False).agg(f)
        cols = ['Irrigated_Harvest_Acre','Rainfed_Harvest_Acre','Production_Bu','Yield_Bu_per_Acre','Storage_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','VWS_ir_m3','VWS_rf_m3','VWS_m3','Land_Area_km2','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency'] 
        df = df[cols]

        print 'Test... {0} Sum of Volumetric Precipitation (km3): {1}'.format(self.year, long(df['Precipitation_Volume_km3'].sum()))

        print u'{0} Mean \u00b1 Std Dev'.format(self.year)
        #print '{0} Irrigated Harvested Area (Acres):\t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Irrigated_Harvest_Acre'].mean()),long(df['Irrigated_Harvest_Acre'].std()))
        #print '{0} Rainfed Harvested Area (Acres):  \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Rainfed_Harvest_Acre'].mean()),long(df['Rainfed_Harvest_Acre'].std()))
        #print '{0} Production (Bu):                 \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Production_Bu'].mean()),long(df['Production_Bu'].std()))
        #print '{0} Yield (Bu/Acre):                 \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Yield_Bu_per_Acre'].mean()),long(df['Yield_Bu_per_Acre'].std()))
        #print '{0} Storage (Bu):                    \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Storage_Bu'].mean()),long(df['Storage_Bu'].std()))
        #print '{0} CWU, Blue (m3/ha):               \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_bl_m3ha'].mean()),long(df['CWU_bl_m3ha'].std()))
        #print '{0} CWU, Green, Irrigated (m3/ha):   \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_gn_ir_m3ha'].mean()),long(df['CWU_gn_ir_m3ha'].std()))
        #print '{0} CWU, Green, Rainfed (m3/ha):     \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_gn_rf_m3ha'].mean()),long(df['CWU_gn_rf_m3ha'].std()))
        #print '{0} Precipitation, Volume (km3):     \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Precipitation_Volume_km3'].mean()),long(df['Precipitation_Volume_km3'].std()))
        #print '{0} Capture Efficiency (%):          \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['Capture_Efficiency'].mean()),long(df['Capture_Efficiency'].std()))
        #print '{0} VWS, Irrigated (m3):             \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_ir_m3'].mean()),long(df['VWS_ir_m3'].std()))
        #print '{0} VWS, Rainfed (m3):               \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_rf_m3'].mean()),long(df['VWS_rf_m3'].std()))
        #print '{0} VWS, Total (m3):                 \t {1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_m3'].mean()),long(df['VWS_m3'].std()))

        print '{0} Irrigated Harvested Area (Acres):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['Irrigated_Harvest_Acre'].mean()),long(df['Irrigated_Harvest_Acre'].std()))
        print '{0} Rainfed Harvested Area (Acres):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['Rainfed_Harvest_Acre'].mean()),long(df['Rainfed_Harvest_Acre'].std()))
        print '{0} Production (Bu):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['Production_Bu'].mean()),long(df['Production_Bu'].std()))
        print '{0} Yield (Bu/Acre):{1:.2f} ({2:.2f})'.format(self.year,df['Yield_Bu_per_Acre'].mean()[0],df['Yield_Bu_per_Acre'].std()[0])
        print '{0} Storage (Bu):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['Storage_Bu'].mean()),long(df['Storage_Bu'].std()))
        print '{0} CWU, Blue (m3/ha):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_bl_m3ha'].mean()),long(df['CWU_bl_m3ha'].std()))
        print '{0} CWU, Green, Irrigated (m3/ha):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_gn_ir_m3ha'].mean()),long(df['CWU_gn_ir_m3ha'].std()))
        print '{0} CWU, Green, Rainfed (m3/ha):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['CWU_gn_rf_m3ha'].mean()),long(df['CWU_gn_rf_m3ha'].std()))
        print '{0} Precipitation, Volume (m3):{1:1.2e} ({2:1.2e})'.format(self.year,long((df['Precipitation_Volume_km3']*1.e9).mean()),long((df['Precipitation_Volume_km3']*1.e9).std()))
        print '{0} Capture Efficiency (%):{1:.2f} ({2:.2f})'.format(self.year,df['Capture_Efficiency'].mean()[0],df['Capture_Efficiency'].std()[0])
        print '{0} VWS, Irrigated (m3):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_ir_m3'].mean()),long(df['VWS_ir_m3'].std()))
        print '{0} VWS, Rainfed (m3):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_rf_m3'].mean()),long(df['VWS_rf_m3'].std()))
        print '{0} VWS, Total (m3):{1:1.2e} ({2:1.2e})'.format(self.year,long(df['VWS_m3'].mean()),long(df['VWS_m3'].std()))

if __name__ == '__main__':
    # Select year for analysis
    years_list = ['2002','2007','2012']

    # Iterate over all years and perform analysis
    for year in years_list:
        # All paths and column specifications for data class
	harvest_path = 'usda_nass_data/usda_state_harvest_all_{0}.csv'.format(year) # Census
	irrigation_harvest_path = 'usda_nass_data/usda_state_harvest_irrigated_{0}.csv'.format(year)
	production_path = 'usda_nass_data/usda_state_production_all_{0}.csv'.format(year)
	harvest_production_cols = ['Program','State','State ANSI','Commodity','Data Item','Value']
	storage_path = 'usda_nass_data/usda_state_storage_{0}.csv'.format(year) # Overall grain storage
	storage_cols = ['State','State ANSI','Value']
        precipitation_path = 'precipitation_data/{0}_state_precip.csv'.format(year)
	codes_path = 'usda_nass_data/county_codes.csv'
	usda_to_wfn_path = 'usda_to_wfn.csv'
	states_ignore = ['ALASKA','HAWAII']

	# Create outputs
	data = alldata(harvest_path,irrigation_harvest_path,production_path,harvest_production_cols,storage_path,storage_cols,precipitation_path,codes_path,usda_to_wfn_path,states_ignore,year)
