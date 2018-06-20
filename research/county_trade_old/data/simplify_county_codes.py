import pandas

df = pandas.read_csv('county_codes.csv')

print df.head()

df['State ANSI'] = df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
df['County ANSI'] = df['County ANSI'].apply(lambda x: '{0:03g}'.format(x))
df['State Name'] = df[df['County ANSI'] == '000']['Name']

print df.head()
