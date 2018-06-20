import pandas

df = pandas.read_csv('county_rice_2016_raw.csv',usecols=['State ANSI','County ANSI'])

df = df[df['County ANSI'] > 0]

df['State'] = df['State ANSI'].apply(
    lambda x: '{0:02g}'.format(x) # formats leading zeros while ignoring decimal points
    )
df['County'] = df['County ANSI'].apply(
    lambda x: '{0:03g}'.format(x) # formats leading zeros while ignoring decimal points
    )

df['GEOID'] = df['State'] + df['County']
print df.head()
print map(int,list(df['GEOID']))