import pandas
import matplotlib.pyplot as plt

df = pandas.read_csv('corn_soy_sorghum_wheat_us_total_production.csv',usecols=['Program','Year','Commodity','Value'])

df = df[df['Program'] == 'SURVEY']

df['Value'] = df['Value'].apply(lambda x: pandas.to_numeric(x.replace(',',''),errors='coerce'))

corn = df[df['Commodity'] == 'CORN']
sorghum = df[df['Commodity'] == 'SORGHUM']
soybeans = df[df['Commodity'] == 'SOYBEANS']
wheat = df[df['Commodity'] == 'WHEAT']

corn['Value'] = ( corn['Value'] - corn['Value'].min() ) / ( corn['Value'].max() - corn['Value'].min() )
sorghum['Value'] = ( sorghum['Value'] - sorghum['Value'].min() ) / ( sorghum['Value'].max() - sorghum['Value'].min() )
soybeans['Value'] = ( soybeans['Value'] - soybeans['Value'].min() ) / ( soybeans['Value'].max() - soybeans['Value'].min() )
wheat['Value'] = ( wheat['Value'] - wheat['Value'].min() ) / ( wheat['Value'].max() - wheat['Value'].min() )

# Plot figures
fig = plt.figure()
ax = fig.add_subplot(111)

# Shrink Axis height by 10% at bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25, box.width, box.height * 0.75])

plt.plot('Year','Value',data=corn,linestyle='-',color='blue',linewidth=2,label='Corn')
plt.plot('Year','Value',data=sorghum,linestyle=':',color='red',linewidth=2,label='Sorghum')
plt.plot('Year','Value',data=soybeans,linestyle='--',color='green',linewidth=2,label='Soybeans')
plt.plot('Year','Value',data=wheat,linestyle='-.',color='orange',linewidth=2,label='Wheat')
plt.axvline(x=2001,linestyle=(0,(5,10)),color='black',linewidth=1,label='China accession\nto WTO')
plt.xlabel('Year')
plt.title('Normalized U.S. Crop Production, 1991-2017')
plt.legend(loc='upper center',bbox_to_anchor=(0.5,-0.25),fancybox=False,shadow=False,ncol=3)
plt.savefig('us_grain_production.png')
