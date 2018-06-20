library(magick)

### COUNTY ###

# Input variables
hi1 <- image_read('county_plots/total/2002_total_irrigated_harvest.png')
hi2 <- image_read('county_plots/total/2007_total_irrigated_harvest.png')
hi3 <- image_read('county_plots/total/2012_total_irrigated_harvest.png')
hi1 <- image_crop(hi1,'1800x1275')
hi2 <- image_crop(hi2,'1800x1275')
harv_ir <- image_append(c(hi1,hi2,hi3))

hr1 <- image_read('county_plots/total/2002_total_rainfed_harvest.png')
hr2 <- image_read('county_plots/total/2007_total_rainfed_harvest.png')
hr3 <- image_read('county_plots/total/2012_total_rainfed_harvest.png')
hr1 <- image_crop(hr1,'1800x1275')
hr2 <- image_crop(hr2,'1800x1275')
harv_rf <- image_append(c(hr1,hr2,hr3))

p1 <- image_read('county_plots/total/2002_total_production.png')
p2 <- image_read('county_plots/total/2007_total_production.png')
p3 <- image_read('county_plots/total/2012_total_production.png')
p1 <- image_crop(p1,'1800x1275')
p2 <- image_crop(p2,'1800x1275')
prod <- image_append(c(p1,p2,p3))

y1 <- image_read('county_plots/total/2002_total_yield.png')
y2 <- image_read('county_plots/total/2007_total_yield.png')
y3 <- image_read('county_plots/total/2012_total_yield.png')
y1 <- image_crop(y1,'1800x1275')
y2 <- image_crop(y2,'1800x1275')
yield <- image_append(c(y1,y2,y3))

s1 <- image_read('county_plots/total/2002_total_storage.png')
s2 <- image_read('county_plots/total/2007_total_storage.png')
s3 <- image_read('county_plots/total/2012_total_storage.png')
s1 <- image_crop(s1,'1800x1275')
s2 <- image_crop(s2,'1800x1275')
stor <- image_append(c(s1,s2,s3))

county_inputs <- image_append(c(harv_ir, harv_rf, prod, yield, stor),stack=TRUE)

image_write(county_inputs, path = "group_images/county_inputs_combined.png", format = "png")

# VWS results
vb1 <- image_read('county_plots/total/2002_total_vws_irrigated.png')
vb2 <- image_read('county_plots/total/2007_total_vws_irrigated.png')
vb3 <- image_read('county_plots/total/2012_total_vws_irrigated.png')
vb1 <- image_crop(vb1,'1800x1275')
vb2 <- image_crop(vb2,'1800x1275')
vws_blue <- image_append(c(vb1,vb2,vb3))

vg1 <- image_read('county_plots/total/2002_total_vws_rainfed.png')
vg2 <- image_read('county_plots/total/2007_total_vws_rainfed.png')
vg3 <- image_read('county_plots/total/2012_total_vws_rainfed.png')
vg1 <- image_crop(vg1,'1800x1275')
vg2 <- image_crop(vg2,'1800x1275')
vws_green <- image_append(c(vg1,vg2,vg3))

v1 <- image_read('county_plots/total/2002_total_vws.png')
v2 <- image_read('county_plots/total/2007_total_vws.png')
v3 <- image_read('county_plots/total/2012_total_vws.png')
v1 <- image_crop(v1,'1800x1275')
v2 <- image_crop(v2,'1800x1275')
vws_total <- image_append(c(v1,v2,v3))

vws <- image_append(c(vws_blue, vws_green, vws_total),stack=TRUE)

image_write(vws, path = "group_images/county_vws_combined.png", format = "png")

# Capture Efficiency
ce1 <- image_read('county_plots/total/2002_total_capture_efficiency.png')
ce2 <- image_read('county_plots/total/2007_total_capture_efficiency.png')
ce3 <- image_read('county_plots/total/2012_total_capture_efficiency.png')
ce1 <- image_crop(ce1,'1800x1275')
ce2 <- image_crop(ce2,'1800x1275')
ce <- image_append(c(ce1,ce2,ce3))

