# Import necessary libraries
import pandas
import networkx
import matplotlib.pyplot as plt
import matplotlib
import numpy
#plt.rcParams['axes.formatter.useoffset'] = False
#plt.rcParams['axes.formatter.min_exponent'] = 4

def metrics(data):
    df = pandas.read_csv('results/{0}_edgelist_clean.csv'.format(data),usecols=['ori','des','total'])
    
    print df.shape
    df = df[df['total'] > 0]
    print df.shape
    
    ### CALCULATE NETWORK STATISTICS ###
    
    
    
    edges = zip( df['ori'], df['des'], df['total'] ) # reorganize edgelist as origin/destination/weight 
    
    # Create networkx graph of data
    G = networkx.DiGraph() # create directed graph
    G.add_weighted_edges_from(edges) # add edges from edge-list
    
    # Create visual representation of graph for fun
    # f = plt.figure()
    # networkx.draw( G, ax=f.add_subplot(111) )
    # f.savefig('network.pdf')
    
    # Number of nodes and edges in graph, and graph density
    n = G.number_of_nodes()
    e = G.number_of_edges()
    d = networkx.density(G)
    print 'Number of Nodes: ', n
    print 'Number of Edges: ', e
    print 'Network Density: ', d
    
    # Manually verify density
    # Note that this is a directed graph, so possible combinations is NOT divided by 2 (as in undirected)
    d_test = float( float(e) / ( float(n) * ( float(n) - 1 ) ) )
    #print 'Density Check:   ',d_test,'\n' # 0.0413237924866
    
    #deg = G.degree().values()
    deg = [val for (node,val) in G.degree()]
    deg_seq = sorted(deg,reverse=True)
    deg_probs = numpy.arange(1,len(deg_seq)+1)/(float(len(deg_seq)))
    #deg_in = G.in_degree().values()
    deg_in = [val for (node,val) in G.out_degree()]
    deg_in_seq = sorted(deg_in,reverse=True)
    deg_in_probs = numpy.arange(1,len(deg_in_seq)+1)/(float(len(deg_in_seq)))
    #deg_out = G.out_degree().values()
    deg_out = [val for (node,val) in G.in_degree()]
    deg_out_seq = sorted(deg_out,reverse=True)
    deg_out_probs = numpy.arange(1,len(deg_out_seq)+1)/(float(len(deg_out_seq)))
    
    #stn = G.degree(weight='weight').values()
    stn = [val for (node,val) in G.degree(weight='weight')]
    stn_seq = sorted(stn,reverse=True)
    stn_probs = numpy.arange(1,len(stn_seq)+1)/(float(len(stn_seq)))
    #stn_in = G.in_degree(weight='weight').values()
    stn_in = [val for (node,val) in G.in_degree(weight='weight')]
    stn_in_seq = sorted(stn_in,reverse=True)
    stn_in_probs = numpy.arange(1,len(stn_in_seq)+1)/(float(len(stn_in_seq)))
    #stn_out = G.out_degree(weight='weight').values()
    stn_out = [val for (node,val) in G.out_degree(weight='weight')]
    stn_out_seq = sorted(stn_out,reverse=True)
    stn_out_probs = numpy.arange(1,len(stn_out_seq)+1)/(float(len(stn_out_seq)))
    
    fig,ax = plt.subplots(3,3)
    
    ax[0,0].step(deg_seq,deg_probs,lw=1,c='k')
    ax[0,0].set_xlabel('Degree')
    ax[0,0].set_ylabel('Count')
    ax[0,0].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[0,0].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[1,0].step(deg_in_seq,deg_in_probs,lw=1,c='k')
    ax[1,0].set_xlabel('Degree')
    ax[1,0].set_ylabel('Count')
    ax[1,0].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[1,0].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[2,0].step(deg_out_seq,deg_out_probs,lw=1,c='k')
    ax[2,0].set_xlabel('Degree')
    ax[2,0].set_ylabel('Count')
    ax[2,0].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[2,0].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[0,1].step(stn_seq,stn_probs,lw=1,c='k')
    ax[0,1].set_xlabel('Strength')
    ax[0,1].set_ylabel('Count')
    ax[0,1].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[0,1].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[1,1].step(stn_in_seq,stn_in_probs,lw=1,c='k')
    ax[1,1].set_xlabel('Strength')
    ax[1,1].set_ylabel('Count')
    ax[1,1].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[1,1].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[2,1].step(stn_out_seq,stn_out_probs,lw=1,c='k')
    ax[2,1].set_xlabel('Strength')
    ax[2,1].set_ylabel('Count')
    ax[2,1].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[2,1].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    
    ax[0,2].scatter(deg,stn,s=1,c='k')
    ax[0,2].set_xlabel('Degree')
    ax[0,2].set_ylabel('Strength')
    ax[0,2].set_xscale('log')
    ax[0,2].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[0,2].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    ax[0,2].set_yscale('log')
    
    ax[1,2].scatter(deg_in,stn_in,s=1,c='k')
    ax[1,2].set_xlabel('Degree')
    ax[1,2].set_ylabel('Strength')
    ax[1,2].set_xscale('log')
    ax[1,2].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[1,2].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    ax[1,2].set_yscale('log')
    
    ax[2,2].scatter(deg_out, stn_out,s=1,c='k')
    ax[2,2].set_xlabel('Degree')
    ax[2,2].set_ylabel('Strength')
    ax[2,2].set_xscale('log')
    ax[2,2].get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax[2,2].get_xaxis().set_minor_formatter(matplotlib.ticker.NullFormatter())
    ax[2,2].set_yscale('log')
    
    plt.tight_layout()
    plt.savefig('figures/fig5_{0}.png'.format(data))

