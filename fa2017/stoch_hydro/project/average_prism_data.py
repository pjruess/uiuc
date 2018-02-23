import pandas

# Read in all dataframes with specified identifier b/w 1996-2005
identifiers = ['ppt','tdmean','tmax','tmean','tmin','vpdmax','vpdmin']
years = range(1996,2006)

filename = 'data/prism_csvs/prism_{0}_{1}.csv'

for i in identifiers:
    df = pandas.DataFrame()
    for y in years:
        tempdf = pandas.read_csv( filename.format(i,y) )
        if y == years[0]: 
            df['GEOID'] = tempdf['GEOID']
            df['NAME'] = tempdf['NAME']
            df['ALAND'] = tempdf['ALAND']
        df[y] = tempdf['mean']
    df['mean'] = df[years].apply(pandas.to_numeric,errors='coerce').mean(axis=1)
    df.to_csv('data/prism_csvs/prism_{0}_1996-2005.csv'.format(i))
