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

nrow = 2
ncol = 2

fig = plt.figure(figsize=(2.22,2))

gs = gridspec.GridSpec(nrow,ncol,
    wspace=0.0,hspace=0.0)#,
    #top=1,bottom=0,left=0,right=0)#top=1.-0.5/(nrow+1),bottom=0.5/(nrow+1),left=0.5/(ncol+1),right=1.-0.5/(ncol+1))

img_paths = ['figures/faf_des_1.png','figures/faf_ori_1.png','figures/county_des_1.png','figures/county_ori_1.png']
a = numpy.array(img_paths)
a = a.reshape(nrow,ncol)

for i in range(nrow):
    for j in range(ncol):
        im = trim(Image.open(a[i,j]))
        ax = plt.subplot(gs[i,j])
        ax.imshow(im)#,aspect='auto')
        #ax.set(adjustable='datalim')
        ax.set_xticks([])
        ax.set_xticklabels([])
        ax.set_yticks([])
        ax.set_yticklabels([])
        ax.margins(x=0,y=0)
        #plt.subplots_adjust(left=0,bottom=0,right=1,top=1,wspace=0,hspace=0.001)
#plt = trim(plt)

#ax[0,0].set_title('FAF')
#ax[0,1].set_title('County')

#plt.subp
#plt.rcParams['axes.xmargin'] = 0
plt.tight_layout(pad=0)

plt.savefig('figures/fig4_test.png',bbox_inches='tight',dpi=1800)