image_write(ce, path = "group_images/county_ce_combined.png", format = "png")

# CWU
cwu1 <- image_read('county_plots/total/2012_total_cwu_blue.png')
cwu2 <- image_read('county_plots/total/2012_total_cwu_green_irrigated.png')
cwu3 <- image_read('county_plots/total/2012_total_cwu_green_rainfed.png')
cwu1 <- image_crop(cwu1,'1800x1275')
cwu2 <- image_crop(cwu2,'1800x1275')
county_cwu <- image_append(c(cwu1,cwu2,cwu3))

image_write(county_cwu, path = "group_images/county_cwu_combined.png", format = "png")

# Water Footprint of Grains
# Fill in data here... 

### STATE ###

# Input variables
hi1 <- image_read('state_plots/total/2002_total_irrigated_harvest.png')
hi2 <- image_read('state_plots/total/2007_total_irrigated_harvest.png')
hi3 <- image_read('state_plots/total/2012_total_irrigated_harvest.png')
hi1 <- image_crop(hi1,'1800x1275')
hi2 <- image_crop(hi2,'1800x1275')
harv_ir <- image_append(c(hi1,hi2,hi3))

hr1 <- image_read('state_plots/total/2002_total_rainfed_harvest.png')
hr2 <- image_read('state_plots/total/2007_total_rainfed_harvest.png')
hr3 <- image_read('state_plots/total/2012_total_rainfed_harvest.png')
hr1 <- image_crop(hr1,'1800x1275')
hr2 <- image_crop(hr2,'1800x1275')
harv_rf <- image_append(c(hr1,hr2,hr3))

p1 <- image_read('state_plots/total/2002_total_production.png')
p2 <- image_read('state_plots/total/2007_total_production.png')
p3 <- image_read('state_plots/total/2012_total_production.png')
p1 <- image_crop(p1,'1800x1275')
p2 <- image_crop(p2,'1800x1275')
prod <- image_append(c(p1,p2,p3))

y1 <- image_read('state_plots/total/2002_total_yield.png')
y2 <- image_read('state_plots/total/2007_total_yield.png')
y3 <- image_read('state_plots/total/2012_total_yield.png')
y1 <- image_crop(y1,'1800x1275')
y2 <- image_crop(y2,'1800x1275')
yield <- image_append(c(y1,y2,y3))

s1 <- image_read('state_plots/total/2002_total_storage.png')
s2 <- image_read('state_plots/total/2007_total_storage.png')
s3 <- image_read('state_plots/total/2012_total_storage.png')
s1 <- image_crop(s1,'1800x1275')
s2 <- image_crop(s2,'1800x1275')
stor <- image_append(c(s1,s2,s3))

state_inputs <- image_append(c(harv_ir, harv_rf, prod, yield, stor),stack=TRUE)

image_write(state_inputs, path = "group_images/state_inputs_combined.png", format = "png")

# VWS results
vb1 <- image_read('state_plots/total/2002_total_vws_irrigated.png')
vb2 <- image_read('state_plots/total/2007_total_vws_irrigated.png')
vb3 <- image_read('state_plots/total/2012_total_vws_irrigated.png')
vb1 <- image_crop(vb1,'1800x1275')
vb2 <- image_crop(vb2,'1800x1275')
vws_blue <- image_append(c(vb1,vb2,vb3))

vg1 <- image_read('state_plots/total/2002_total_vws_rainfed.png')
vg2 <- image_read('state_plots/total/2007_total_vws_rainfed.png')
vg3 <- image_read('state_plots/total/2012_total_vws_rainfed.png')
vg1 <- image_crop(vg1,'1800x1275')
vg2 <- image_crop(vg2,'1800x1275')
vws_green <- image_append(c(vg1,vg2,vg3))

v1 <- image_read('state_plots/total/2002_total_vws.png')
v2 <- image_read('state_plots/total/2007_total_vws.png')
v3 <- image_read('state_plots/total/2012_total_vws.png')
v1 <- image_crop(v1,'1800x1275')
v2 <- image_crop(v2,'1800x1275')
vws_total <- image_append(c(v1,v2,v3))

