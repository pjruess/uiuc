library(magick)

a <- image_read('usgs_2000.png')
b <- image_read('usgs_2010.png')
c <- image_read('gwa_2000.png')
d <- image_read('gwa_2010.png')

a <- image_crop(a,'3300x1550+100+550')
b <- image_crop(b,'3300x1550+100+550')
c <- image_crop(c,'3300x1550+100+550')
d <- image_crop(d,'3300x1550+100+550')

image_write(a,'usgs_2000_crop.png')
image_write(b,'usgs_2010_crop.png')
image_write(c,'gwa_2000_crop.png')
image_write(d,'gwa_2010_crop.png')
