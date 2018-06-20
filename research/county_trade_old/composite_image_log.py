#import imageio
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy
from PIL import Image,ImageChops

def trim(im):
    bg = Image.new(im.mode,im.size,im.getpixel((0,0)))
    diff = ImageChops.difference(im,bg)
    diff = ImageChops.add(diff,diff,2.0,-100)
    bbox = diff.getbbox()
    if bbox: return im.crop(bbox)

faf_in = trim(Image.open('faf_log_figures/plot_inflows_total.png'))
faf_out = trim(Image.open('faf_log_figures/plot_outflows_total.png'))
#faf_ratio = trim(Image.open('faf_log_figures/plot_ratio_total.png'))

cnty_in = trim(Image.open('county_log_figures/plot_inflows_total.png'))
cnty_out = trim(Image.open('county_log_figures/plot_outflows_total.png'))
#cnty_ratio = trim(Image.open('county_log_figures/plot_ratio_total.png'))

#img.thumbnail((64,64), Image.ANTIALIAS)

fig,ax = plt.subplots(2,2)

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

#ax[2,0].imshow(faf_ratio)
#ax[2,0].set_title('FAF Inflows/Outflows')
#ax[2,0].axis('off')

#ax[2,1].imshow(cnty_ratio)
#ax[2,1].set_title('FAF Inflows/Outflows')
#ax[2,1].axis('off')

#ax[0,0].set_title('FAF')
#ax[0,1].set_title('County')

plt.subplots_adjust(wspace=0,hspace=0)
gs = gridspec.GridSpec(2,2)
gs.update(wspace=0.025,hspace=0.025)

plt.tight_layout()

plt.savefig('figures/fig3_log.png',dpi=1800)
