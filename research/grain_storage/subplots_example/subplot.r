library(magick)

### VERSION WITH TITLE LABELS

# County Harvest
h1 <- image_read('county_plots/2002_total_harvest.png')
h1 <- image_annotate(h1,'County, 2002',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h2 <- image_read('county_plots/2007_total_harvest.png')
h2 <- image_annotate(h2,'County, 2007',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h3 <- image_read('county_plots/2012_total_harvest.png')
h3 <- image_annotate(h3,'County, 2012',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h1 <- image_crop(h1,'1550x1100') # Figure out size by trial and error; this was cut to remove legend from first two plots, leaving it only for the third plot
h2 <- image_crop(h2,'1550x1100')
county_harv <- image_append(c(h1,h2,h3))
county_harv <- image_crop(county_harv,'5650x1000') # Again, size by trial and error

# State Harvest
h1 <- image_read('state_plots/2002_total_harvest.png')
h1 <- image_annotate(h1,'Harvest, 2002',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h2 <- image_read('state_plots/2007_total_harvest.png')
h2 <- image_annotate(h2,'Harvest, 2007',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h3 <- image_read('state_plots/2012_total_harvest.png')
h3 <- image_annotate(h3,'Harvest, 2012',size=100,location='+50+50',,gravity='northwest',color='black')#,location='+50+15')
h1 <- image_crop(h1,'1550x1100')
h2 <- image_crop(h2,'1550x1100')
state_harv <- image_append(c(h1,h2,h3))
state_harv <- image_crop(state_harv,'5650x1100')

# Combined Harvest
all_harv <- image_append(c(county_harv, state_harv),stack=TRUE)
image_write(all_harv, path = 'all_harv_titles.png', format = 'png')

### ALTERNATIVE WITH LETTER LABELS (A, B, C...)

# Harvest
h1 <- image_read('county_plots/2002_total_harvest.png')
h1 <- image_annotate(h1,'A',size=200,gravity='northwest',color='black')#,location='+50+15')
h2 <- image_read('county_plots/2007_total_harvest.png')
h2 <- image_annotate(h2,'B',size=200,gravity='northwest',color='black')#,location='+50+15')
h3 <- image_read('county_plots/2012_total_harvest.png')
h3 <- image_annotate(h3,'C',size=200,gravity='northwest',color='black')#,location='+50+15')
h1 <- image_crop(h1,'1550x1100')
h2 <- image_crop(h2,'1550x1100')
county_harv <- image_append(c(h1,h2,h3))
county_harv <- image_crop(county_harv,'5650x1000')

# Harvest
h1 <- image_read('state_plots/2002_total_harvest.png')
h1 <- image_annotate(h1,'D',size=200,gravity='northwest',color='black')#,location='+50+15')
h2 <- image_read('state_plots/2007_total_harvest.png')
h2 <- image_annotate(h2,'E',size=200,gravity='northwest',color='black')#,location='+50+15')
h3 <- image_read('state_plots/2012_total_harvest.png')
h3 <- image_annotate(h3,'F',size=200,gravity='northwest',color='black')#,location='+50+15')
h1 <- image_crop(h1,'1550x1100')
h2 <- image_crop(h2,'1550x1100')
state_harv <- image_append(c(h1,h2,h3))
state_harv <- image_crop(state_harv,'5650x1100')

# Combined Harvest
all_harv <- image_append(c(county_harv, state_harv),stack=TRUE)
image_write(all_harv, path = "all_harv_letters.png", format = "png")