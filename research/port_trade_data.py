import pandas

exp = pandas.read_csv('../../research/landon/port_exports_world_2012_raw.csv')
imp = pandas.read_csv('../../research/landon/port_imports_world_2012_raw.csv')
trans = pandas.read_csv('../../research/landon/SCTG-HS Crosswalk.csv')

# total = total value of goods
# sea = value of trade through vessel ports (seaborne trade)
# air = value of trade through airborne carriers
# van = value of shipments transported in any van-type container (already included in sea)
exp.columns = ['port','commodity','total_exports_$','sea_exports_$','sea_exports_kg','air_exports_$','air_exports_kg','van_exports_$','van_exports_kg']
imp.columns = ['port','commodity','total_imports_$','sea_imports_$','sea_imports_kg','air_imports_$','air_imports_kg','van_imports_$','van_imports_kg']

# Sum all kg for total mass
exp['total_exports_kg'] = exp['sea_exports_kg'] + exp['air_exports_kg']
imp['total_imports_kg'] = imp['sea_imports_kg'] + imp['air_imports_kg']

# Merge dataframes to join by location and commodity
df = pandas.merge(exp,imp,how='outer')

# Clean up port names
df['port'] = df['port'].str.replace(r' \(.*?\)','')

# Create HS column representing four-digit HS codes
df['hs'] = df['commodity'].str[:4]

# Multiply all hs values less than 100 by 100
trans.loc[trans['hs'] < 100, ['hs']] *= 100

# Add leading zero to all hs values less than 1000
trans['hs'] = trans['hs'].apply('{:0>4}'.format)

# Slice first two digits from hs for trans and df dataframes
trans['hs_edit'] = trans['hs'].str[:2]
df['hs_edit'] = df['hs'].str[:2]

# Drop duplicate 'hs_edit' values to avoid redundancy
trans = trans.drop_duplicates(subset=['hs_edit'])

# Clean up trans
del trans['hs']
del trans['hs_description']

# Associate sctg values in trans with hs values in df
df_edit = pandas.merge(df,trans,on=['hs_edit'])

# Clean up df_edit
del df_edit['hs_edit']

print df_edit.columns

df_subset = df_edit[['port','commodity','total_exports_$','total_exports_kg','total_imports_$','total_imports_kg','hs','sctg']]

print df_subset

# Need to isolate sctg exports and imports by location