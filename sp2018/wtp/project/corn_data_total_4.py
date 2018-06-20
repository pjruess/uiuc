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

corn = pandas.read_csv('data/usda_il_corn_planted_area.csv',usecols=['Year','Value'])
soy = pandas.read_csv('data/usda_il_soy_planted_area.csv',usecols=['Year','Value'])

prices = pandas.read_csv('data/crop_price.csv')

subs = pandas.read_csv('data/crop_subsidies_simplified.csv',usecols=['year','corn_il_total','soy_il_total'])#,'il_mil$'])
# subs['corn_il_total'] = subs['corn_il_total']/subs['il_mil$']*1.
# subs['soy_il_total'] = subs['soy_il_total']/subs['il_mil$']*1.
# subs['others_il_total'] = subs['others_il_total']/subs['il_mil$']*1.
# subs.drop('il_mil$',axis=1,inplace=True)

# Phosphorus Data
phos = pandas.read_csv('data/epa_il_phosphorous.csv',usecols=['P_mg/l','Year'])

# Precipitation Data
# url = 'https://www.ncdc.noaa.gov/cag/statewide/time-series/11-pcp-12-12-1895-2018.csv'
# pcp = pandas.read_csv(url,skiprows=3)
# pcp['Year'] = pcp['Date'].apply(lambda x: int(str(x)[:4]))
# pcp.drop(['Date'],axis=1,inplace=True)

# Filter by years
corn = corn.groupby('Year',as_index=False)['Value'].sum()
corn = corn[corn['Year'].isin(years)]

soy = soy.groupby('Year',as_index=False)['Value'].sum()
soy = soy[soy['Year'].isin(years)]

prices = prices[prices['Year'].isin(years)]

subs = subs[subs['year'].isin(years)]

phos = phos.groupby('Year',as_index=False)['P_mg/l'].mean()
phos = phos[phos['Year'].isin(years)]

# pcp = pcp[pcp['Year'].isin(years)]

# Normalize
plantmax = max( corn['Value'].max(), soy['Value'].max() )
plantmin = min( corn['Value'].min(), soy['Value'].min() )
corn['Value'] = 2. * ( ( corn['Value'] - plantmin ) / ( plantmax - plantmin ) ) - 1.
soy['Value'] = 2. * ( ( soy['Value'] - plantmin ) / ( plantmax - plantmin ) ) - 1.

pricemax = max( prices['Corn'].max(), prices['Soybeans'].max() )
pricemin = min( prices['Corn'].min(), prices['Soybeans'].min() )
prices['Corn'] = 2. * ( ( prices['Corn'] - pricemin ) / ( pricemax - pricemin ) ) - 1.
prices['Soybeans'] = 2. * ( ( prices['Soybeans'] - pricemin ) / ( pricemax - pricemin ) ) - 1.

submax = max( subs['corn_il_total'].max(), subs['soy_il_total'].max() )
submin = min( subs['corn_il_total'].min(), subs['soy_il_total'].min() )
subs['corn_il_total'] = 2. * ( ( subs['corn_il_total'] - submin ) / ( submax - submin ) ) - 1.
subs['soy_il_total'] = 2. * ( ( subs['soy_il_total'] - submin ) / ( submax - submin ) ) - 1.

phos['P_mg/l'] = 2. * ( ( phos['P_mg/l'] - phos['P_mg/l'].min() ) / ( phos['P_mg/l'].max() - phos['P_mg/l'].min() ) ) - 1.

# pcp['Value'] = 2. * ( ( pcp['Value'] - pcp['Value'].min() ) / ( pcp['Value'].max() - pcp['Value'].min() ) ) - 1.

# Plot Results
# ax.plot(pcp['Year'],pcp['Value'],ls='-',c='blue',label='Precipitation')
ax.plot(phos['Year'],phos['P_mg/l'],ls='-',c='purple',label='Phosphorus (mg/L)')
ax.plot(corn['Year'],corn['Value'],ls='-',c='orange',label='Planted Corn (Acres)')
ax.plot(soy['Year'],soy['Value'],ls='-',c='green',label='Planted Soy (Acres)')
ax.plot(prices['Year'],prices['Corn'],ls='--',c='orange',label='Corn Price ($/Bu)')
ax.plot(prices['Year'],prices['Soybeans'],ls='--',c='green',label='Soy Price ($/Bu)')
ax.plot(subs['year'],subs['corn_il_total'],ls=':',c='orange',label='Corn Subsidies (Million $)')
ax.plot(subs['year'],subs['soy_il_total'],ls=':',c='green',label='Soy Subsidies (Million $)')

ax.set_yticks([-1,0,1])
ax.set_title('Corn and Soybean Planted Areas, Prices, and Subsidies in IL\nwith Precipitation, Phosphorus, and Timeline of Corn-related Legislature')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('timeline_corn_soy_prices_subs_phos_pcp.png')