vws <- image_append(c(vws_blue, vws_green, vws_total),stack=TRUE)

image_write(vws, path = "group_images/state_vws_ce_combined.png", format = "png")

# Capture Efficiency
ce1 <- image_read('state_plots/total/2002_total_capture_efficiency.png')
ce2 <- image_read('state_plots/total/2007_total_capture_efficiency.png')
ce3 <- image_read('state_plots/total/2012_total_capture_efficiency.png')
ce1 <- image_crop(ce1,'1800x1275')
ce2 <- image_crop(ce2,'1800x1275')
ce <- image_append(c(ce1,ce2,ce3))

image_write(ce, path = "group_images/state_ce_combined.png", format = "png")

# CWU
cwu1 <- image_read('state_plots/total/2012_total_cwu_blue.png')
cwu2 <- image_read('state_plots/total/2012_total_cwu_green_irrigated.png')
cwu3 <- image_read('state_plots/total/2012_total_cwu_green_rainfed.png')
cwu1 <- image_crop(cwu1,'1800x1275')
cwu2 <- image_crop(cwu2,'1800x1275')
state_cwu <- image_append(c(cwu1,cwu2,cwu3))

image_write(state_cwu, path = "group_images/state_cwu_combined.png", format = "png")

# Water Footprint of Grains
# Fill in data here... 

### STATE + COUNTY ###

# Input variables
s1 <- image_read('vws_plots/total/2002_total_storage.png')
s2 <- image_read('vws_plots/total/2007_total_storage.png')
s3 <- image_read('vws_plots/total/2012_total_storage.png')
s1 <- image_crop(s1,'1800x1275')
s2 <- image_crop(s2,'1800x1275')
stor <- image_append(c(s1,s2,s3))

#county_inputs <- image_append(c(harv_ir, harv_rf, prod, yield, stor),stack=TRUE)

image_write(stor, path = "group_images/total_inputs_combined.png", format = "png")

# VWS results
vb1 <- image_read('vws_plots/total/2002_total_vws_irrigated.png')
vb2 <- image_read('vws_plots/total/2007_total_vws_irrigated.png')
vb3 <- image_read('vws_plots/total/2012_total_vws_irrigated.png')
vb1 <- image_crop(vb1,'1800x1275')
vb2 <- image_crop(vb2,'1800x1275')
vws_blue <- image_append(c(vb1,vb2,vb3))

vg1 <- image_read('vws_plots/total/2002_total_vws_rainfed.png')
vg2 <- image_read('vws_plots/total/2007_total_vws_rainfed.png')
vg3 <- image_read('vws_plots/total/2012_total_vws_rainfed.png')
vg1 <- image_crop(vg1,'1800x1275')
vg2 <- image_crop(vg2,'1800x1275')
vws_green <- image_append(c(vg1,vg2,vg3))

v1 <- image_read('vws_plots/total/2002_total_vws.png')
v2 <- image_read('vws_plots/total/2007_total_vws.png')
v3 <- image_read('vws_plots/total/2012_total_vws.png')
v1 <- image_crop(v1,'1800x1275')
v2 <- image_crop(v2,'1800x1275')
vws_total <- image_append(c(v1,v2,v3))

vws <- image_append(c(vws_blue, vws_green, vws_total),stack=TRUE)

image_write(vws, path = "group_images/total_vws_combined.png", format = "png")

# Capture Efficiency
ce1 <- image_read('vws_plots/total/2002_total_capture_efficiency.png')
ce2 <- image_read('vws_plots/total/2007_total_capture_efficiency.png')
ce3 <- image_read('vws_plots/total/2012_total_capture_efficiency.png')
ce1 <- image_crop(ce1,'1800x1275')
ce2 <- image_crop(ce2,'1800x1275')
ce <- image_append(c(ce1,ce2,ce3))

image_write(ce, path = "group_images/total_ce_combined.png", format = "png")