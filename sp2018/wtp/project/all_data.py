import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

total = pandas.read_csv('corn_data/usda_il_all_planted_area.csv',usecols=['Year','Ag District','Commodity','Value'])
# Soy only available beginning 1973: remove 1972 from rest of data
total = total[total['Year'] != 1972]

corn = total[total['Commodity'] == 'CORN']
corn.drop('Commodity',axis=1,inplace=True)
soy = total[total['Commodity'] == 'SOYBEANS']
soy.drop('Commodity',axis=1,inplace=True)
other = total[~total['Commodity'].isin(['CORN','SOYBEANS'])]
#other.drop('Commodity',axis=1,inplace=True)
other = other.groupby(['Year','Ag District'],as_index=False)['Value'].sum()

ag_dists = total['Ag District'].unique()

num_colors = len(ag_dists)
cm = plt.get_cmap('gist_rainbow')

plt.rc('lines', linewidth=.9)
# plt.rc('axes', prop_cycle=(cycler('color', [cm(1.*i/num_colors) for i in range(num_colors)])))
# cm = plt.get_cmap('gist_rainbow')

# plt.style.use('dark_background')

fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_prop_cycle(color=[cm(1.*i/num_colors) for i in range(num_colors)])
# ax.set_prop_cycle(color=['blue','orange','cyan','lightgreen','magenta','lightgrey','darkgrey','yellow','red'])

for ad in ag_dists:
	tempcorn = corn[corn['Ag District'] == ad]
	ax.plot(tempcorn['Year'],tempcorn['Value'],label=ad,ls='-')
for ad in ag_dists:
	tempsoy = soy[soy['Ag District'] == ad]
	ax.plot(tempsoy['Year'],tempsoy['Value'],label='',ls='--')
for ad in ag_dists:
	tempother = other[other['Ag District'] == ad]
	ax.plot(tempother['Year'],tempother['Value'],label='',ls=':')

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
                 box.width, box.height * 0.75])
ax.set_title('Corn (-), Soybeans (--), and Other (:)\nPlanted Area (Acres) in Illinois by Agricultural District')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('corn_soy_other_il_agdists.pdf')

# New plot
plt.cla()
allcorn = corn.groupby('Year',as_index=False)['Value'].sum()
allsoy = soy.groupby('Year',as_index=False)['Value'].sum()
allother = other.groupby('Year',as_index=False)['Value'].sum()
ax.plot(allcorn['Year'],allcorn['Value'],ls='-',c='blue',label='Corn')
ax.plot(allsoy['Year'],allsoy['Value'],ls='--',c='blue',label='Soybeans')
ax.plot(allother['Year'],allother['Value'],ls=':',c='blue',label='Other Crops')
ax.set_title('Corn (-), Soybeans (--), and Other (:)\nPlanted Area (Acres) in Illinois (Total)')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('corn_soy_other_il_total.pdf')

# New plot
plt.cla()
alltotal = total.groupby('Year',as_index=False)['Value'].sum()
alltotal['Corn'] = allcorn['Value']/alltotal['Value']*1.
alltotal['Soybeans'] = allsoy['Value']/alltotal['Value']*1.
alltotal['Other'] = allother['Value']/alltotal['Value']*1.

import numpy
ind = alltotal['Year'].unique() # the x locations for the groups
width = 0.5 # the width of the bars: can also be len(x) sequence

p1 = plt.bar(ind, alltotal['Corn'], width,label='Corn',color='orange')
p2 = plt.bar(ind, alltotal['Soybeans'], width, bottom=alltotal['Corn'],label='Soybeans',color='green')
p3 = plt.bar(ind, alltotal['Other'], width, bottom=(alltotal['Corn'] + alltotal['Soybeans']),label='Other Crops',color='grey')

plt.ylabel('Planted Area (%)')
plt.title('Corn, Soybeans, and Other\nPercent of Planted Area (Acres) in Illinois (Total)')
#plt.xticks(ind, ('G1', 'G2', 'G3', 'G4', 'G5'))
#plt.yticks(np.arange(0, 81, 10))
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)

# ax.locator_params(nbins=6, axis='y')
# plt.tight_layout()
plt.savefig('all_il_percent_total.png')