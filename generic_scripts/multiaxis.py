import numpy
import math
import matplotlib.pyplot as plt

t = numpy.linspace(-2, 2*math.pi, 400)
a = numpy.sin(t)
b = numpy.cos(t)
c = a + b

fig = plt.figure()
ax = fig.add_subplot(111)

ax.plot(t, a, 'r') # plotting t, a separately 
ax.plot(b, t, 'b') # plotting b, t separately 
ax.plot(t, c, 'g') # plotting t, c separately 

ax.set_xlim([-4,4])
ax.set_xticklabels([str(abs(x)) for x in ax.get_xticks()])
label = ax.set_xlabel('Xlabel', fontsize = 9)
ax.xaxis.set_label_coords(1.05, -0.025)


ax.set_ylim([-4,4])
ax.set_yticklabels([str(abs(y)) for y in ax.get_yticks()])
label = ax.set_ylabel('YLABEL', fontsize = 9)
ax.xaxis.set_label_coords(1.05, -0.025)

ax.spines['left'].set_position('center')
ax.spines['right'].set_color('none')
ax.spines['bottom'].set_position('center')
ax.spines['top'].set_color('none')

plt.show()