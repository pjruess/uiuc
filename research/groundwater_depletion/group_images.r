library(magick)

### COUNTY ###

# Harvest
u1 <- image_read('gwa_2000.png')
u2 <- image_read('gwa_2010.png')
p1 <- image_read('pcr_2000.png')
p2 <- image_read('pcr_2000.png')

u1 <- image_annotate(u1,'USGS Groundwater Withdrawals, 2000',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
u2 <- image_annotate(u2,'USGS Groundwater Withdrawals, 2010',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
p1 <- image_annotate(p1,'PCR-GLOBWB Groundwater Abstractions, 2000',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
p2 <- image_annotate(p2,'PCR-GLOBWB Groundwater Abstractions, 2010',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')

u1 <- image_crop(h1,'1550x1100')
u2 <- image_crop(h2,'1550x1100')
p1 <- image_crop(p1,'1550x1100')
p2 <- image_crop(p2,'1550x1100')

u <- image_append(c(u1,u2))
p <- image_append(c(p1,p2))

u <- image_crop(u,'5650x1000')
p <- image_crop(p,'5650x1000')

f <- image_append(c(u, p),stack=TRUE)
image_write(f, path = 'usgs_vs_pcr.png', format = 'png')