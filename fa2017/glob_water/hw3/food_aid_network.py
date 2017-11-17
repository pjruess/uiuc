# Import necessary libraries
import pandas
import networkx
import matplotlib.pyplot as plt

# Read in data
df = pandas.read_csv('vwc_flows_2005.csv')

### ORGANIZE DATA FOR CIRCOS PLOT GENERATION ###

# Create list of all unique countries included in dataset
recips = list(df.columns[2:])
donors = list(df['Donor'].values)
countries = set( recips + donors ) # Number of nodes

# Make matrix symmetrical (ie. make sure donors and recipients lists include all counties)
circos = df.groupby(['Donor'])[recips].sum().reset_index()
circos = circos.set_index('Donor')

not_in_donors = []
not_in_recips = []

for c in countries:
    if c not in donors:
        not_in_donors.append(c)
        circos.loc[c] = 0 # add empty column to circos
    if c not in recips:
        not_in_recips.append(c)
        circos[c] = 0 # add empty row to circos

print 'Countries artificially added to Donors list...\n',not_in_donors,'\n'
print 'Countries artificially added to Recipients list...\n',not_in_recips,'\n'

# Get rid of countries that donate nothing
circos['sum'] = circos.sum(axis=1)
circos = circos.sort_values('sum', ascending=False)
circos = circos[circos['sum'] != 0]

# Reformat to improve Circos plotting
circos = circos.sort_index(axis=0) # sort rows alphabetically
circos = circos.sort_index(axis=1) # sort columns alphabetically

# Retain ONLY numbers, lower-case letters, and upper-case letters in country names
import re
circos.columns = [re.sub('[^0-9a-zA-Z]+', '', s) for s in circos.columns]
circos.index = [re.sub('[^0-9a-zA-Z]+', '', s) for s in circos.index]
circos.index.name = 'Countries' # add index label

# Save to text file to import to Circos plot: http://mkweb.bcgsc.ca/tableviewer/
circos.to_csv('food_aid_matrix.txt',sep=' ',header=True,index=True)

### CALCULATE NETWORK STATISTICS ###

# Remove 'commodity' column to make adjacency matrix
network = df.copy()
del network['Commodity']

# Create list of edges to add to graph
network = network.set_index('Donor') # change index to prepare for stack function
network = network.stack().reset_index() # stack to create donor-recipient pairs, then reset index to make them columns
network = network.rename(columns={'level_1': 'Recipient', 0: 'Flow'}) # rename columns to be more intuitive
network = network.loc[network['Flow'] != 0] # remove any flows of zero (to avoid accidental inclusion in the network)
edges = zip( network['Donor'], network['Recipient'], network['Flow'] ) # combine adjacency matrix information into edge-list

# Create networkx graph of data
G = networkx.DiGraph() # create directed graph
G.add_weighted_edges_from(edges) # add edges from edge-list

# Create visual representation of graph for fun
# f = plt.figure()
# networkx.draw( G, ax=f.add_subplot(111) )
# f.savefig('network.pdf')

# Problem 2: Number of nodes and edges in graph, and graph density
n = G.number_of_nodes() # 130
e = G.number_of_edges() # 693
d = networkx.density(G) # 0.0413237924866
print 'Number of Nodes: ', n
print 'Number of Edges: ', e
print 'Network Density: ', d

# Manually verify density
# Note that this is a directed graph, so possible combinations is NOT divided by 2 (as in undirected)
d_test = float( float(e) / ( float(n) * ( float(n) - 1 ) ) )
print 'Density Check:   ',d_test,'\n' # 0.0413237924866

# Problems 3 & 4: Plot Degree Distribution and Strength Distrbution
def plot_dd(data,path,title,weight=False):
    """ 
    Plots degree distribution of a networkx graph object
    ---
    data: networkx graph object
    path: file path to save to
    title: title of plot
    weight: if True, add edge wights
    """
    if weight: # add weights to in- and out-degrees
        in_deg = data.in_degree(weight='weight')
        out_deg = data.out_degree(weight='weight')
        # path = '{0}_weighted.{1}'.format( path.split('.')[0], path.split('.')[1] )
    else: 
        in_deg = data.in_degree()
        out_deg = data.out_degree()

    # Retrieve values and ranks for plotting
    in_vals = sorted(set(in_deg.values()))
    in_hist = [in_deg.values().count(x) for x in in_vals]

    out_vals = sorted(set(out_deg.values()))
    out_hist = [out_deg.values().count(x) for x in out_vals]
    
    # Plot data
    plt.plot(in_vals,in_hist,'ro-')
    plt.plot(out_vals,out_hist,'bv-')
    plt.legend(['In-Degree','Out-Degree'])
    plt.xlabel('Degree Density')
    plt.ylabel('Number of Nodes')
    plt.title(title)
    plt.savefig(path)
    print '{0} saved to {1}'.format(title,path),'\n'

# Plot Degree and Strength Density Distributions
plot_dd(G,'degree_dist.png','Degree Density for Food Aid Network' )
plot_dd(G,'strength_dist.png','Strength Density for Food Aid Network',weight=True)

# Problem 5: Rank top 10 countries for Clustering and Betweenness-Centrality
def get_top(data,top):
    """ 
    Retrieves top x nodes ranked by the specified centrality measure
    ---
    data: dictionary object containing networkx centrality test results
    top: number of top values to extract (ie. 10 would retrieve top 10 most central nodes)
    """
    items = data.items()
    items.sort(reverse=True, key=lambda x: x[1])
    return map(lambda x: x[0], items[:top])

# Retrieve centrality measures
clust_c = networkx.clustering(G.to_undirected()) # clustering coefficients only supported on undirected networks
bet_cen = networkx.betweenness_centrality(G)

# Retrieve results
c10 = get_top(clust_c, 10) 
b10 = get_top(bet_cen, 10) 

print 'Top-10 Ranked Nodes based on Clustering Coefficient: \n',c10,'\n'  # ['Ecuador', 'India', 'Egypt', 'Algeria', 'Cape Verde', 'Mozambique', 'Bangladesh', 'Sri Lanka', 'Mali', 'Madagascar']
print 'Top-10 Ranked Nodes based on Betweenness-Centrality: \n',b10,'\n' # ['Sri Lanka', 'Algeria', 'China', 'India', 'Egypt', 'Canada', 'Serbia and Montenegro', 'Cambodia', 'Ethiopia', 'Swaziland']
