import pandas

df = pandas.read_csv('data/faf_flows_2012.csv')

#print df.sort_values(['DMS_ORIG','DMS_DEST']) 

# S values in CFS database also remove some potential links which are estimated by the FAF 2012 database
# https://faf.ornl.gov/fafweb/data/FAF4%20draft%20report%20on%20data%20and%20method.pdf

# Restrict analysis to SCTGs 1-5
df= df[df['SCTG2'].isin(['Cereal grains','Other ag prods.','Animal feed','Meat/seafood','Other foodstuffs'])]

# Remove circular edges
df = df[df['DMS_ORIG'] != df['DMS_DEST']]

# Remove edges with value of zero
df = df[df['Total KTons in 2012'] > 1 ]

shortdf = df.groupby(['SCTG2'],as_index=False)['Total KTons in 2012'].sum()
print 'Sum of KTons for all commodities...'
print shortdf

# Sum over all SCTGs (1-7)
df = df.groupby(['DMS_ORIG','DMS_DEST'],as_index=False)['Total KTons in 2012'].sum()

import matplotlib.pyplot as plt
df.hist(column='Total KTons in 2012',bins=100)
plt.savefig('test.png',figsize=(16,16))
df.to_csv('data/faf_flows_2012_simplified.csv')

import networkx

edges = zip( df['DMS_ORIG'],df['DMS_DEST'],df['Total KTons in 2012'])

G = networkx.DiGraph()
G.add_weighted_edges_from(edges)

n = G.number_of_nodes()
e = G.number_of_edges()
d = networkx.density(G)
print 'Network Statistics...'
print 'Number of Nodes: ', n
print 'Number of Edges: ', e
print 'Network Density: ', d
