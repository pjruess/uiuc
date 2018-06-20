import pandas

df = pandas.read_csv('nid_cleaned_csv.csv')

df = df[df['State'] != 'HI']
df = df[df['State'] != 'PR']
df = df[df['State'] != 'AK']
df = df[df['State'] != 'GU']

print 'Number of States in CONUS (should be 48):', len(df['State'].unique()) # should be 48

print 'Total number of dams in NID:', len(df) # Number of dams included

max_stor = long(df['Max_Storage'].sum()) # acre-feet
max_stor_m3 = long(max_stor * 1233.48) # convert to cubic meters

nor_stor = long(df['Normal_Storage'].sum()) # acre-feet
nor_stor_m3 = long(nor_stor * 1233.48) # convert to cubic meters

print 'Max Storage (m3):', max_stor_m3
print 'Normal Storage (m3):', nor_stor_m3

print 'Average Max Storage for all dams (m3):', max_stor_m3/len(df)
print 'Average Normal Storage for all dams (m3):', nor_stor_m3/len(df)