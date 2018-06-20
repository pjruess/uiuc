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

deg = (Image.open('figures/degree_dist.png'))
deg_in = (Image.open('figures/degree_in_dist.png'))
deg_out = (Image.open('figures/degree_out_dist.png'))

strn = (Image.open('figures/strength_dist.png'))
strn_in = (Image.open('figures/strength_in_dist.png'))
strn_out = (Image.open('figures/strength_out_dist.png'))

#img.thumbnail((64,64), Image.ANTIALIAS)

fig,ax = plt.subplots(2,3)

ax[0,0].imshow(deg)
ax[0,0].axis('off')

ax[0,1].imshow(deg_in)
ax[0,1].axis('off')

ax[0,2].imshow(deg_out)
ax[0,2].axis('off')

ax[1,0].imshow(strn)
ax[1,0].axis('off')

ax[1,1].imshow(strn_in)
ax[1,1].axis('off')

ax[1,2].imshow(strn_out)
ax[1,2].axis('off')

plt.subplots_adjust(wspace=0,hspace=0)
#gs = gridspec.GridSpec(2,2)
#gs.update(wspace=0.025,hspace=0.025)

plt.tight_layout()

plt.savefig('figures/fig5_test.png',dpi=1800)
