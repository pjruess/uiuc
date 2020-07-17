import pandas
import matplotlib.pyplot as plt

data = pandas.read_csv('us_soybean_data.csv',usecols=['Year','Data Item','Value'],thousands=',')

trade = pandas.read_csv('us_china_trade_soybean.csv',usecols=['Year','Netweight (kg)'])#,'Trade Value (US$)'])

# Sum trade
trade.columns = ['Year','Weight_kg']
trade['Weight_kg'] = trade['Weight_kg'].apply(pandas.to_numeric,errors='coerce')
trade = trade.groupby('Year',as_index=False)['Weight_kg'].sum()

# Data Item pivot
data = data.pivot(index='Year',columns='Data Item',values='Value').reset_index()
data.columns = ['Year','Harvest_Ac','Planted_Ac','Production_$','Production_Bu','Yield_BuAc']

# Merge dataframes
df = pandas.merge(data,trade,how='outer',on='Year')

#df[['Harvest_Ac','Production_Bu','Yield_BuAc','Weight_kg','Planted_Ac']] = df[['Harvest_Ac','Production_Bu','Yield_BuAc','Weight_kg','Planted_Ac']].apply(pandas.to_numeric,errors='coerce')

df['Harvest_Ac_Norm'] = ( df['Harvest_Ac'] - df['Harvest_Ac'].min() ) / ( df['Harvest_Ac'].max() - df['Harvest_Ac'].min() )
df['Production_Bu_Norm'] = ( df['Production_Bu'] - df['Production_Bu'].min() ) / ( df['Production_Bu'].max() - df['Production_Bu'].min() )
df['Yield_BuAc_Norm'] = ( df['Yield_BuAc'] - df['Yield_BuAc'].min() ) / ( df['Yield_BuAc'].max() - df['Yield_BuAc'].min() )
df['Weight_kg_Norm'] = ( df['Weight_kg'] - df['Weight_kg'].min() ) / ( df['Weight_kg'].max() - df['Weight_kg'].min() )
df['Planted_Ac_Norm'] = ( df['Planted_Ac'] - df['Planted_Ac'].min() ) / ( df['Planted_Ac'].max() - df['Planted_Ac'].min() )

df = df[df['Year'] >= 1990]

#print df[['Harvest_Ac_Norm','Production_']].head()

# Plot figures
fig = plt.figure()
ax = fig.add_subplot(111)

# Shrink Axis height by 10% at bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.15, box.width, box.height * 0.85])

plt.plot('Year','Weight_kg_Norm',data=df,linestyle='-',color='blue',linewidth=2,label='Exports to China (kg)')
#plt.plot('Year','Harvest_Ac_Norm',data=df,linestyle='--',color='black',linewidth=2,label='US Harvest (Ac)')
plt.plot('Year','Planted_Ac_Norm',data=df,linestyle=':',color='green',linewidth=2,label='Planted Area (Ac)')
plt.plot('Year','Production_Bu_Norm',data=df,linestyle='--',color='red',linewidth=2,label='Production (Bu)')
plt.plot('Year','Yield_BuAc_Norm',data=df,linestyle='-.',color='orange',linewidth=2,label='Yield (Bu/Ac)')
plt.axvline(x=2001,linestyle=(0,(5,10)),color='black',linewidth=1,label='China accession\nto WTO')
plt.xlabel('Year')
plt.title('Normalized U.S. Soybean Variables, 1990-2017')
plt.legend(loc='upper center',bbox_to_anchor=(0.5,-0.15),fancybox=False,shadow=False,ncol=3)
plt.savefig('timeseries_us.png')
