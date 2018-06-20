library(raster)
library(rgdal)

# # Read in data
# l8.s.r <- stack('data/l8_summer_rice.tif')
# l8.s.n <- stack('data/l8_summer_notrice.tif')
# l8.w.r <- stack('data/l8_winter_rice.tif')
# l8.w.n <- stack('data/l8_winter_notrice.tif')

# bands = seq(11)

# for (b in bands) {
# 	png(sprintf('results/band%s_box.png',b))
# 	boxplot(
# 		list(
# 			summer_rice=values(l8.s.r[[b]]),
# 			summer_other=values(l8.s.n[[b]]),
# 			winter_rice=values(l8.w.r[[b]]),
# 			winter_other=values(l8.w.n[[b]])
# 		),las=2
# 	)
# 	dev.off()
# 	pdf(sprintf('results/band%s_hist.pdf',b))
# 	hist(l8.s.r[[b]],maxpixels=ncell(l8.s.r[[b]]),xaxt='n')
# 	hist(l8.s.n[[b]],maxpixels=ncell(l8.s.n[[b]]),xaxt='n')
# 	hist(l8.w.r[[b]],maxpixels=ncell(l8.w.r[[b]]),xaxt='n')
# 	hist(l8.w.n[[b]],maxpixels=ncell(l8.w.n[[b]]),xaxt='n')
# 	axis(side=1, labels=seq(0,1,0.2))
# 	dev.off()
# }

# # Read in NDVI data
# ndvi.s.r <- stack('data/ndvi_summer_rice.tif')
# ndvi.s.n <- stack('data/ndvi_summer_notrice.tif')
# ndvi.w.r <- stack('data/ndvi_winter_rice.tif')
# ndvi.w.n <- stack('data/ndvi_winter_notrice.tif')

# # Plot NDVI data
# png('results/ndvi_box.png')
# boxplot(
# 	list(
# 		summer_rice=values(ndvi.s.r),
# 		summer_other=values(ndvi.s.n),
# 		winter_rice=values(ndvi.w.r),
# 		winter_other=values(ndvi.w.n)
# 	),las=2
# )
# dev.off()
# pdf('results/ndvi_hist.pdf')
# hist(ndvi.s.r,maxpixels=ncell(ndvi.s.r))
# hist(ndvi.s.n,maxpixels=ncell(ndvi.s.n))
# hist(ndvi.w.r,maxpixels=ncell(ndvi.w.r))
# hist(ndvi.w.n,maxpixels=ncell(ndvi.w.n))
# dev.off()

# # Read in NDWI data
# ndwi.s.r <- stack('data/ndwi_summer_rice.tif')
# ndwi.s.n <- stack('data/ndwi_summer_notrice.tif')
# ndwi.w.r <- stack('data/ndwi_winter_rice.tif')
# ndwi.w.n <- stack('data/ndwi_winter_notrice.tif')

# # Plot NDWI data
# png('results/ndwi_box.png')
# boxplot(
# 	list(
# 		summer_rice=values(ndwi.s.r),
# 		summer_other=values(ndwi.s.n),
# 		winter_rice=values(ndwi.w.r),
# 		winter_other=values(ndwi.w.n)
# 	),las=2
# )
# dev.off()
# pdf('results/ndwi_hist.pdf')
# hist(ndwi.s.r,maxpixels=ncell(ndwi.s.r))
# hist(ndwi.s.n,maxpixels=ncell(ndwi.s.n))
# hist(ndwi.w.r,maxpixels=ncell(ndwi.w.r))
# hist(ndwi.w.n,maxpixels=ncell(ndwi.w.n))
# dev.off()

# Read in NDVI and NDWI and LWSI difference data
ndvi.diff.r <- stack('data/ndvi_rice_diff.tif')
print('1')
ndvi.diff.n <- stack('data/ndvi_notrice_diff.tif')
print('2')
ndwi.diff.r <- stack('data/ndwi_rice_diff.tif')
print('3')
ndwi.diff.n <- stack('data/ndwi_notrice_diff.tif')
print('4')
lswi1.diff.r <- stack('data/lswi1_rice_diff.tif')
print('5')
lswi1.diff.n <- stack('data/lswi1_notrice_diff.tif')
print('6')
lswi2.diff.r <- stack('data/lswi2_rice_diff.tif')
print('7')
lswi2.diff.n <- stack('data/lswi2_notrice_diff.tif')
print('8')

