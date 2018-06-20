import pandas

# Read datasets
vals = pandas.read_csv('corn_data/narrowresult.csv',usecols=['ActivityStartDate','MonitoringLocationIdentifier','CharacteristicName','ResultSampleFractionText','ResultMeasureValue','ResultMeasure/MeasureUnitCode'])
locs = pandas.read_csv('corn_data/station.csv',usecols=['MonitoringLocationIdentifier','HorizontalCoordinateReferenceSystemDatumName','CountyCode',])#'StateCode','LatitudeMeasure','LongitudeMeasure',])

# Merge datasets
df = pandas.merge(vals,locs,on='MonitoringLocationIdentifier',how='outer')
df.drop('MonitoringLocationIdentifier',axis=1,inplace=True)

# Create year column
df['Year'] = df['ActivityStartDate'].str.split('-').str[0]
df.drop('ActivityStartDate',axis=1,inplace=True)

# Filter to Total Phosphorous and Nitrogen
df = df[df['ResultSampleFractionText'] == 'Total']

# Focus first on Phosphorous (VERY little Nitrogen data)
df = df[df['CharacteristicName'] == 'Phosphorus']

# Add Ag Districts
df.drop('CharacteristicName',axis=1,inplace=True)
df.drop('ResultSampleFractionText',axis=1,inplace=True)

# Pick most popular units and stick with those (mg/L as P)
# for unit in df['ResultMeasure/MeasureUnitCode'].unique():
# 	print '{0}, {1}'.format(unit,df[df['ResultMeasure/MeasureUnitCode'] == unit].shape)
df = df[df['ResultMeasure/MeasureUnitCode'] == 'mg/l as P']
df.drop('ResultMeasure/MeasureUnitCode',axis=1,inplace=True)

# Because Horizontal CRS is all same, column no longer needed
# print df['HorizontalCoordinateReferenceSystemDatumName'].unique()
df.drop('HorizontalCoordinateReferenceSystemDatumName',axis=1,inplace=True)

# Read in county codes : ag district data
# Source: https://www.nass.usda.gov/Data_and_Statistics/County_Data_Files/Frequently_Asked_Questions/county_list.txt
cc = pandas.read_csv('county_codes.csv',usecols=['State ANSI','District ANSI','County ANSI'])
cc['State ANSI'] = cc['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
cc['District ANSI'] = cc['District ANSI'].apply(lambda x: '{0:02g}'.format(x))
cc['County ANSI'] = cc['County ANSI'].apply(lambda x: '{0:03g}'.format(x))

# Filter to Illinois
cc = cc[cc['State ANSI'] == '17']
cc.drop('State ANSI',axis=1,inplace=True)

# Merge Phosphorous data with Agricultural Districts
df['CountyCode'] = df['CountyCode'].apply(lambda x: '{0:03g}'.format(x))
df = pandas.merge(df,cc,left_on='CountyCode',right_on='County ANSI',how='outer')
df.drop('County ANSI',axis=1,inplace=True)
df.drop('CountyCode',axis=1,inplace=True)
df.rename(columns={'ResultMeasureValue':'P_mg/l'},inplace=True)

# Read in Ag District name:number table
ad = pandas.read_csv('ag_dists.csv')
ad['Ag District Code'] = ad['Ag District Code'].apply(lambda x: '{0:02g}'.format(x))

# Merge Phosphorous data with Agricultural District Names
df = pandas.merge(df,ad,left_on='District ANSI',right_on='Ag District Code',how='outer')
df.drop('District ANSI',axis=1,inplace=True)

# Remove rows with no Year value
import numpy
df['Year'].replace('', numpy.nan, inplace=True)
df.dropna(subset=['Year'], inplace=True)

# Remove phosphorous levels of 999 (probably an error report)
df = df[df['P_mg/l'] != 999]

# Write to CSV
df.to_csv('corn_data/epa_il_phosphorous.csv',index=False)
print df.head()