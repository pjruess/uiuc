import pandas
import itertools

def get_top_x(df,by,col,x=10):

    # Groupby identifier
    if col == 'Storage_Bu': g = df.groupby(by,as_index=False)[col].mean()
    if col == 'Yield_Bu_per_Ac': 
        g = df.groupby(by,as_index=False).agg({'Production_Bu':'sum','Harvest_Ac':'sum'})
        g['Yield_Bu_per_Ac'] = g['Production_Bu']/g['Harvest_Ac']
    else: g = df.groupby(by,as_index=False)[col].sum()

    # Sort values
    g.sort_values(col,ascending=False,inplace=True)

    return g[[by,col]][:x]

inputs = pandas.DataFrame()

columns = ['Production_Bu','Yield_Bu_per_Ac','Storage_Bu']#,'VWS_m3']
years = ['2002','2007','2012']

for col,year in itertools.product(columns,years):
    geo = 'state'
    by = 'State ANSI'
    df = pandas.read_csv('final_results/final_{0}_{1}.csv'.format(geo,year))
    df['State ANSI'] == df['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
    res = get_top_x(df,by,col,10)
    inputs['{0}_{1}'.format(col,year)] = res[by].values
    
inputs.to_csv('top_states_ranked_inputs.csv',index=False)

vws = pandas.DataFrame()

columns = ['VWS_ir_m3','VWS_rf_m3','VWS_m3']
years = ['2002','2007','2012']

for col,year in itertools.product(columns,years):
    geo = 'state'
    by = 'State.ANSI'
    df = pandas.read_csv('vws_plot_aggregates/{0}_aggregate_total_data.csv'.format(year))
    df['State.ANSI'] == df['State.ANSI'].apply(lambda x: '{0:02g}'.format(x))
    res = get_top_x(df,by,col,10)
    vws['{0}_{1}'.format(col,year)] = res[by].values
    
vws.to_csv('top_states_ranked_vws.csv',index=False)
