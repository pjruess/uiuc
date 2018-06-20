import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

cornplant = pandas.read_csv('data/usda_il_corn_planted_area.csv',usecols=['Year','Ag District','Value'])
cornharv = pandas.read_csv('data/usda_il_corn_harvested_area.csv',usecols=['Year','Ag District','Value'])
soyplant = pandas.read_csv('data/usda_il_soy_planted_area.csv',usecols=['Year','Ag District','Value'])
soyharv = pandas.read_csv('data/usda_il_soy_harvested_area.csv',usecols=['Year','Ag District','Value'])

ag_dists = cornplant['Ag District'].unique()
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
# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
shrink = 0.75
ax.set_position([box.x0, box.y0 + box.height * (1.-shrink),
				box.width, box.height * shrink])
### NEW PLOT ###

for ad in ag_dists:
	tempcorn = cornplant[cornplant['Ag District'] == ad]
	ax.plot(tempcorn['Year'],tempcorn['Value'],label=ad,ls='-')
for ad in ag_dists:
	tempsoy = soyplant[soyplant['Ag District'] == ad]
	ax.plot(tempsoy['Year'],tempsoy['Value'],label='',ls='--')


ax.set_title('Corn (-) & Soy (--) Planted Area\nin Illinois by Agricultural District')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('corn_soy_il_planted_agdists.png')

plt.cla()

### NEW PLOT ###

for ad in ag_dists:
	tempcorn = cornharv[cornharv['Ag District'] == ad]
	ax.plot(tempcorn['Year'],tempcorn['Value'],label=ad,ls='-')
for ad in ag_dists:
	tempsoy = soyharv[soyharv['Ag District'] == ad]
	ax.plot(tempsoy['Year'],tempsoy['Value'],label='',ls='--')

ax.set_title('Corn (-) & Soy (--) Harvested Area\nin Illinois by Agricultural District')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('corn_soy_il_harvested_agdists.png')

plt.cla()

### NEW PLOT ###

allcornplant = cornplant.groupby('Year',as_index=False)['Value'].sum()
allcornharv = cornharv.groupby('Year',as_index=False)['Value'].sum()
ax.plot(allcornplant['Year'],allcornplant['Value'],ls='-',c='orange',label='Corn Planted Area')
ax.plot(allcornharv['Year'],allcornharv['Value'],ls='--',c='orange',label='Corn Harvested Area')

allsoyplant = soyplant.groupby('Year',as_index=False)['Value'].sum()
allsoyharv = soyharv.groupby('Year',as_index=False)['Value'].sum()
ax.plot(allsoyplant['Year'],allsoyplant['Value'],ls='-',c='green',label='Soy Planted Area')
ax.plot(allsoyharv['Year'],allsoyharv['Value'],ls='--',c='green',label='Soy Harvested Area')
ax.set_title('Total Corn & Soy\nPlanted & Harvested Area in Illinois')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=2)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('corn_soy_il_total.png')