import pandas
import matplotlib.pyplot as plt

df = pandas.read_csv('all_china_trade_soybean.csv',usecols=['Year','Reporter','Netweight (kg)'])#,'Trade Value (US$)'])

df.columns = ['Year','Exporter','Weight_kg']

# Remove self-loops (trade from China to Hong Kong, etc.)
df = df[~df['Exporter'].isin(['China','China, Hong Kong SAR','China, Macao SAR'])]

# Sum trade
df['Weight_kg'] = df['Weight_kg'].apply(pandas.to_numeric,errors='coerce')
df = df.groupby(('Year','Exporter'),as_index=False)['Weight_kg'].sum()

dfsum = df.groupby('Exporter',as_index=False)['Weight_kg'].sum()
dfsum = dfsum.sort_values(by=['Weight_kg'],ascending=False)
top10 = dfsum['Exporter'][:10].tolist()
print top10

# Plot figures
fig = plt.figure()
ax = fig.add_subplot(111)

# Shrink Axis height by 10% at bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25, box.width, box.height * 0.75])

# Linestyles and colors
lc = [['-','blue'],
		[':','green'],
		['--','purple'],
		['-.','brown'],
		['-','red'],
		[':','orange'],
		['--','gray'],
		['-.','cyan'],
		[':','yellow'],
		['--','pink']]

for i,e in enumerate(top10):
	plt.plot('Year','Weight_kg',data=df[df['Exporter'] == e],linestyle=lc[i][0],color=lc[i][1],linewidth=2,label='{0}'.format(e))
plt.axvline(x=2001,linestyle=(0,(5,10)),color='black',linewidth=1,label='China accession\nto WTO')
plt.xlabel('Year')
plt.title('Soybean Exports to China, 1988-2017')
plt.legend(loc='upper center',bbox_to_anchor=(0.5,-0.25),fancybox=False,shadow=False,ncol=4)
plt.savefig('timeseries_all_china.png')
