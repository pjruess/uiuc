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

df = pandas.read_csv('data/corn_soy_il_yield.csv',usecols=['Year','Data Item','Value'])

corn_g = df[df['Data Item'] == 'CORN, GRAIN - YIELD, MEASURED IN BU / ACRE']
corn_s = df[df['Data Item'] == 'CORN, SILAGE - YIELD, MEASURED IN TONS / ACRE']
soy = df[df['Data Item'] == 'SOYBEANS - YIELD, MEASURED IN BU / ACRE']

# Filter by years
corn_g = corn_g.groupby('Year',as_index=False)['Value'].sum()
corn_g = corn_g[corn_g['Year'].isin(years)]

corn_s = corn_s.groupby('Year',as_index=False)['Value'].sum()
corn_s = corn_s[corn_s['Year'].isin(years)]

soy = soy.groupby('Year',as_index=False)['Value'].sum()
soy = soy[soy['Year'].isin(years)]

# Normlize
cmax = max( corn_g['Value'].max(), corn_s['Value'].max(), soy['Value'].max() )
cmin = min( corn_g['Value'].min(), corn_s['Value'].min(), soy['Value'].min() )
corn_g['Value'] = (corn_g['Value'] - corn_g['Value'].min()) / (corn_g['Value'].max() - corn_g['Value'].min()) * 1.
corn_s['Value'] = (corn_s['Value'] - corn_s['Value'].min()) / (corn_s['Value'].max() - corn_s['Value'].min()) * 1.
soy['Value'] = (soy['Value'] - soy['Value'].min()) / (soy['Value'].max() - soy['Value'].min()) * 1.

# Plot Results
ax.plot(corn_g['Year'],corn_g['Value'],ls='-',c='orange',label='Corn Grain')
ax.plot(corn_s['Year'],corn_s['Value'],ls='--',c='orange',label='Corn Silage')
ax.plot(soy['Year'],soy['Value'],ls='-',c='green',label='Soybeans')

ax.set_yticks([0,1])
ax.set_title('Corn and Soybean Yield in IL')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('corn_soy_yield.png')
