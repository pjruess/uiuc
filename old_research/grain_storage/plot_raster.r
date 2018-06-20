# library(ggplot2)
library(raster)
# library(viridis)
# library(RColorBrewer)
# if (!interactive()) {
# 	  main()
# }

plot.raster <- function(n) {
	# Read in raster
	r <- raster(n)

	# Extract raster name
	# s <- sub( '^\\/[^/]+\\/([^/]+)\\/', n )
	name <- sub('.*/(.*)[.].*', '\\1', n)

	# r.fort <- fortify(r)
	map.df <- as(r, "SpatialPixelsDataFrame")
	map.df <- as.data.frame(map.df)
	colnames(map.df) <- c('value','long','lat')
	cols <- c('0' = 'white', '1' = 'black')
	# ggplot(data=map.df, aes(x=long, y=lat, fill=value)) +
	# # ggplot() + 
	# # 	geom_tile(data=map.df, aes(x=long, y=lat, fill=value), alpha=0.8) +
	# 	scale_fill_viridis() + 
	# 	# scale_fill_gradientn(colours=c('green','blue')) +
	# 	# scale_colour_manual(values = cols) +
	# 	coord_map( xlim=c(-125,-66), ylim=c(24,50) ) +
	# 	labs( title=sprintf('Plot of %s',name) ) +
	# 	theme( panel.grid.major=element_blank(),
	# 	      panel.grid.minor=element_blank(),
	# 	      panel.background=element_blank(),
	# 	      axis.line=element_blank(),
	# 	      axis.text=element_blank(),
	# 	      axis.ticks=element_blank())
	# blues <- brewer.pal(map.df$value,'Blues')

	plot(r,col=cols, main=sprintf('Plot of %s', name))
	# ggsave( sprintf( '%s/results/%s.png', path, name ) )
}

names = list.files('cwu_zonal_stats/raw_tiffs/')

# names <- c('cwu15_bl_reclass.tif','cwu15_gn_ir_reclass.tif','cwu15_gn_rf_reclass.tif')


### NEED TO MAKE RASTERS FOR ALL COMMODITY-WATERTYPE PAIRS (TO VERIFY THAT THE THREE TYPES OVERLAP) ###


for (n in names) {
	n <- sprintf('test_rasters/%s',n)
	print(n)
	break
	path <- sub('(.*)[/].*', '\\1', n)
	png(path)
	plot.raster(n)
	dev.off()
}

bl.path <- 'test_rasters/cwu15_bl.tif'
gn_ir.path <- 'test_rasters/cwu15_gn_ir.tif'
gn_rf.path <- 'test_rasters/cwu15_gn_rf.tif'
bl_reclass.path <- 'test_rasters/cwu15_bl_reclass.tif'
gn_ir_reclass.path <- 'test_rasters/cwu15_gn_ir_reclass.tif'
gn_rf_reclass.path <- 'test_rasters/cwu15_gn_rf_reclass.tif'

bl <- raster(bl.path)
gn_ir <- raster(gn_ir.path)
gn_rf <- raster(gn_rf.path)
bl_r <- raster(bl_reclass.path)
gn_ir_r <- raster(gn_ir_reclass.path)
gn_rf_r <- raster(gn_rf_reclass.path)

bl.df <- as.data.frame( as( bl, "SpatialPixelsDataFrame" ) )
gn_ir.df <- as.data.frame( as( gn_ir, "SpatialPixelsDataFrame" ) )
gn_rf.df <- as.data.frame( as( gn_rf, "SpatialPixelsDataFrame" ) )
bl_r.df <- as.data.frame( as( bl_r, "SpatialPixelsDataFrame" ) )
gn_ir_r.df <- as.data.frame( as( gn_ir_r, "SpatialPixelsDataFrame" ) )
gn_rf_r.df <- as.data.frame( as( gn_rf_r, "SpatialPixelsDataFrame" ) )

colnames(bl.df) <- c('value','long','lat')
colnames(gn_ir.df) <- c('value','long','lat')
colnames(gn_rf.df) <- c('value','long','lat')
colnames(bl_r.df) <- c('value','long','lat')
colnames(gn_ir_r.df) <- c('value','long','lat')
colnames(gn_rf_r.df) <- c('value','long','lat')

a <- merge( bl.df, gn_ir.df, by=c('long','lat'), all=T )
b <- merge(a, gn_rf.df, by=c('long','lat'), all=T )
c <- merge(b, bl_r.df, by=c('long','lat'), all=T )
d <- merge(c, gn_ir_r.df, by=c('long','lat'), all=T )
all <- merge(d, gn_rf_r.df, by=c('long','lat'), all=T )

colnames(all) <- c('long','lat','bl','gn_ir','gn_rf','bl_r','gn_ir_r','gn_rf_r')

all$r_sum <- rowSums( all[ ,c('bl_r','gn_ir_r','gn_rf_r') ] )

print(head(all))

write.csv(all, 'cwu15_summary.csv')
