library(ncdf4) # for reading and processing NetCDF files
library(glue) # for formatting strings 
library(rgdal) # for spatial analysis (masking with US map)
library(raster) # for reading and processing rasters
library(data.table)

library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)

# Read in USA map for masking
counties <- readOGR('../grain_storage/cb_2016_us_county_500k','cb_2016_us_county_500k')

### USGS data
usgs.2000 <- fread('usco2000.csv',select=c('FIPS','TO-WGWFr','TO-WGWSa','TO-WGWTo'))
names(usgs.2000) <- c('FIPS','TO.WGWFr.2000','TO.WGWSa.2000','TO.WGWTo.2000')
usgs.2010 <- fread('usco2010.csv',select=c('FIPS','TO-WGWFr','TO-WGWSa','TO-WGWTo'))
names(usgs.2010) <- c('FIPS','TO.WGWFr.2010','TO.WGWSa.2010','TO.WGWTo.2010')

# Convert units MGal/day to Mm3/year
usgs.2000[,c(2:4)] <- usgs.2000[,c(2:4)] * 366 / 264.1721
usgs.2010[,c(2:4)] <- usgs.2010[,c(2:4)] * 365 / 264.1721

# Merge datasets
usgs <- merge(usgs.2000,usgs.2010)

### PCR data
pcr.2000 <- fread('pcr_gwa_2000.csv',select=c('GEOID','sum'))
pcr.2000$sum[pcr.2000$sum == 'None'] <- NA
names(pcr.2000) <- c('FIPS','PCR.GWA.2000')
pcr.2010 <- fread('pcr_gwa_2010.csv',select=c('GEOID','sum'))
pcr.2010$sum[pcr.2010$sum == 'None'] <- NA
names(pcr.2010) <- c('FIPS','PCR.GWA.2010')

# Merge datasets
pcr <- merge(pcr.2000,pcr.2010)

### Merge USGS and PCR data and calculate difference
df <- merge(usgs,pcr)
df$FIPS <- formatC(df$FIPS, width=5, format='d', flag='0')
df <- transform(df, PCR.GWA.2000 = as.numeric(PCR.GWA.2000), PCR.GWA.2010 = as.numeric(PCR.GWA.2010))

# Calculate difference
df$dif.2000.Fr <- df$TO.WGWFr.2000 - df$PCR.GWA.2000
df$dif.2000.To <- df$TO.WGWTo.2000 - df$PCR.GWA.2000
df$dif.2010.Fr <- df$TO.WGWFr.2010 - df$PCR.GWA.2010
df$dif.2010.To <- df$TO.WGWTo.2010 - df$PCR.GWA.2010

### Remove problematic Florida county for viewing (enormous values)
#df <- subset(df, FIPS!='12087')

### Add spatial data for mapping

# Create temp df
data <- data.frame(id=rownames(counties@data),
		   FIPS=counties@data$GEOID)

# Convert from factor to character
data$id <- as.character(data$id)

# Merge databases
data <- merge(data, df, by='FIPS')

# Fortify data to extract spatial information
counties.fort <- fortify(counties)
map.df <- join(counties.fort, data, by='id')

### Function for plotting change over time 
# df: dataframe
# path: path to save file to
# limit: larger of max and min
# label: plot label
# yr1: first year (for title)
# yr2: second year (for title)
ggPlot <- function(d,path,identifier,label) {

	d$plot_fill <- d[,identifier]

    # Get min and max values
    minima <- min(d$plot_fill,na.rm=T)
    maxima <- max(d$plot_fill,na.rm=T)
    print(sprintf('Min: %s',minima))
    print(sprintf('Max: %s',maxima))
    
    ext <- max(abs(minima),abs(maxima))

    # Manually make this insane florida county huge
    d$plot_fill[df$FIPS=='12087'] <- 1799
    print(head(d[d$FIPS=='12087',]))

    # Plot data
	ggplot(d, aes(x=long,y=lat,group=group)) + 
        geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
    	coord_map(xlim=c(-128, -66),ylim=c(22, 52)) + 
	    scale_fill_distiller(name='',
                    palette='BrBG',
    			    limits=c( -1800, 1800 ),
                    direction = 1,
    			    na.value='grey90') +
    	labs(title='USGS Groundwater Use minus PCR-GLOBWB Groundwater Abstractions',
	        subtitle=sprintf('Min: %s, Max: %s', formatC( minima, format='e', digits=2 ), formatC( maxima, format='e', digits=2 ) ),
            x='',
            y='') +
    	theme(plot.title=element_text(size=24),
            plot.subtitle=element_text(size=20),
            legend.title=element_text(size=24),
            legend.text=element_text(size=20),
            panel.grid.major=element_blank(), 
		    panel.grid.minor=element_blank(), 
		    panel.background=element_blank(), 
		    axis.line=element_blank(), 
		    axis.text=element_blank(), 
		    axis.ticks=element_blank())
    # Save plot
    ggsave(path,
    	width = 7,
    	height = 4)#, dpi = 1200)
    print(sprintf('Plot saved to %s',path))
}

ggPlot(map.df,'dif_map_2000_to.png','dif.2000.To','USGS Total Groundwater Withdrawals minus PCR-GLOBWB Groundwater Abstractions, 2000')
ggPlot(map.df,'dif_map_2000_fr.png','dif.2000.Fr','USGS Freshwater Groundwater Withdrawals minus PCR-GLOBWB Groundwater Abstractions, 2000')
ggPlot(map.df,'dif_map_2010_to.png','dif.2010.To','USGS Total Groundwater Withdrawals minus PCR-GLOBWB Groundwater Abstractions, 2010')
ggPlot(map.df,'dif_map_2010_fr.png','dif.2010.Fr','USGS Freshwater Groundwater Withdrawals minus PCR-GLOBWB Groundwater Abstractions, 2010')
