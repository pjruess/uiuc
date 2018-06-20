library(magick)

### COUNTY ###

# Input variables
hi1 <- image_read('county_plots/2002_irrigated_harvest_plot_total.png')
hi2 <- image_read('county_plots/2007_irrigated_harvest_plot_total.png')
hi3 <- image_read('county_plots/2012_irrigated_harvest_plot_total.png')
harv_ir <- image_append(c(hi1,hi2,hi3))

hr1 <- image_read('county_plots/2002_rainfed_harvest_plot_total.png')
hr2 <- image_read('county_plots/2007_rainfed_harvest_plot_total.png')
hr3 <- image_read('county_plots/2012_rainfed_harvest_plot_total.png')
harv_rf <- image_append(c(hr1,hr2,hr3))

p1 <- image_read('county_plots/2002_production_plot_total.png')
p2 <- image_read('county_plots/2007_production_plot_total.png')
p3 <- image_read('county_plots/2012_production_plot_total.png')
prod <- image_append(c(p1,p2,p3))

y1 <- image_read('county_plots/2002_yield_plot_total.png')
y2 <- image_read('county_plots/2007_yield_plot_total.png')
y3 <- image_read('county_plots/2012_yield_plot_total.png')
yield <- image_append(c(y1,y2,y3))

s1 <- image_read('county_plots/2002_storage_plot.png')
s2 <- image_read('county_plots/2007_storage_plot.png')
s3 <- image_read('county_plots/2012_storage_plot.png')
stor <- image_append(c(s1,s2,s3))

county_inputs <- image_append(c(harv_ir, harv_rf, prod, yield, stor),stack=TRUE)

image_write(county_inputs, path = "group_images/county_inputs_combined.png", format = "png")

# VWS results
vb1 <- image_read('county_plots/2002_vws_irrigated_plot_total.png')
vb2 <- image_read('county_plots/2007_vws_irrigated_plot_total.png')
vb3 <- image_read('county_plots/2012_vws_irrigated_plot_total.png')
vws_blue <- image_append(c(vb1,vb2,vb3))

vg1 <- image_read('county_plots/2002_vws_rainfed_plot_total.png')
vg2 <- image_read('county_plots/2007_vws_rainfed_plot_total.png')
vg3 <- image_read('county_plots/2012_vws_rainfed_plot_total.png')
vws_green <- image_append(c(vg1,vg2,vg3))

v1 <- image_read('county_plots/2002_vws_plot_total.png')
v2 <- image_read('county_plots/2007_vws_plot_total.png')
v3 <- image_read('county_plots/2012_vws_plot_total.png')
vws_total <- image_append(c(v1,v2,v3))

county_vws <- image_append(c(vws_blue, vws_green, vws_total),stack=TRUE)

image_write(county_vws, path = "group_images/county_vws_combined.png", format = "png")

# CWU
cwu1 <- image_read('county_plots/2012_cwu_blue_plot_total.png')
cwu2 <- image_read('county_plots/2012_cwu_green_irrigated_plot_total.png')
cwu3 <- image_read('county_plots/2012_cwu_green_rainfed_plot_total.png')
county_cwu <- image_append(c(cwu1,cwu2,cwu3))

image_write(county_cwu, path = "group_images/county_cwu_combined.png", format = "png")

# Water Footprint of Grains
# Fill in data here... 

### STATE ###

# Input variables
hi1 <- image_read('state_plots/2002_irrigated_harvest_plot_total.png')
hi2 <- image_read('state_plots/2007_irrigated_harvest_plot_total.png')
hi3 <- image_read('state_plots/2012_irrigated_harvest_plot_total.png')
harv_ir <- image_append(c(hi1,hi2,hi3))

hr1 <- image_read('state_plots/2002_rainfed_harvest_plot_total.png')
hr2 <- image_read('state_plots/2007_rainfed_harvest_plot_total.png')
hr3 <- image_read('state_plots/2012_rainfed_harvest_plot_total.png')
harv_rf <- image_append(c(hr1,hr2,hr3))

p1 <- image_read('state_plots/2002_production_plot_total.png')
p2 <- image_read('state_plots/2007_production_plot_total.png')
p3 <- image_read('state_plots/2012_production_plot_total.png')
prod <- image_append(c(p1,p2,p3))

y1 <- image_read('state_plots/2002_yield_plot_total.png')
y2 <- image_read('state_plots/2007_yield_plot_total.png')
y3 <- image_read('state_plots/2012_yield_plot_total.png')
yield <- image_append(c(y1,y2,y3))

s1 <- image_read('state_plots/2002_storage_plot.png')
s2 <- image_read('state_plots/2007_storage_plot.png')
s3 <- image_read('state_plots/2012_storage_plot.png')
stor <- image_append(c(s1,s2,s3))

state_inputs <- image_append(c(harv_ir, harv_rf, prod, yield, stor),stack=TRUE)

image_write(state_inputs, path = "group_images/state_inputs_combined.png", format = "png")

# VWS results
vb1 <- image_read('state_plots/2002_vws_irrigated_plot_total.png')
vb2 <- image_read('state_plots/2007_vws_irrigated_plot_total.png')
vb3 <- image_read('state_plots/2012_vws_irrigated_plot_total.png')
vws_blue <- image_append(c(vb1,vb2,vb3))

vg1 <- image_read('state_plots/2002_vws_rainfed_plot_total.png')
vg2 <- image_read('state_plots/2007_vws_rainfed_plot_total.png')
vg3 <- image_read('state_plots/2012_vws_rainfed_plot_total.png')
vws_green <- image_append(c(vg1,vg2,vg3))

v1 <- image_read('state_plots/2002_vws_plot_total.png')
v2 <- image_read('state_plots/2007_vws_plot_total.png')
v3 <- image_read('state_plots/2012_vws_plot_total.png')
vws_total <- image_append(c(v1,v2,v3))

state_vws <- image_append(c(vws_blue, vws_green, vws_total),stack=TRUE)

image_write(state_vws, path = "group_images/state_vws_combined.png", format = "png")

# CWU
cwu1 <- image_read('state_plots/2012_cwu_blue_plot_total.png')
cwu2 <- image_read('state_plots/2012_cwu_green_irrigated_plot_total.png')
cwu3 <- image_read('state_plots/2012_cwu_green_rainfed_plot_total.png')
state_cwu <- image_append(c(cwu1,cwu2,cwu3))

image_write(state_cwu, path = "group_images/state_cwu_combined.png", format = "png")

# Water Footprint of Grains
# Fill in data here... 