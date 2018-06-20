import pandas

df = pandas.read_csv('usda_2016_production_total_organic.csv',usecols=['Program','State','State ANSI','Commodity','Data Item','Domain','Value'])

# Remove data with redacted values
noise = [' (D)',' (NA)','(1)']
df = df[~df['Value'].isin(noise)]

# Retrieve total production
tot = df[df['Program'] == 'SURVEY']
#print tot.head()
tot = tot[~tot['Data Item'].str.endswith('$')]
print tot['Data Item'].unique()
#tot = tot[tot['Data Item'].str.endswith('BU')] # Simplify to deal only with Bushels
#coms = tot.Commodity.unique() # Identify unique commodities (using Bushels as units)


# Retrieve organic production
org = df[df['Program'] == 'CENSUS']
#print org.head()
#org = org[org['Commodity'].isin(coms)]
#print org.head()
#print org.head()

