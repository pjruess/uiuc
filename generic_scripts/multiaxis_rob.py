import numpy
import matplotlib.pyplot as plt

flood_flow = [0,100]
damage = [0,10]
exceedance_probability = [0,20]
flood_stage = [0,5]

def formatter(x_lim, y_lim, x_invert, y_invert):
    plt.xlim(x_lim), plt.ylim(y_lim)
    if x_invert:
        plt.gca().invert_xaxis()
    if y_invert:
        plt.gca().invert_yaxis()

fig = plt.figure()

ul = fig.add_subplot(221)
formatter(flood_flow, flood_stage, True, False)
ul.set_xticklabels('', visible=False)

ur = fig.add_subplot(222)
formatter(damage, flood_stage, False, False)
ur.set_xticklabels('', visible=False); ur.set_yticklabels('', visible=False)


ll = fig.add_subplot(223)
formatter(flood_flow, exceedance_probability, True, True)

lr = fig.add_subplot(224)
formatter(damage, exceedance_probability, False, True)
lr.set_yticklabels('', visible=False);

# labels
ll.set_xlabel("flood flow")
lr.set_xlabel("damage")
ul.set_ylabel("flood stage")
ll.set_ylabel("exceedance probability")

# test functions
ur.plot(numpy.linspace(0,10,20), numpy.linspace(0,20,20)**0.5)
ul.plot(numpy.linspace(0,100,20), numpy.linspace(0,20,20)**0.5)

fig.subplots_adjust(hspace=0.05,wspace=0.05)

plt.show()