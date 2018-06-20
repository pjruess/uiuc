import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

plant = pandas.read_csv('data/usda_il_corn_planted_area.csv',usecols=['Year','Ag District','Value'])
phos = pandas.read_csv('data/epa_il_phosphorous.csv')

#plt.style.use('dark_background')

# Set up color scheme
ag_dists = plant['Ag District'].unique()
num_colors = len(ag_dists)
cm = plt.get_cmap('gist_rainbow')
plt.rc('lines', linewidth=.9)
#plt.rc('axes', prop_cycle=(cycler('color', [cm(1.*i/num_colors) for i in range(num_colors)])))
# cm = plt.get_cmap('gist_rainbow')
fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_prop_cycle(color=[cm(1.*i/num_colors) for i in range(num_colors)])
ax.set_prop_cycle(color=['blue','orange','cyan','lightgreen','magenta','lightgrey','darkgrey','yellow','red'])

for ad in ag_dists:
	tempplant = plant[plant['Ag District'] == ad]
	ax.plot(tempplant['Year'],tempplant['Value']/max(tempplant['Value'])*1.,label=ad,ls='-')
for ad in ag_dists:
	tempphos = phos[phos['Ag District'] == ad]
	tempphos = tempphos.groupby('Year',as_index=False)['P_mg/l'].mean() # 
	ax.plot(tempphos['Year'],tempphos['P_mg/l']/max(tempphos['P_mg/l']*2.)*1.,label='',ls='--')

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
                 box.width, box.height * 0.75])
ax.set_title('Corn in Illinois by Agricultural District\nPlanted Area (-) & Mean Phosphorous (--)')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('corn_and_phos_il_agdists.png')

plt.cla()

allplant = plant.groupby('Year',as_index=False)['Value'].sum()
allphos = phos.groupby('Year',as_index=False)['P_mg/l'].mean()
ax.plot(allplant['Year'],allplant['Value']/max(allplant['Value'])*1.,ls='-',c='blue',label='Planted Area')
ax.plot(allphos['Year'],allphos['P_mg/l']/max(allphos['P_mg/l']*2.)*1.,ls='--',c='blue',label='Harvested Area')
ax.set_title('Total Corn in Illinois\nPlanted Area (-) & Mean Phosphorous (--)')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('corn_and_phos_il_total.png')

plt.cla()

for ad in ag_dists:
	tempphos = phos[phos['Ag District'] == ad]
	tempphos = tempphos.groupby('Year',as_index=False)['P_mg/l'].mean() # 
	ax.plot(tempphos['Year'],tempphos['P_mg/l'],label='',ls='-')

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
                 box.width, box.height * 0.75])
ax.set_title('Mean Phosphorous in Illinois by Agricultural District')
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=8, axis='y')
plt.savefig('phos_il_agdists.png')

plt.cla()