# Difference values
absndvi_absndwi_r=(abs(values(ndvi.diff.r))-abs(values(ndwi.diff.r)))
absndvi_absndwi_o=(abs(values(ndvi.diff.n))-abs(values(ndwi.diff.n)))
absndvi_abslswi1_r=(abs(values(ndvi.diff.r))-abs(values(lswi1.diff.r)))
absndvi_abslswi1_o=(abs(values(ndvi.diff.n))-abs(values(lswi1.diff.n)))
abs_ndvi_ndwi_r=abs(values(ndvi.diff.r)-values(ndwi.diff.r))
abs_ndvi_ndwi_o=abs(values(ndvi.diff.n)-values(ndwi.diff.n))
abs_ndvi_lswi1_r=abs(values(ndvi.diff.r)-values(lswi1.diff.r))
abs_ndvi_lswi1_o=abs(values(ndvi.diff.n)-values(lswi1.diff.n))
ndvi_ndwi_r=(values(ndvi.diff.r)-values(ndwi.diff.r))
ndvi_ndwi_o=(values(ndvi.diff.n)-values(ndwi.diff.n))
ndvi_lswi1_r=(values(ndvi.diff.r)-values(lswi1.diff.r))
ndvi_lswi1_o=(values(ndvi.diff.n)-values(lswi1.diff.n))

# Plot data
png('results/diff_box.png')
par(mar=c(14, 2, 2, 2) + 0.1)
boxplot(
	list(
		ndvi_diff_rice=values(ndvi.diff.r),
		ndvi_diff_other=values(ndvi.diff.n),
		ndwi_diff_rice=values(ndwi.diff.r),
		ndwi_diff_other=values(ndwi.diff.n),
		lswi1_diff_rice=values(lswi1.diff.r),
		lswi1_diff_other=values(lswi1.diff.n),
		lswi2_diff_rice=values(lswi2.diff.r),
		lswi2_diff_other=values(lswi2.diff.n),
		absndvi_minus_absndwi_rice=absndvi_absndwi_r,
		absndvi_minus_absndwi_other=absndvi_absndwi_o,
		absndvi_minus_abslswi1_rice=absndvi_abslswi1_r,
		absndvi_minus_abslswi1_other=absndvi_abslswi1_o,
		abs_ndvi_minus_ndwi_rice=abs_ndvi_ndwi_r,
		abs_ndvi_minus_ndwi_other=abs_ndvi_ndwi_o,
		abs_ndvi_minus_lswi1_rice=abs_ndvi_lswi1_r,
		abs_ndvi_minus_lswi1_other=abs_ndvi_lswi1_o,
		ndvi_minus_ndwi_rice=ndvi_ndwi_r,
		ndvi_minus_ndwi_other=ndvi_ndwi_o,
		ndvi_minus_lswi1_rice=ndvi_lswi1_r,
		ndvi_minus_lswi1_other=ndvi_lswi1_o
	),las=2
)
dev.off()
pdf('results/diff_hist.pdf')
# Overlap: https://www.r-bloggers.com/overlapping-histogram-in-r/
hist(ndvi.diff.r,maxpixels=ncell(ndvi.diff.r))
hist(ndvi.diff.n,maxpixels=ncell(ndvi.diff.n))
hist(ndwi.diff.r,maxpixels=ncell(ndwi.diff.r))
hist(ndwi.diff.n,maxpixels=ncell(ndwi.diff.n))
hist(lswi1.diff.r,maxpixels=ncell(lswi1.diff.r))
hist(lswi1.diff.n,maxpixels=ncell(lswi1.diff.n))
hist(lswi2.diff.r,maxpixels=ncell(lswi2.diff.r))
hist(lswi2.diff.n,maxpixels=ncell(lswi2.diff.n))
hist(absndvi_absndwi_r,maxpixels=ncell(absndvi_absndwi_r))
hist(absndvi_absndwi_o,maxpixels=ncell(absndvi_absndwi_o))
hist(absndvi_abslswi1_r,maxpixels=ncell(absndvi_abslswi1_r))
hist(absndvi_abslswi1_o,maxpixels=ncell(absndvi_abslswi1_o))
hist(abs_ndvi_ndwi_r,maxpixels=ncell(abs_ndvi_ndwi_r))
hist(abs_ndvi_ndwi_o,maxpixels=ncell(abs_ndvi_ndwi_o))
hist(abs_ndvi_lswi1_r,maxpixels=ncell(abs_ndvi_lswi1_r))
hist(abs_ndvi_lswi1_o,maxpixels=ncell(abs_ndvi_lswi1_o))
hist(ndvi_ndwi_r,maxpixels=ncell(ndvi_ndwi_r))
hist(ndvi_ndwi_o,maxpixels=ncell(ndvi_ndwi_o))
hist(ndvi_lswi1_r,maxpixels=ncell(ndvi_lswi1_r))
hist(ndvi_lswi1_o,maxpixels=ncell(ndvi_lswi1_o))
dev.off()