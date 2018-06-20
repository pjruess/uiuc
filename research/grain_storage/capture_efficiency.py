import pandas

### MERGE THIS SCRIPT WITH calculate_counties_ and calculate_states_ scripts as a new function
### Ultimately want this included in final_data_{year} files so that I can ***plot capture efficiencies***

pcp = pandas.read_csv('precipitation_data/2002_county_precip.csv',usecols=['GEOID','ALAND','mean'])
stor = pandas.read_csv('county_outputs/final_data_2002.csv')

stor = stor.dropna(subset=['Storage_Bu'])

stor = stor.groupby('GEOID',as_index=False)['VWS_rf_m3'].sum()

geoids = list(stor['GEOID'].unique())

pcp = pcp.loc[pcp['GEOID'].isin(geoids)]

pcp['mean'] = pandas.to_numeric(pcp['mean'],errors='coerce')/1000000. #km conversion

pcp['ALAND'] = pcp['ALAND']/1000000.

pcp['total_km3'] = pcp['mean'] * pcp['ALAND']

pcp = pcp.sort_values('GEOID')

print pcp['total_km3'].sum()

df = pandas.merge(stor,pcp)

df['capture_efficiency'] = df['VWS_rf_m3'] / ( df['total_km3'] * 1e9 )

print df

print 'Mean capture efficiency:',df['capture_efficiency'].mean()
print 'Min capture efficienct:',df['capture_efficiency'].min()
print 'Max capture efficiency:',df['capture_efficiency'].max()

print df.sort_values('capture_efficiency')

print df[df['GEOID'] ==46067] 
