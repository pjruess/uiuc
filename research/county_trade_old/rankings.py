import pandas

def get_rankings(df,path):
    
    # Largest links
    links = df.sort_values('total',ascending=False).head(10)
    print links.head()
    #for index,row in links.iterrows():
    #    print '<{0}> from <{1}> to <{2}>'.format(row['total'],row['ori'],row['des'])
    
    # Inflows
    inflows = df.groupby(['des'])['total'].sum().reset_index()
    inflows = inflows.sort_values('total',ascending=False).head(10)
    print inflows.head()
    
    # Outflows
    outflows = df.groupby(['ori'])['total'].sum().reset_index()
    outflows = outflows.sort_values('total',ascending=False).head(10)
    print outflows.head()
    print '--------------'
    rng = range(10)
    ranks = pandas.DataFrame(index=rng,columns=['Rank','Outflow','Outflow Value','Inflow','Inflow Value','Link Origin','Link Destination','Link Value'])
    
    for i in rng:
        ranks.iloc[i]['Rank'] = i+1
        ranks.iloc[i]['Outflow'] = outflows.iloc[i]['ori']
        ranks.iloc[i]['Outflow Value'] = outflows.iloc[i]['total']
        ranks.iloc[i]['Inflow'] = inflows.iloc[i]['des']
        ranks.iloc[i]['Inflow Value'] = inflows.iloc[i]['total']
        ranks.iloc[i]['Link Origin'] = links.iloc[i]['ori']
        ranks.iloc[i]['Link Destination'] = links.iloc[i]['des']
        ranks.iloc[i]['Link Value'] = links.iloc[i]['total']
    
    ranks.to_csv(path,index=False)
    return ranks

faf = pandas.read_csv('results/faf_edgelist_clean.csv',usecols=['ori','des','total'])
faf_ranks = get_rankings(faf,'figures/table5_faf.csv')
print faf_ranks

county = pandas.read_csv('results/county_edgelist_clean.csv',usecols=['ori','des','total'])
county_ranks = get_rankings(county,'figures/table5_county.csv')

county_codes = pandas.read_csv('data/county_codes.csv')
county_codes['State ANSI'] = county_codes['State ANSI'].apply(lambda x: '{0:02g}'.format(x))
county_codes['County ANSI'] = county_codes['County ANSI'].apply(lambda x: '{0:03g}'.format(x))
#county_codes['State Name'] = county_codes[county_codes['County ANSI'] == '000']['Name']
county_codes['GEOID'] = county_codes['State ANSI'] + county_codes['County ANSI']

for index,row in county_ranks.iterrows():
    outflow_info = county_codes[county_codes['GEOID'] == '{0:05g}'.format(row['Outflow'])]
    state = county_codes[(county_codes['County ANSI'] == '000') & (county_codes['State ANSI'] == outflow_info['State ANSI'].values[0])]['Name'].values[0]
    row['Outflow'] = '{0} County, {1}'.format(outflow_info['Name'].values[0], state)

    inflow_info = county_codes[county_codes['GEOID'] == '{0:05g}'.format(row['Inflow'])]
    state = county_codes[(county_codes['County ANSI'] == '000') & (county_codes['State ANSI'] == inflow_info['State ANSI'].values[0])]['Name'].values[0]
    row['Inflow'] = '{0} County, {1}'.format(inflow_info['Name'].values[0], state)

    link_ori_info = county_codes[county_codes['GEOID'] == '{0:05g}'.format(row['Link Origin'])]
    state = county_codes[(county_codes['County ANSI'] == '000') & (county_codes['State ANSI'] == link_ori_info['State ANSI'].values[0])]['Name'].values[0]
    row['Link Origin'] = '{0} County, {1}'.format(link_ori_info['Name'].values[0], state)

    link_des_info = county_codes[county_codes['GEOID'] == '{0:05g}'.format(row['Link Destination'])]
    state = county_codes[(county_codes['County ANSI'] == '000') & (county_codes['State ANSI'] == link_des_info['State ANSI'].values[0])]['Name'].values[0]
    row['Link Destination'] = '{0} County, {1}'.format(link_des_info['Name'].values[0], state)

print county_ranks
county_ranks.to_csv('figures/table5_county_final.csv',index=False)
    
#county_ranks['Outflow'] = county_codes[county_codes['GEOID'] county_ranks['Outflow'] == 

#import matplotlib.pyplot as plt
#from pandas.tools.plotting import table
#
#fig,ax = plt.subplots()#figsize=(12,12))
#ax.xaxis.set_visible(False)
#ax.yaxis.set_visible(False)
#ax.set_frame_on(False)
#tab = table(ax,ranks,loc='upper right',colWidths=[0.17]*len(ranks.columns))
#tab.auto_set_font_size(False)
#tab.set_fontsize(12)
#tab.scale(1.2,1.2)
#
#plt.savefig('figures/table5.png',transparent=True)
