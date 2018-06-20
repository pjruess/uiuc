import pandas

df = pandas.read_csv('nid_cleaned_csv.csv')

df = df[df['State'] != 'HI']
df = df[df['State'] != 'PR']
df = df[df['State'] != 'AK']
df = df[df['State'] != 'GU']

print len(df['State'].unique()) # should be 48

max_stor = long(df['Max_Storage'].sum()) # acre-feet

print max_stor # acre-feet

print long(max_stor * 1233.48) # convert to cubic meters