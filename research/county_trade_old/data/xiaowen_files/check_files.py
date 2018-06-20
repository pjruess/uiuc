import pandas

df1 = pandas.read_csv('raw_data/faf_complete_by_sctg1_kg_2012.csv')
df234 = pandas.read_csv('raw_data/faf_complete_by_sctg_kg_2012.csv')
df567 = pandas.read_csv('raw_data/faf_complete_by_sctg567_kg_2012.csv')

print 'SCTG 1 ---'
print df1.shape
print 'SCTG 2, 3, 4 ---'
print df234.shape
print 'SCTG 5, 6, 7 ---'
print df567.shape

def make_ori_des(df):
    df['ori_des'] = df['sim_ori'].map(str) + ', ' + df['sim_des'].map(str)
    del df['sim_ori']
    del df['sim_des']
    return df

df1567 = pandas.concat([df1,df567])
print df1567.shape

import math
df1567 = df1567[df1567.sim_ori != df1567.sim_des]
df1567['value'] = df1567['value'].map(lambda x: x/math.pow(10, 7))
df1567 = log(df1567, [u'sctg',u'sim_des',u'sim_ori',u'value'])
assert(sum(df1567[['sctg','sim_ori','sim_des','to_fr']].duplicated())==0)
df1567.drop(['from_fr','to_fr'],1,inplace=True)

df234 = df234[df234.sim_ori != df234.sim_des]
df234['value'] = df234['value'].map(lambda x: x/math.pow(10, 7))
df234 = log(df234, [u'sctg',u'sim_des',u'sim_ori',u'value'])
assert(sum(df234[['sctg','sim_ori','sim_des','to_fr']].duplicated())==0)
df234.drop(['from_fr','to_fr'],1,inplace=True)

df1567 = make_ori_des(df1567)
df234 = make_ori_des(df234)

od1567 = df1567[df1567['value'].isnull()]['ori_des']
print od1567.shape
print df1567[df1567['ori_des'].isin(od1567)].head()
v = df1567[df1567['ori_des'] == '01-142, 01-142']['value']
print v
print '------------'
print df1567[df1567['ori_des'] == '01-142, 01-142']
#print df1567.iloc[[0,1,2,31144,44949,58786]]

1/0

cols1567 = ['dist','gdp_ori_usd','gdp_des_usd','pop_ori_2012','pop_des_2012']
cols234 = ['dist','gdp_ori_usd','gdp_des_usd','pop_ori_2012','pop_des_2012','prod_ori_ton','prod_des_ton']

for c in cols1567:
    res = df1567.pivot_table(values=c,index='ori_des',columns='sctg')
    
    path = 'analysis/df1567_{0}.csv'.format(c)
    res.to_csv(path)

for c in cols234:
    res = df234.pivot_table(values=c,index='ori_des',columns='sctg')

    path = 'analysis/df234_{0}.csv'.format(c)
    res.to_csv(path)

#df1 = make_des_ori(df1)
#df234 = make_des_ori(df234)
#df567 = make_des_ori(df567)
#
## Mergedf1 and df2 
#df1234 = pandas.merge(df1,df234,on=['ori_des'],how='outer')
#df1234.rename(columns={'dist_x':'','simulate_y':'sctg_2'},inplace=True)
#
## Merge with df3
#df = pandas.merge(df1234,df567,on=['ori_des'],how='outer')
#df.rename(columns={'simulate':'sctg_3'},inplace=True)




#df2 = df234[df234['sctg'] == 2]
#print 'SCTG 2 ---'
#print df2.head()
#df3 = df234[df234['sctg'] == 3]
#print 'SCTG 3 ---'
#print df3.head()
#df4 = df234[df234['sctg'] == 4]
#print 'SCTG 4 ---'
#print df4.head()
#df5 = df567[df567['sctg'] == 5]
#print 'SCTG 5 ---'
#print df5.head()
#df6 = df567[df567['sctg'] == 6]
#print 'SCTG 6 ---'
#print df6.head()
#df7 = df567[df567['sctg'] == 7]
#print 'SCTG 7 ---'
#print df7.head()
#
## Check for rows missing values
#def row_len(df):
#    cols = list(df)
#    print cols
#
#dfs = ['df1','df2','df3','df4','df5','df6','df7']
#
#for df in dfs:
#    row_len(df)
#
#
