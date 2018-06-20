import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

plant = pandas.read_csv('data/usda_il_corn_planted_area.csv',usecols=['Year','Ag District','Value'])
harv = pandas.read_csv('data/usda_il_corn_harvested_area.csv',usecols=['Year','Ag District','Value'])

ag_dists = plant['Ag District'].unique()
num_colors = len(ag_dists)
cm = plt.get_cmap('gist_rainbow')

#plt.style.use('dark_background')

plt.rc('lines', linewidth=.9)

#plt.rc('axes', prop_cycle=(cycler('color', [cm(1.*i/num_colors) for i in range(num_colors)])))
# cm = plt.get_cmap('gist_rainbow')
fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_prop_cycle(color=[cm(1.*i/num_colors) for i in range(num_colors)])
ax.set_prop_cycle(color=['blue','orange','cyan','lightgreen','magenta','lightgrey','darkgrey','yellow','red'])

for ad in ag_dists:
	tempplant = plant[plant['Ag District'] == ad]
	ax.plot(tempplant['Year'],tempplant['Value'],label=ad,ls='-')
# for ad in ag_dists:
# 	tempharv = harv[harv['Ag District'] == ad]
# 	ax.plot(tempharv['Year'],tempharv['Value'],label='',ls='--')

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
                 box.width, box.height * 0.75])
ax.set_title('Corn in Illinois by Agricultural District')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('corn_il_agdists.png')

plt.cla()

allplant = plant.groupby('Year',as_index=False)['Value'].sum()
allharv = harv.groupby('Year',as_index=False)['Value'].sum()
ax.plot(allplant['Year'],allplant['Value'],ls='-',c='blue',label='Planted Area')
ax.plot(allharv['Year'],allharv['Value'],ls='--',c='blue',label='Harvested Area')
ax.set_title('Total Corn in Illinois')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('corn_il_total.png')
