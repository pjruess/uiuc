#import imageio
import matplotlib.pyplot as plt
import numpy
from PIL import Image

faf_in = Image.open('faf_figures/plot_inflows_total.png')
faf_out = Image.open('faf_figures/plot_outflows_total.png')
faf_ratio = Image.open('faf_figures/plot_ratio_total.png')

cnty_in = Image.open('county_figures/plot_inflows_total.png')
cnty_out = Image.open('county_figures/plot_outflows_total.png')
cnty_ratio = Image.open('county_figures/plot_ratio_total.png')

#img.thumbnail((64,64), Image.ANTIALIAS)

fig,ax = plt.subplots(3,2)

ax[0,0].imshow(faf_in)
#ax[0,0].set_title('FAF Inflows')
ax[0,0].axis('off')

ax[0,1].imshow(cnty_in)
#ax[0,1].set_title('County Inflows')
ax[0,1].axis('off')

ax[1,0].imshow(faf_out)
#ax[1,0].set_title('FAF Outflows')
ax[1,0].axis('off')

ax[1,1].imshow(cnty_out)
#ax[1,1].set_title('County Outflows')
ax[1,1].axis('off')

ax[2,0].imshow(faf_ratio)
#ax[2,0].set_title('FAF Inflows/Outflows')
ax[2,0].axis('off')

ax[2,1].imshow(cnty_ratio)
#ax[2,1].set_title('FAF Inflows/Outflows')
ax[2,1].axis('off')

ax[0,0].set_title('FAF')
ax[0,1].set_title('County')

plt.subplots_adjust(wspace=0,hspace=0)

plt.savefig('fig3.png',dpi=1800)
