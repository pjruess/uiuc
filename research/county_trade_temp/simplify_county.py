import pandas
import os

path = 'results/county_flows_all.csv'

if os.path.isfile(path):
    print 'Loading aggregated file from {0}'.format(path)
    df_all = pandas.read_csv(path)
else:
    print 'Creating new aggregated file at {0}'.format(path)
    df1 = pandas.read_csv('data/cnty_faf12_domestic_1_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df2 = pandas.read_csv('data/cnty_faf12_domestic_2_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df3 = pandas.read_csv('data/cnty_faf12_domestic_3_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df4 = pandas.read_csv('data/cnty_faf12_domestic_4_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df5 = pandas.read_csv('data/cnty_faf12_domestic_5_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df6 = pandas.read_csv('data/cnty_faf12_domestic_6_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    df7 = pandas.read_csv('data/cnty_faf12_domestic_7_7_mincost_upload_.csv',usecols=['sim_ori','sim_des','simulate_kg'],quotechar='"')
    
    # Reformat for proper merging
    df1['simulate_kg'] = pandas.to_numeric(df1['simulate_kg'])
    df2['simulate_kg'] = pandas.to_numeric(df2['simulate_kg'])
    df3['simulate_kg'] = pandas.to_numeric(df3['simulate_kg'])
    df4['simulate_kg'] = pandas.to_numeric(df4['simulate_kg'])
    df5['simulate_kg'] = pandas.to_numeric(df5['simulate_kg'])
    df6['simulate_kg'] = pandas.to_numeric(df6['simulate_kg'])
    df7['simulate_kg'] = pandas.to_numeric(df7['simulate_kg'])

    df1['sim_ori'] = df1['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df2['sim_ori'] = df2['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df3['sim_ori'] = df3['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df4['sim_ori'] = df4['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df5['sim_ori'] = df5['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df6['sim_ori'] = df6['sim_ori'].apply(lambda x: '{0:05g}'.format(x))
    df7['sim_ori'] = df7['sim_ori'].apply(lambda x: '{0:05g}'.format(x))

    df1['sim_des'] = df1['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df2['sim_des'] = df2['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df3['sim_des'] = df3['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df4['sim_des'] = df4['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df5['sim_des'] = df5['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df6['sim_des'] = df6['sim_des'].apply(lambda x: '{0:05g}'.format(x))
    df7['sim_des'] = df7['sim_des'].apply(lambda x: '{0:05g}'.format(x))

    # Proper merge test (compare with number of post-merge rows)
    #print 'SCTG 1 shape:',df1.shape
    #print 'SCTG 2 shape:',df2.shape
    #print 'SCTG 3 shape:',df3.shape
    #print 'SCTG 4 shape:',df4.shape
    #print 'SCTG 5 shape:',df5.shape
    #print 'SCTG 6 shape:',df6.shape
    #print 'SCTG 7 shape:',df7.shape
    
    #print 'SCTG 1 shape (non-zero):',df1[df1['simulate_kg'] != 0].shape
    #print 'SCTG 2 shape (non-zero):',df2[df2['simulate_kg'] != 0].shape
    #print 'SCTG 3 shape (non-zero):',df3[df3['simulate_kg'] != 0].shape
    #df3[df3['simulate_kg'] != 0].to_csv('TEST_orig.csv')
    #print 'SCTG 4 shape (non-zero):',df4[df4['simulate_kg'] != 0].shape
    #print 'SCTG 5 shape (non-zero):',df5[df5['simulate_kg'] != 0].shape
    #print 'SCTG 6 shape (non-zero):',df6[df6['simulate_kg'] != 0].shape
    #print 'SCTG 7 shape (non-zero):',df7[df7['simulate_kg'] != 0].shape

    # Create place-holder column for merging
    def make_des_ori(df):
        df['ori_des'] = df['sim_ori'].map(str) + ', ' + df['sim_des'].map(str)
        del df['sim_ori']
        del df['sim_des']
        return df
    
    df1 = make_des_ori(df1)
    df2 = make_des_ori(df2)
    df3 = make_des_ori(df3)
    #df3 = df3.groupby(['ori_des']).mean().reset_index()
    #df3[df3['simulate_kg'] != 0].to_csv('TEST_SPEC_orig.csv')
    df4 = make_des_ori(df4)
    df5 = make_des_ori(df5)
    df6 = make_des_ori(df6)
    df7 = make_des_ori(df7)
    
    # Merge df1 and df2 
    df12 = pandas.merge(df1,df2,on=['ori_des'],how='outer')
    df12.rename(columns={'simulate_kg_x':'sctg_1','simulate_kg_y':'sctg_2'},inplace=True)

    # Merge with df3
    df123 = pandas.merge(df12,df3,on=['ori_des'],how='outer')
    df123.rename(columns={'simulate_kg':'sctg_3'},inplace=True)
    
    # Merge with df4
    df1234 = pandas.merge(df123,df4,on=['ori_des'],how='outer')
    df1234.rename(columns={'simulate_kg':'sctg_4'},inplace=True)
    
    # Merge with df5
    df12345 = pandas.merge(df1234,df5,on=['ori_des'],how='outer')
    df12345.rename(columns={'simulate_kg':'sctg_5'},inplace=True)
    
    # Merge with df6
    df123456 = pandas.merge(df12345,df6,on=['ori_des'],how='outer')
    df123456.rename(columns={'simulate_kg':'sctg_6'},inplace=True)
    
    # Merge with df7
    df_all = pandas.merge(df123456,df7,on=['ori_des'],how='outer')
    df_all.rename(columns={'simulate_kg':'sctg_7'},inplace=True)
    
    # Sum all sctg flows
    df_all.set_index('ori_des')
    df_all['total'] = df_all.sum(axis=1)
    df_all.reset_index(inplace=True)
    
    # Re-organize dataframe
    df_all._get_numeric_data()[(df_all > 0) & (df_all < 0.001)] = 0.001
    df_all = df_all.groupby(['ori_des']).mean().reset_index()
    df_all[['ori','des']] = df_all['ori_des'].str.split(', ',expand=True)
    del df_all['ori_des']
    del df_all['index']

    # Remove values equal to zero
    df_all = df_all[df_all['total'] > 0]

    # Remove circular references
    df_all = df_all[df_all['ori'] != df_all['des']]

    #df_all = df_all[df_all['ori'].str[:2] != '02'] #remove Alaska (02) from origins
    #df_all = df_all[df_all['ori'].str[:2] != '15'] #remove Hawaii (15) from origins
    #df_all = df_all[df_all['des'].str[:2] != '02'] #remove Alaska (02) from destinations
    #df_all = df_all[df_all['des'].str[:2] != '15'] #remove Hawaii (15) from destinations
    df_all.to_csv(path,index=False)

# Tweak an annoyance. Fix this later. Not working properly above. 
#df_all[['ori','des']] = df_all['ori_des'].str.split(', ',expand=True)
#del df_all['ori_des']

print 'SCTG 1 shape (non-zero):',df_all[df_all['sctg_1'] != 0].shape
#df_all[df_all['sctg_3'] != 0].to_csv('TEST.csv')
print 'SCTG 2 shape (non-zero):',df_all[df_all['sctg_2'] != 0].shape
print 'SCTG 3 shape (non-zero):',df_all[df_all['sctg_3'] != 0].shape
print 'SCTG 4 shape (non-zero):',df_all[df_all['sctg_4'] != 0].shape
print 'SCTG 5 shape (non-zero):',df_all[df_all['sctg_5'] != 0].shape
print 'SCTG 6 shape (non-zero):',df_all[df_all['sctg_6'] != 0].shape
print 'SCTG 7 shape (non-zero):',df_all[df_all['sctg_7'] != 0].shape

# Save data as independent csv files to avoid overloading memory when plotting maps
flowtypes = ['outflows','inflows']
sctgs = ['sctg_1','sctg_2','sctg_3','sctg_4','sctg_5','sctg_6','sctg_7','total']

def split_data(df,flowtype,sctg):
    key = ''
    if flowtype == 'outflows': key = 'ori'
    elif flowtype == 'inflows': key = 'des'
    df_temp = df_all[[key,sctg]]
    df_temp = df_temp.pivot_table(index=key,aggfunc=sum).reset_index()
    print df_temp.shape
    df_temp.to_csv('county_clean/county_trade_{0}_{1}.csv'.format(flowtype,sctg),index=False)

import itertools
for (f,s) in itertools.product(flowtypes,sctgs):
    df = split_data(df_all,f,s)
