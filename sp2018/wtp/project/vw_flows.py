import pandas
import numpy 

### Useful Docs
# FAF Documentation: https://faf.ornl.gov/fafweb/Documentation.aspx
# SCTG Details: https://bhs.econ.census.gov/bhs/cfs/Commodity%20Code%20Manual%20(CFS-1200).pdf
# Qian's Similar Paper: http://mkonar.cee.illinois.edu/Dang_WRR_2015.pdf

# Read in 2012 data
faf = pandas.read_csv('faf_sctg2_2012.csv',usecols=['DMS_ORIG','DMS_DEST','Total KTons in 2012'])
#faf.rename(columns={'DMS_ORIG':'ORI','DMS_DEST':'DES','Total KTons in 2012':'KTON'}, inplace=True)
usda = pandas.read_csv('usda_county_alldata_2012.csv')#,usecols=['GEOID','Commodity','Irrigated_Harvest_Acre','Irrigated_Percent_Harvest','Rainfed_Harvest_Acre','Rainfed_Percent_Harvest','Production_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','Yield_Bu_per_Acre'])

# Create VW columns
usda['VW_ir_m3_per_Bu'] = usda['Yield_Bu_per_Acre'] * usda['CWU_bl_and_gn_ir_m3ha'] * usda['Irrigated_Percent_Harvest'] / 100 * 0.405 # ha/acre
usda['VW_rf_m3_per_Bu'] = usda['Yield_Bu_per_Acre'] * usda['CWU_gn_rf_m3ha'] * usda['Rainfed_Percent_Harvest'] / 100 * 0.405 # ha/acre
usda.fillna(0,inplace=True)
usda['VW_m3_per_Bu'] = usda['VW_ir_m3_per_Bu'] + usda['VW_rf_m3_per_Bu']
usda = usda[['GEOID','VW_m3_per_Bu']].groupby('GEOID',as_index=False).sum() #'VW_ir_m3_per_Bu','VW_rf_m3_per_Bu',

### NAMING CONVENTION IS DIFFERENT. LOOK INTO THIS. ###
conc = pandas.read_csv('concordance_file.csv',usecols=['SHORTNAME','CFSAREANAM'])
# conc[conc['CFSAREANAM'] == 'Alaska'] = 'Remainder of Alaska'
# conc[conc['CFSAREANAM'] == 'Arkansas'] = 'Remainder of Arkansas'
# conc[conc['CFSAREANAM'] == 'Idaho'] = 'Remainder of Idaho'
# conc[conc['CFSAREANAM'] == 'Iowa'] = 'Remainder of Iowa'
# conc[conc['CFSAREANAM'] == 'Maine'] = 'Remainder of Maine'
# conc[conc['CFSAREANAM'] == 'Mississippi'] = 'Remainder of Mississippi'
# conc[conc['CFSAREANAM'] == 'Montana'] = 'Remainder of Montana'
# conc[conc['CFSAREANAM'] == 'New Mexico'] = 'Remainder of New Mexico'
# conc[conc['CFSAREANAM'] == 'North Dakota'] = 'Remainder of North Dakota'
# conc[conc['CFSAREANAM'] == 'South Dakota'] = 'Remainder of South Dakota'
# conc[conc['CFSAREANAM'] == 'Vermont'] = 'Remainder of Vermont'
# conc[conc['CFSAREANAM'] == 'West Virginia'] = 'Remainder of West Virginia'
# conc[conc['CFSAREANAM'] == 'Wyoming'] = 'Remainder of Wyoming'
# conc[conc['CFSAREANAM'] == 'Remainder of Wisconsin_x000D_'] = 'Remainder of Wisconsin'
# conc[conc['CFSAREANAM'] == 'Nashville-Davidson--Murfreesboro, TN  CFS Area'] = 'Nashville-Davidson-Murfreesboro, TN  CFS Area'
# conc[conc['CFSAREANAM'] == 'Greensboro--Winston-Salem--High Point, NC  CFS Area'] = 'Greensboro-Winston-Salem-High Point, NC  CFS Area'
conc.set_index('SHORTNAME',inplace=True)

# Add CFS name of origin to dataframe
faf.set_index('DMS_ORIG',inplace=True)
faf = conc.join(faf,how='outer')
faf.reset_index(inplace=True)
faf.rename(columns={'index':'DMS_ORIG','CFSAREANAM':'CFS_ORIG'},inplace=True)

# Add CFS name of destination to dataframe
faf.set_index('DMS_DEST',inplace=True)
faf = conc.join(faf,how='outer')
faf.reset_index(inplace=True)
faf.rename(columns={'index':'DMS_DEST','CFSAREANAM':'CFS_DEST'},inplace=True)

geoids = pandas.read_csv('county_codes.csv',usecols=['State ANSI','County ANSI','Name'])
geoids['State ANSI'] = geoids['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
geoids['County ANSI'] = geoids['County ANSI'].apply(lambda x: '{0:03g}'.format(x))
#geoids['State Name'] = geoids[geoids['County ANSI'] == '000']['Name']
geoids = geoids[geoids['County ANSI'] != '000']
geoids['GEOID'] = geoids['State ANSI'] + geoids['County ANSI']

print usda.head()
print faf.head()
# print geoids.head()
# print conc.head()