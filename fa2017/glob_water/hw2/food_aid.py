import pandas # python package for manipulating csv files as dataframes

# Read in data
flows = pandas.read_csv('food_aid_flows_2005_edit.csv')
vwc = pandas.read_csv('commodity_vwc.csv')

# Manually rename flow country names to match VWC database
flows.loc[flows['Donor'] == 'Democratic Republic of the Congo (DRC)','Donor'] = 'DR Congo'
flows.loc[flows['Donor'] == 'Republic of Korea, the','Donor'] = 'South Korea'
flows.loc[flows['Donor'] == 'Netherlands, the','Donor'] = 'Netherlands'
flows.loc[flows['Donor'] == 'Syrian Arab Republic, the','Donor'] = 'Syria'
flows.loc[flows['Donor'] == 'United Arab Emirates, the','Donor'] = 'UAE'
flows.loc[flows['Donor'] == 'United Kingdom','Donor'] = 'UK'
flows.loc[flows['Donor'] == 'United States of America','Donor'] = 'USA'
flows.loc[flows['Donor'] == 'Lybian Arab Jamahiriya','Donor'] = 'Libya'

# Manually remove flow country names where no clear VWC match exists
flows = flows[flows['Donor'] != 'Andorra']
flows = flows[flows['Donor'] != 'European Community']
flows = flows[flows['Donor'] != 'Faeroe Islands']
flows = flows[flows['Donor'] != 'NGOs']
flows = flows[flows['Donor'] != 'OTHER']
flows = flows[flows['Donor'] != 'PRIVATE']
flows = flows[flows['Donor'] != 'Taiwan, Province of China']
flows = flows[flows['Donor'] != 'UNITED NATIONS']

# Condense VWC dataframe to one VWC value per county-commodity pair: sum(green,blue,grey)
vwc = vwc.groupby('Product description (HS)').sum()

# Shrink VWC database to include only Donor countries (all others are irrelevant)
vwc = vwc[list(flows['Donor'].unique())].reset_index()

# Create datasets for all commodities in both the flows and vwc dataframes
flowcoms = flows['Commodity'].unique()
vwccoms = vwc['Product description (HS)']

# Import package containing fuzzy logic for string matching
# Details: https://marcobonzanini.com/2015/02/25/fuzzy-string-matching-in-python/ 
from fuzzywuzzy import fuzz

# Create dictionary associating flow commodity names to VWC commodity name indexes
res = {}
ix = []
for fc in flowcoms: # iterate over commodities in flows dataframe
	vals = []
	# Compare each flows commodity to every single VWC commodity, returning a 'vals' list
	# with fuzzy string matching metric for all comparisons
	for vwcc in vwccoms: # iterate over commodities in VWC dataframe
		match = fuzz.token_sort_ratio(fc,vwcc) # metric describing fuzzy string match (b/w 0 & 100)
		vals.append(match) # add match metric to 'vals' list, unique for this commodity
	best_ix = vals.index(max(vals)) # index of VWC commodity best-match
	res[fc] = best_ix # dictionary of flow commodity w/ index of VWC commodity best-match
	ix.append(vwccoms[best_ix]) # list of best-match VWC commodities for all flow commodities

# Filter VWC dataframe to contain only commodities that match to a flow commodity
vwc = vwc[vwc['Product description (HS)'].isin(ix)]

# Iterate over donor-commodity pairs in flows database, then select corresponding 
# VWC value and multiply by location in flows database
vwc_mult = []
for index,row in flows.iterrows():
	d = row['Donor']
	c = row['Commodity']
	subdf = vwc.ix[res[c]] # select VWC of VWC commodity corresponding to flows commodity
	vwc_mult.append(subdf[d]) # add VWC to list of all VWC values

flows = flows.set_index(['Donor','Commodity']) # Ignore these columns during subsequent multiplication

# New dataframe with virtual water flows from flow data * VWC values of those commodity-donor pairs
vwc_flows = flows.mul(vwc_mult,axis=0) # Multiply each row by the next VWC value in 'vwc_mult'

print vwc_flows.values.sum() # Total VW of food aid: 11,902,838,154

vwc_flows.to_csv('vwc_flows_2005.csv')