import pandas

#shp = pandas.read_csv('data/faf_shp/attribute_table.csv',usecols=['CFS12GEOID','CFS12_NAME'])

#shp.drop_duplicates(inplace=True)

#shp.set_index('CFS12_NAME',inplace=True)

#shp.to_csv('test.csv')

# Read in CFS-to-FAF Lookup Table (LUT)
cfs_lut = pandas.read_csv('data/concordance_file.csv',usecols=['CFSAREANAM','SHORTNAME'])#,'SHORTNAME2','SHORTNAME3'])
cfs_lut.set_index('SHORTNAME',inplace=True)

# Read in FAF Flows
#flowdata = pandas.read_csv('data/faf_flows_2012.csv')
flowdata = pandas.read_csv('data/FAF_ALL_Transfers.csv') # includes international flows with domestic legs
flowdata = flowdata[flowdata['SCTG'].isin(range(1,8))]

# Read in SCTG_Name-to-SCTG_Number Lookup Table (LUT)
sctg_lut = pandas.read_csv('data/sctg_lookup.csv')
sctg_lut.set_index('SCTG2',inplace=True)

# Manually edit some CFS Names for consistency with FAF shapefile

### NAMING CONVENTION IS DIFFERENT. LOOK INTO THIS. ###

cfs_lut[cfs_lut['CFSAREANAM'] == 'Alaska'] = 'Remainder of Alaska'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Arkansas'] = 'Remainder of Arkansas'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Idaho'] = 'Remainder of Idaho'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Iowa'] = 'Remainder of Iowa'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Maine'] = 'Remainder of Maine'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Mississippi'] = 'Remainder of Mississippi'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Montana'] = 'Remainder of Montana'
cfs_lut[cfs_lut['CFSAREANAM'] == 'New Mexico'] = 'Remainder of New Mexico'
cfs_lut[cfs_lut['CFSAREANAM'] == 'North Dakota'] = 'Remainder of North Dakota'
cfs_lut[cfs_lut['CFSAREANAM'] == 'South Dakota'] = 'Remainder of South Dakota'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Vermont'] = 'Remainder of Vermont'
cfs_lut[cfs_lut['CFSAREANAM'] == 'West Virginia'] = 'Remainder of West Virginia'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Wyoming'] = 'Remainder of Wyoming'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Remainder of Wisconsin_x000D_'] = 'Remainder of Wisconsin'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Nashville-Davidson--Murfreesboro, TN  CFS Area'] = 'Nashville-Davidson-Murfreesboro, TN  CFS Area'
cfs_lut[cfs_lut['CFSAREANAM'] == 'Greensboro--Winston-Salem--High Point, NC  CFS Area'] = 'Greensboro-Winston-Salem-High Point, NC  CFS Area'

# Add CFS name of origin to dataframe
flowdata.set_index('DMS_ORIG',inplace=True)
summary = cfs_lut.join(flowdata,how='outer')
summary.reset_index(inplace=True)
summary.rename(columns={'index':'DMS_ORIG','CFSAREANAM':'CFS_ORIG'},inplace=True)

# Add CFS name of destination to dataframe
summary.set_index('DMS_DEST',inplace=True)
summary = cfs_lut.join(summary,how='outer')
summary.reset_index(inplace=True)
summary.rename(columns={'index':'DMS_DEST','CFSAREANAM':'CFS_DEST'},inplace=True)

# Add SCTG numbers to dataframe
#summary.set_index('SCTG2',inplace=True)
#summary = sctg_lut.join(summary,how='outer')
#summary.reset_index(inplace=True)

# Remove circular references
summary = summary[summary['CFS_ORIG'] != summary['CFS_DEST']]

# Create generic origin/destination columns to simplify naming convention
summary['ori_des'] = summary['CFS_ORIG'] + '+' + summary['CFS_DEST']
summary['flow_kg'] = summary['Total KTons in 2012']*907185 # tons/grams (Ktons --> Kg)
summary = summary.loc[summary['SCTG'].isin([1,2,3,4,5,6,7])] # select only sctgs 1 thru 7
summary['SCTG'] = 'sctg_' + summary['SCTG'].astype(str)
summary.reset_index(inplace=True)
summary = summary[['ori_des','SCTG','flow_kg']]
summary = summary.groupby(['ori_des','SCTG'],as_index=False).mean()
summary = summary.pivot(index='ori_des',columns='SCTG',values='flow_kg')
summary['total'] = summary.sum(axis=1)
summary.reset_index(inplace=True)

# Drop duplicates (doesn't do anything...)
summary = summary.groupby('ori_des',as_index=False).mean()

# Remove redundant columns
summary[['ori','des']] = summary['ori_des'].str.split('+',expand=True)

# Remove zero value columns
summary = summary[summary['total'] > 0]

# Remove Alaska and Hawaii
#summary = summary[summary['ori'] != 'Remainder of Alaska'] #remove Alaska from origins
#summary = summary[summary['ori'] != 'Remainder of Hawaii'] #remove Hawaii from origins
#summary = summary[summary['ori'] != 'Urban Honolulu, HI  CFS Area'] #remove Honolulu from origins
#summary = summary[summary['des'] != 'Remainder of Alaska'] #remove Alaska from destinations
#summary = summary[summary['des'] != 'Remainder of Hawaii'] #remove Hawaii from destinations
#summary = summary[summary['des'] != 'Urban Honolulu, HI  CFS Area'] #remove Honolulu from destinations

# Save backup
summary.to_csv('results/faf_flows_all.csv',index=False)

# Reformat
flowtypes = ['outflows','inflows']
sctgs = ['sctg_1','sctg_2','sctg_3','sctg_4','sctg_5','sctg_6','sctg_7','total']

def split_data(df,flowtype,sctg):
    key = ''
    if flowtype == 'outflows': key = 'ori'
    elif flowtype == 'inflows': key = 'des'
    df_temp = df[[key,sctg]]
    df_temp = df_temp.pivot_table(index=key,aggfunc=sum).reset_index()
    print df_temp.shape
    df_temp.to_csv('faf_clean/faf_trade_{0}_{1}.csv'.format(flowtype,sctg),index=False)

import itertools
for (f,s) in itertools.product(flowtypes,sctgs):
    df = split_data(summary,f,s)
