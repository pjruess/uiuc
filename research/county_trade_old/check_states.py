import pandas

sctgs = ['data/cnty_faf12_domestic_1_0.0005_mincost_upload.csv','data/cnty_faf12_domestic_2_0.005_mincost_upload.csv','data/cnty_faf12_domestic_3_0.05_mincost_upload.csv','data/cnty_faf12_domestic_4_0.005_mincost_upload.csv','data/cnty_faf12_domestic_5_5e-05_mincost_upload.csv','data/cnty_faf12_domestic_6_5e-05_mincost_upload.csv','data/cnty_faf12_domestic_7_5e-05_mincost_upload.csv']

for sctg in sctgs: 
    print 'FILE: {0}'.format(sctg)
    df = pandas.read_csv(sctg,usecols=['sim_ori','sim_des','simulate'],quotechar='"')
    
    df = df[df['simulate'] > 0]
    
    df['state_ori'] = df['sim_ori'].apply(lambda x: str('{0:05g}'.format(x))[:2])
    df['state_des'] = df['sim_des'].apply(lambda x: str('{0:05g}'.format(x))[:2])
    
    all_states = sorted( set( list(df['state_ori'].unique()) + list(df['state_des'].unique()) ) )
    
    print all_states

    print df[df['state_ori'] == '05'].head()

