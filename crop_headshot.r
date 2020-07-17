library(magick)

i <- image_read('paul_ruess_sloan_photograph.JPG')
print(i)

c <- image_crop(i,'3000x3000+1500')
print(c)
image_write(c,'ruess_headshot_crop.png',format='png')
