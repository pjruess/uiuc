import pandas

df = pandas.read_csv('nid_cleaned_csv.csv')

df = df[df['State'] != 'HI']
df = df[df['State'] != 'PR']
df = df[df['State'] != 'AK']
df = df[df['State'] != 'GU']

print 'Number of States in CONUS (should be 48):', len(df['State'].unique()) # should be 48

print 'Total number of dams in NID:', len(df) # Number of dams included

print df.columns

print len(df['Dam_Name'].unique())

df_norm = df.groupby(['NID_ID','Longitude','Latitude'],as_index=False)['Normal_Storage'].max()

nor_stor = long(df_norm['Normal_Storage'].sum()) # acre-feet
nor_stor_m3 = long(nor_stor * 1233.48) # convert to cubic meters

df_max = df.groupby(['NID_ID','Longitude','Latitude'],as_index=False)['Max_Storage'].max()

max_stor = long(df_max['Max_Storage'].sum()) # acre-feet
max_stor_m3 = long(max_stor * 1233.48) # convert to cubic meters

print 'Normal Storage (km3):', nor_stor_m3/1.e9
print 'Max Storage (km3):', max_stor_m3/1.e9

#print 'Average Max Storage for all dams (m3):', max_stor_m3/len(df)
#print 'Average Normal Storage for all dams (m3):', nor_stor_m3/len(df)

# Search for Grand Coulee
print [s for s in df['Dam_Name'].astype(str).unique() if 'COULEE' in s]

print df[df['Dam_Name'] == 'GRAND COULEE'][['Dam_Name','Normal_Storage','Max_Storage']]

df_norm.to_csv('normal_dams.csv')
df_max.to_csv('max_dams.csv')

df.to_csv('dams_subset.csv')

1/0


df_dup = pandas.concat(g for _, g in df_norm.groupby(['NID_ID','Longitude','Latitude']) if len(g) > 1)
df_dup.to_csv('duplicate_dams.csv',index=False)
1/0

max_stor = long(df['Max_Storage'].sum()) # acre-feet
max_stor_m3 = long(max_stor * 1233.48) # convert to cubic meters

nor_stor = long(df['Normal_Storage'].sum()) # acre-feet
nor_stor_m3 = long(nor_stor * 1233.48) # convert to cubic meters

print 'Original Results... ------------------------------'
print 'Max Storage (km3):', max_stor_m3/1.e9
print 'Normal Storage (km3):', nor_stor_m3/1.e9

#print 'Average Max Storage for all dams (m3):', max_stor_m3/len(df)
#print 'Average Normal Storage for all dams (m3):', nor_stor_m3/len(df)
