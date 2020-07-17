import pandas
import matplotlib.pyplot as plt

df = pandas.read_csv('us_all_trade_soybean.csv',usecols=['Year','Partner','Netweight (kg)'])#,'Trade Value (US$)'])

df.columns = ['Year','Importer','Weight_kg']

# Remove self-loops and total world values
df = df[~df['Importer'].isin(['USA','World'])]

# Sum trade
df['Weight_kg'] = df['Weight_kg'].apply(pandas.to_numeric,errors='coerce')
df = df.groupby(('Year','Importer'),as_index=False)['Weight_kg'].sum()

dfsum = df.groupby('Importer',as_index=False)['Weight_kg'].sum()
dfsum = dfsum.sort_values(by=['Weight_kg'],ascending=False)
top10 = dfsum['Importer'][:10].tolist()
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
	plt.plot('Year','Weight_kg',data=df[df['Importer'] == e],linestyle=lc[i][0],color=lc[i][1],linewidth=2,label='{0}'.format(e))
plt.axvline(x=2001,linestyle=(0,(5,10)),color='black',linewidth=1,label='China accession\nto WTO')
plt.xlabel('Year')
plt.title('Soybean Imports from USA, 1991-2017')
plt.legend(loc='upper center',bbox_to_anchor=(0.5,-0.25),fancybox=False,shadow=False,ncol=4)
plt.savefig('timeseries_us_all.png')
