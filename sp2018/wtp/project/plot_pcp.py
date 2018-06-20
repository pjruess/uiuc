import pandas
import matplotlib.pyplot as plt
#from cycler import cycler

url = 'https://www.ncdc.noaa.gov/cag/statewide/time-series/11-pcp-12-12-1895-2018.csv'
pcp = pandas.read_csv(url,skiprows=3)
pcp['Year'] = pcp['Date'].apply(lambda x: int(str(x)[:4]))
pcp.drop(['Date'],axis=1,inplace=True)

botlim = 1973
labstep = 5

pcp = pcp[pcp['Year'] >= botlim]

plt.rc('lines', linewidth=.9)

fig = plt.figure()

ax = fig.add_subplot(111)

box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.25,
                 box.width, box.height * 0.75])

ax.plot(pcp['Year'],pcp['Value'],ls='-',c='blue',label='Precipitation')
ax.set_title('Total Precipitation in Illinois')
ax.set_xlabel('Year')
ax.set_ylabel('Precipitation (Inches)')

xlabs = [int(y) for y in pcp['Year'] if int(y)%labstep == 0]
xlabs = xlabs# + [2020]
ax.set_xticks(xlabs)
ax.set_xticklabels(xlabs)

# Put a legend below current axis
# ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1),
#           fancybox=True, shadow=True, ncol=3)
#ax.locator_params(nbins=6, axis='y')
plt.savefig('pcp_il_total.png')