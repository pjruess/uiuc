import matplotlib.pyplot as plt
import scipy

# plt.style.use('dark_background')

x = scipy.random.randint(0,100,50)
r = scipy.random.randint(-2000,2000,50)
imin = scipy.where(r==min(r))
y = abs(x**2)
plt.axvline(-x[imin],c='#ff7f0e',label='Threshold')
plt.scatter(-x,y+r,s=50,facecolors='none',edgecolors='#1f77b4',label='Raw Data')
xl,yl = zip(*sorted(zip(-x,y))) # organize data by ordered x values
plt.plot(xl,yl,c='#8c564b',label='Curve Fit')
plt.scatter(-x[imin],y[imin],s=100,c='#ff7f0e',label='Minimum Residual')
plt.xticks([-100,-80,-60,-40,-20,0],[0,20,40,60,80,100])
plt.title('Virtual Water Imports vs. Trading Partner Distance')
plt.xlabel('Trading Partner Distance')
plt.ylabel('Virtual Water Imports')

handles, labels = plt.gca().get_legend_handles_labels()
order = [2,1,3,0]
plt.legend([handles[idx] for idx in order],[labels[idx] for idx in order])

plt.savefig('scaling_example.png')
plt.show()