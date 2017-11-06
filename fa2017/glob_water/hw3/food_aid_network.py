import pandas
import networkx
import matplotlib
import matplotlib.pyplot as plt
import scipy

df = pandas.read_csv('../hw2/vwc_flows_2005.csv')

del df['Commodity']

# Create list of edges to add to graph
df = df.set_index('Donor') # change index to prepare for stack function
df = df.stack().reset_index() # stack to create donor-recipient pairs, then reset index to make them columns
df = df.rename(columns={'level_1': 'Recipient', 0: 'Flow'})
df = df.loc[df['Flow'] != 0] # remove any flows of zero (to avoid accidental inclusion in the network)
df.to_csv('food_aid_matrix_stacked.csv',sep=',',header=True, index=False) # create csv output for other scripts
edges = zip(df['Donor'],df['Recipient'],df['Flow'])

# Create networkx graph of data
G = networkx.DiGraph() # create directed graph
G.add_weighted_edges_from(edges)
# print G.edges(data=True)

# Create visual representation of graph for fun
# f = plt.figure()
# networkx.draw( G, ax=f.add_subplot(111) )
# f.savefig('network.pdf')

# Problem 2: Number of nodes and edges in graph, and graph density
n = G.number_of_nodes() # 130
e = G.number_of_edges() # 693
d = networkx.density(G) # 0.0413237924866
print 'Number of nodes: ', n
print 'Number of edges: ', e
print 'Network Density: ', d

# Manually verify density
# Note that this is a directed graph, so possible combinations is not divided by 2 (as in undirected)
d_test = float( float(e) / ( float(n) * ( float(n) - 1 ) ) )

# Define function to plot degree and strength distributions
def deg_hist(data,path):
    fig,ax = plt.subplots()
    weights = scipy.ones_like(data)/float(len(data)) # Determine weights to make histogram bars <= 1
    ax.hist( data, weights=weights)#, bins=scipy.arange(1,max(data)+1) ) # Plot with all node degrees as separate bins
    fig.savefig(path)
    plt.close()

# Collect Degree and Strength data for all nodes
degs = zip(*G.degree())[1] # Retrieve degree values for all nodes
deg_hist(degs,'degree_dist.pdf')

# Problems 3 &  4: Plot Degree Distribution and Strength Distribution
strs = zip (*G.degree(weight='weight'))[1] # Retrieve weighted degree values for all nodes
print strs
deg_hist(strs,'strength_dist.pdf')

# Problem 5: Rank top 10 countries for Clustering and Betweenness-Centrality
print networkx.betweenness_centrality(G)

