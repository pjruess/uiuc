import pandas
import matplotlib.pyplot as plt

plt.rc('lines', linewidth=.9)

fig = plt.figure()
ax = fig.add_subplot(111)

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
				box.width, box.height * 0.75])

botlim = 1973
toplim = 2017
years = range(botlim,toplim+1)

foodpol = [0] * len(years)
foodpol[years.index(1996)] = -1
foodpol[years.index(1997)] = 1
foodpol[years.index(2014)] = 1

enpol = [0] * len(years)
enpol[years.index(2004)] = 1
enpol[years.index(2005)] = 1
enpol[years.index(2007)] = 1
enpol[years.index(2011)] = -1

drought = [0] * len(years)
drought[years.index(1976)] = -1
drought[years.index(1983)] = -1
drought[years.index(1988)] = -1
drought[years.index(1989)] = -1
drought[years.index(2005)] = -1
drought[years.index(2012)] = -1

# Plot bars
ax.plot(years,[0]*len(years),color='black')
ax.bar(years,foodpol,width=1,color='palegreen',label='Food Policy')
ax.bar(years,enpol,width=1,color='paleturquoise',label='Energy Policy')
ax.bar(years,drought,width=1,color='moccasin',label='Droughts')

cornplant = pandas.read_csv('data/usda_il_corn_planted_area.csv',usecols=['Year','Value'])
soyplant = pandas.read_csv('data/usda_il_soy_planted_area.csv',usecols=['Year','Value'])
cornharv = pandas.read_csv('data/usda_il_corn_harvested_area.csv',usecols=['Year','Value'])
soyharv = pandas.read_csv('data/usda_il_soy_harvested_area.csv',usecols=['Year','Value'])

allcornplant = cornplant.groupby('Year',as_index=False)['Value'].sum()
allsoyplant = soyplant.groupby('Year',as_index=False)['Value'].sum()
allcornharv = cornharv.groupby('Year',as_index=False)['Value'].sum()
allsoyharv = soyharv.groupby('Year',as_index=False)['Value'].sum()

# Filter by years
allcornplant = allcornplant[allcornplant['Year'].isin(years)]
allcornplant['Value'] = 2. * ( ( allcornplant['Value'] - allcornplant['Value'].min() ) / ( allcornplant['Value'].max() - allcornplant['Value'].min() ) ) - 1.

allsoyplant = allsoyplant[allsoyplant['Year'].isin(years)]
allsoyplant['Value'] = 2. * ( ( allsoyplant['Value'] - allsoyplant['Value'].min() ) / ( allsoyplant['Value'].max() - allsoyplant['Value'].min() ) ) - 1.

allcornharv = allcornharv[allcornharv['Year'].isin(years)]
allcornharv['Value'] = 2. * ( ( allcornharv['Value'] - allcornharv['Value'].min() ) / ( allcornharv['Value'].max() - allcornharv['Value'].min() ) ) - 1.

allsoyharv = allsoyharv[allsoyharv['Year'].isin(years)]
allsoyharv['Value'] = 2. * ( ( allsoyharv['Value'] - allsoyharv['Value'].min() ) / ( allsoyharv['Value'].max() - allsoyharv['Value'].min() ) ) - 1.

ax.plot(allcornplant['Year'],allcornplant['Value'],ls='-',c='orange',label='Planted Corn')
ax.plot(allsoyplant['Year'],allsoyplant['Value'],ls='-',c='green',label='Planted Soy')
ax.plot(allcornharv['Year'],allcornharv['Value'],ls='--',c='orange',label='Harvested Corn')
ax.plot(allsoyharv['Year'],allsoyharv['Value'],ls='--',c='green',label='Harvested Soy')

ax.set_yticks([-1,0,1])
ax.set_title('Corn and Soybean Planted Areas in Illinois\nwith Timeline of Corn-related Legislature')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('timeline_corn_soy.png')
