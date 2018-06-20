import pandas
import matplotlib.pyplot as plt
import numpy

df = pandas.read_csv('data/crop_subsidies_simplified.csv')

fig,ax=plt.subplots()

# Convert to percentages
df['corn_us_total'] = df['corn_us_total']/df['us_mil$']*1.
df['soy_us_total'] = df['soy_us_total']/df['us_mil$']*1.
df['others_us_total'] = df['others_us_total']/df['us_mil$']*1.
df['corn_il_total'] = df['corn_il_total']/df['il_mil$']*1.
df['soy_il_total'] = df['soy_il_total']/df['il_mil$']*1.
df['others_il_total'] = df['others_il_total']/df['il_mil$']*1.
df.drop('us_mil$',axis=1,inplace=True)
df.drop('il_mil$',axis=1,inplace=True)
print df.head()

ind = df['year'].unique() # the x locations for the groups
width = 0.5 # the width of the bars: can also be len(x) sequence
# plt.figure(figsize=(10,6))

# plt.plot(ind,df['corn_us_total'],label='Corn, US',color='orange',ls='-')
# plt.plot(ind,df['soy_us_total'],label='Soybeans, US',color='green',ls='-')
# plt.plot(ind,df['others_us_total'],label='Other Crops, US',color='grey',ls='-')

plt.bar(ind, df['corn_il_total'], width,label='Corn, IL',color='orange')
plt.bar(ind, df['soy_il_total'], width, bottom=df['corn_il_total'],label='Soybeans, IL',color='green')
plt.bar(ind, df['others_il_total'], width, bottom=(df['corn_il_total'] + df['soy_il_total']),label='Other Crops, IL',color='grey')

plt.plot(ind,df['corn_us_total'],label='Corn, US',color='orange',ls='--')
plt.plot(ind,df['corn_us_total'] + df['soy_us_total'],label='Soybeans, US',color='green',ls='--')
plt.plot(ind,df['corn_us_total'] + df['soy_us_total'] + df['others_us_total'],label='Other Crops, US',color='grey',ls='--')

# plt.bar(ind+.2, df['corn_il_total'], width,label='Corn, IL',color='orange')
# plt.bar(ind+.2, df['soy_il_total'], width, bottom=df['corn_il_total'],label='Soybeans, IL',color='green')
# plt.bar(ind+.2, df['others_il_total'], width, bottom=(df['corn_il_total'] + df['soy_il_total']),label='Other Crops, IL',color='grey')

# plt.plot(ind+.25,df['corn_il_total'],label='Corn, IL',color='darkorange',ls='--')
# plt.plot(ind+.25,df['corn_il_total'] + df['soy_il_total'],label='Soybeans, IL',color='darkgreen',ls='--')
# plt.plot(ind+.25,df['corn_il_total'] + df['soy_il_total'] + df['others_il_total'],label='Other Crops, IL',color='darkgrey',ls='--')

plt.ylabel('Planted Area (%)')
plt.title('Corn, Soybeans, and Other Crops\nPercent of Subsidies (Million $)')
#plt.xticks(ind, ('G1', 'G2', 'G3', 'G4', 'G5'))
#plt.yticks(np.arange(0, 81, 10))

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
shrink = 0.85
ax.set_position([box.x0, box.y0 + box.height * (1.-shrink),
                 box.width, box.height * shrink])
# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)

# ax.locator_params(nbins=6, axis='y')
# plt.tight_layout()
plt.savefig('percent_subsidies.png')