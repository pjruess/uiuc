import pandas

df = pandas.read_csv('../hw2/vwc_flows_2005.csv')

# print df.head(n=5)

# Create list of all unique countries included in dataset
recips = list(df.columns[2:])
donors = list(df['Donor'].values)
countries = set( recips + donors ) # Number of nodes

# Make matrix symmetrical (ie. make sure donors and recipients lists include all counties)
df = df.groupby(['Donor'])[recips].sum().reset_index()
df = df.set_index('Donor')

for c in countries:
    if c not in donors:
        print '{0} not in donors'.format(c)
        df.loc[c] = 0 # add empty column to df
    if c not in recips:
        print '{0} not in recips'.format(c)
        df[c] = 0 # add empty row to df

# print df.columns
# Get rid of countries that donate nothing
df['sum'] = df.sum(axis=1)
df = df.sort_values('sum', ascending=False)
df = df[df['sum'] != 0]
print df

# Save final matrix
df = df.sort_index(axis=0) # sort rows alphabetically
df = df.sort_index(axis=1) # sort columns alphabetically
# df.columns = [x.replace(',',' ') for x in df.columns] # remove commas in column headers
# df.index = [x.replace(',',' ') for x in df.index] # remove commas in row indices

# import string
# printable = set(string.printable)
# replace_punctuation = string.maketrans(string.punctuation, '_'*len(string.punctuation))
# df.columns = [filter(lambda x: x in printable, t) for t in df.columns]
# df.columns = [t.translate(replace_punctuation) for t in df.columns]
# df.columns = [x.replace(' ','') for x in df.columns] # change spaces to underscores in column headers
# print df.columns[25:35]
# df.index = [x.replace(' ','') for x in df.index] # change spaces to underscores in row indices
import re
df.columns = [re.sub('[^0-9a-zA-Z]+', '', s) for s in df.columns]
df.index = [re.sub('[^0-9a-zA-Z]+', '', s) for s in df.index]
df.index.name = 'Countries' # add index label
df.to_csv('food_aid_matrix.txt',sep=' ',header=True,index=True)
