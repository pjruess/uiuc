import pandas
import matplotlib.pyplot as plt

plt.rc('lines', linewidth=.9)

fig = plt.figure()
ax = fig.add_subplot(111)

# Shrink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
				box.width, box.height * 0.75])

prices = pandas.read_csv('data/crop_price.csv')

# Filter by years
botlim = 1973
toplim = 2017
years = range(botlim,toplim+1)
prices = prices[prices['Year'].isin(years)]

ax.plot(prices['Year'],prices['Corn'],ls='-',c='orange',label='Corn Price')
ax.plot(prices['Year'],prices['Soybeans'],ls='-',c='green',label='Soy Price')

# ax.set_yticks([-1,0,1])
ax.set_title('Corn and Soybean Prices in the United States')

# Put a legend below current axis
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
          fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('crop_prices.png')
