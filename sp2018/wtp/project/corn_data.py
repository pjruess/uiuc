import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

def plot_data(df,savepath_dists,savepath_total,type):
	ag_dists = df['Ag District'].unique()
	num_colors = len(ag_dists)
	cm = plt.get_cmap('gist_rainbow')

	#plt.style.use('dark_background')

	plt.rc('lines', linewidth=.9)

	#plt.rc('axes', prop_cycle=(cycler('color', [cm(1.*i/num_colors) for i in range(num_colors)])))
	# cm = plt.get_cmap('gist_rainbow')
	fig = plt.figure()
	ax = fig.add_subplot(111)
	ax.set_prop_cycle(color=[cm(1.*i/num_colors) for i in range(num_colors)])
	ax.set_prop_cycle(color=['blue','orange','cyan','lightgreen','magenta','lightgrey','darkgrey','yellow','red'])

	for ad in ag_dists:
		tempdf = df[df['Ag District'] == ad]
		ax.plot(tempdf['Year'],tempdf['Value'],label=ad)

	# Shrink current axis's height by 10% on the bottom
	box = ax.get_position()
	ax.set_position([box.x0, box.y0 + box.height * 0.25,
	                 box.width, box.height * 0.75])
	ax.set_title('{0} Area of Corn in Illinois by Agricultural District'.format(type))
	# Put a legend below current axis
	ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
	          fancybox=True, shadow=True, ncol=3)
	#ax.locator_params(nbins=8, axis='y')
	plt.savefig(savepath_dists)

	plt.cla()

	alldf = df.groupby('Year',as_index=False)['Value'].sum()
	print alldf
	ax.plot(alldf['Year'],alldf['Value'])
	ax.set_title('{0} Harvested Area of Corn in Illinois'.format(type))
	#ax.locator_params(nbins=6, axis='y')
	plt.savefig(savepath_total)

if __name__ == '__main__':
	plant = pandas.read_csv('corn_data/usda_il_corn_planted_area.csv',usecols=['Year','Ag District','Value'])
	harvest = pandas.read_csv('corn_data/usda_il_corn_harvested_area.csv',usecols=['Year','Ag District','Value'])

	plot_data(plant,'corn_planted_area_il_agdists.pdf','corn_planted_area_il_total.pdf','Planted')
	plot_data(harvest,'corn_harvested_area_il_agdists.pdf','corn_harvested_area_il_total.pdf','Harvested')