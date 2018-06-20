import matplotlib.pyplot as plt

botlim = 1973
toplim = 2017

years = range(botlim,toplim+1)

drought = [0] * len(years)
drought[years.index(1976)] = -1
# drought[years.index(1983)] = -1
drought[years.index(1988)] = -1
drought[years.index(1989)] = -1
# drought[years.index(2002)] = -1
drought[years.index(2005)] = -1
drought[years.index(2012)] = -1

foodpol = [0] * len(years)
foodpol[years.index(1996)] = -1
foodpol[years.index(1997)] = 1
foodpol[years.index(2014)] = 1

enpol = [0] * len(years)
enpol[years.index(2004)] = 1
enpol[years.index(2005)] = 1
enpol[years.index(2007)] = 1
enpol[years.index(2011)] = -1

fix,ax = plt.subplots()
ax.plot(years,[0]*len(years),color='black')
ax.bar(years,drought,width=1,color='brown')
ax.bar(years,foodpol,width=1,color='blue')
ax.bar(years,enpol,width=1,color='green')
ax.set_yticks([-1,0,1])

plt.title('Timeline of Corn Legislation and Climate in Illinois')
plt.savefig('timeline.png')

# import pandas

# df = pandas.DataFrame({
# 	'Year': years, 
# 	'Pos': [],
# 	'Neg': []
# 	})
