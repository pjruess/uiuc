import pandas
import os

edgelist_path = 'results/county_edgelist_clean.csv'

el = pandas.DataFrame()

if os.path.isfile(edgelist_path):
    print 'Reading edgelist from {0}'.format(edgelist_path)
    el = pandas.read_csv(edgelist_path)
   
else: 
    print 'Creating edgelist at {0}'.format(edgelist_path)

    counties = pandas.read_csv('results/county_coords_simplified.csv')
    
    flow_summary_path = 'results/county_flows_no_duplicates_summary.csv'
    
    flows = pandas.DataFrame()

    if os.path.isfile(flow_summary_path):
        print 'Reading flow summary from {0}'.format(flow_summary_path)
        flows = pandas.read_csv(flow_summary_path)

    else: 
        print 'Creating flow summary at {0}'.format(flow_summary_path)
        flows = pandas.read_csv('results/county_flows_no_duplicates.csv',usecols=['ori','des','total'])
        flows.to_csv(flow_summary_path,index=False)

    #flows = flows[flows['total'] >= flows['total'].quantile(0.999)] 
    #flows.to_csv('results/county_trade_flows_no_duplicates_summary_0.001.csv')
    
    #flows = flows[flows['total'] >= flows['total'].quantile(0.9999)] 
    #flows.to_csv('results/county_trade_flows_no_duplicates_summary_0.0001.csv')
    
    print flows.head(10)
    print flows.shape
    
    #flows = pandas.read_csv('results/county_trade_flows_no_duplicates_summary_0.001.csv')
    
    #print counties.head(10)
    #print flows.head(10)
    
    el = pandas.merge(flows,counties,left_on='ori',right_on='GEOID',how='outer')
    el.rename(columns={'lon':'ori_lon','lat':'ori_lat'},inplace=True)
    
    el = pandas.merge(el,counties,left_on='des',right_on='GEOID')
    el.rename(columns={'lon':'des_lon','lat':'des_lat'},inplace=True)
    print el.head(10)
    
    del el['GEOID_x']
    del el['GEOID_y']
    #del el['Unnamed: 0'] #mysterious index column
    
    el['ori'] = el['ori'].apply(lambda x: '{0:05g}'.format(x))
    el['des'] = el['des'].apply(lambda x: '{0:05g}'.format(x))
    
    print el.head(10)
    
    el.to_csv(edgelist_path,index=False)