metrics('faf')
metrics('county')

### SCRAPS ###

## Plot Degree Distribution and Strength Distrbution
#def plot_dd(data,path,title,deg_type='',weight=False):
#    """ 
#    Plots degree distribution of a networkx graph object
#    ---
#    data: networkx graph object
#    path: file path to save to
#    title: title of plot
#    weight: if True, add edge wights
#    """
#    if weight: w = 'weight'
#    else: w = ''
#
#    if deg_type == 'in': # add weights to in- and out-degrees
#        deg_seq = sorted((data.in_degree(weight=w).values()),reverse=True)
#    elif deg_type == 'out': 
#        deg_seq = sorted((data.out_degree(weight=w).values()),reverse=True)
#    else: 
#        deg_seq = sorted((data.degree(weight=w).values()),reverse=True)
#
#    # Plot data
#    cnt = numpy.arange(1,len(deg_seq)+1)
#    probs = cnt/(float(len(deg_seq)))
#    plt.step(deg_seq,probs)#,marker='o')
#    plt.xlabel('Node Degree')
#    plt.ylabel('Cumulative Count')
#    plt.title(title)
#
#    plt.tight_layout()
#    plt.savefig(path)
#    plt.close()
#    print '{0} saved to {1}'.format(title,path),'\n'
#
### Plot Degree and Strength Distributions (undirected)
##plot_dd(G,'figures/degree_dist.png','Degree Density for FAF')
##plot_dd(G,'figures/strength_dist.png','Strength Density for FAF',weight=True)
### Plot Degree and Strength Distributions (in-Degree)
##plot_dd(G,'figures/degree_in_dist.png','In-Degree Density for FAF',deg_type='in')
##plot_dd(G,'figures/strength_in_dist.png','In-Strength Density for FAF',deg_type='in',weight=True)
### Plot Degree and Strength Distributions (out-Degree)
##plot_dd(G,'figures/degree_out_dist.png','Out-Degree Density for FAF',deg_type='out')
##plot_dd(G,'figures/strength_out_dist.png','Out-Strength Density for FAF',deg_type='out',weight=True)
#
#
#def plot_dvs(data,path,title,deg_type=''):
#    """ 
#    Plots degree distribution of a networkx graph object
#    ---
#    data: networkx graph object
#    path: file path to save to
#    title: title of plot
#    weight: if True, add edge wights
#    """
#    if deg_type == 'in': # add weights to in- and out-degrees
#        degree = data.in_degree().values()
#        strength = data.in_degree(weight='weight').values()
#    elif deg_type == 'out': 
#        degree = data.out_degree().values()
#        strength = data.out_degree(weight='weight').values()
#    else: 
#        degree = data.degree().values()
#        strength = data.degree(weight='weight').values()
#
#    # Plot data
#    plt.scatter(degree,strength)#,marker='o')
#    plt.xlabel('Node Degree')
#    plt.ylabel('Node Strength')
#    ax = plt.gca()
#    ax.set_xscale('log')
#    ax.set_yscale('log')
#    plt.title(title)
#
#    plt.tight_layout()
#    plt.savefig(path)
#    plt.close()
#    print '{0} saved to {1}'.format(title,path),'\n'
#
## Plot Degree vs. Strength
#plot_dvs(G,'figures/deg_v_str.png','Degree vs. Strength for FAF')
#plot_dvs(G,'figures/deg_v_str_in.png','In-Degree vs. In-Strength for FAF',deg_type='in')
#plot_dvs(G,'figures/deg_v_str_out.png','Out-Degree vs. Out-Strength for FAF',deg_type='out')
