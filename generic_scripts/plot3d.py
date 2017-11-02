import numpy
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d

N = 60
g1 = (0.6 + 0.6 * numpy.random.rand(N), numpy.random.rand(N),0.4+0.1*numpy.random.rand(N))
g2 = (0.4+0.3 * numpy.random.rand(N), 0.5*numpy.random.rand(N),0.1*numpy.random.rand(N))
g3 = (0.3*numpy.random.rand(N),0.3*numpy.random.rand(N),0.3*numpy.random.rand(N))

data = (g1, g2, g3)
colors = ("red", "green", "blue")
groups = ("coffee", "tea", "water")

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1, axisbg="1.0") # you can skip this step
ax = fig.gca(projection='3d') # this is the important part for 3d plots

for data, color, group in zip(data, colors, groups):
    x, y, z = data
    ax.scatter(x, y, z, alpha=0.8, c=color, edgecolors='none', s=30, label=group)

plt.show()