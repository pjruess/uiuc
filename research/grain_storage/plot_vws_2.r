# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)
library(stringr) # for str_replace_all

plot_vws <- function(states, vws_state, vws_county, commodity, year, identifier, label, mmdata, ncats=8) {
	# Define path to save to
	path <- sprintf('vws_plots/%s/%s_%s_%s.png', tolower(commodity), year, tolower(commodity), label)

	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		if (commodity != 'total'){ next }
	}

	# If vws_path exists, read. Else create. 
	vws <- data.frame()
	vws_path <- sprintf('vws_plot_aggregates/%s_aggregate_%s_data.csv',year,tolower(commodity))

	if (file.exists(vws_path)){
		#print(vws_path)
		vws <- read.csv(vws_path)
	} else {
		# Convert to data tables
		vws_state <- data.table(vws_state)
		vws_county <- data.table(vws_county)

		# If commodity is 'total', aggregate sum of vws df by GEOID 
		if (commodity == 'total') {
			vws_county <- vws_county[, 
				.(Storage_Bu = mean(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = list(GEOID,State.ANSI)
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'GEOID'

			vws_county <- vws_county[, 
				.(Storage_Bu = sum(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = State.ANSI
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'State.ANSI'

	    	vws_state <- vws_state[, 
	    		.(Storage_Bu = mean(Storage_Bu,na.rm=TRUE), 
	    		VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
	    		VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
	    		VWS_m3 = sum(VWS_m3,na.rm=TRUE),
                Harvest_Ac = sum(Harvest_Ac,na.rm=TRUE),
                Production_Bu = sum(Production_Bu,na.rm=TRUE)), 
	    		by = State.ANSI
	    	]
			colnames(vws_state)[colnames(vws_state) == 'by' ] <- 'State.ANSI'

		} else {
			vws_state <- vws_state[vws_state$Commodity == commodity,]
			vws_county <- vws_county[vws_county$Commodity == commodity,]
			vws_county <- vws_county[, 
				.(Storage_Bu = sum(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = State.ANSI
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'State.ANSI'
		}
		vws <- merge(vws_state,vws_county,by='State.ANSI',all = TRUE)
		vws <- data.frame(vws)
		vws$Storage_Bu <- rowSums(vws[,c('Storage_Bu.x','Storage_Bu.y')], na.rm=TRUE)
		vws$VWS_ir_m3 <- rowSums(vws[,c('VWS_ir_m3.x','VWS_ir_m3.y')], na.rm=TRUE)
		vws$VWS_rf_m3 <- rowSums(vws[,c('VWS_rf_m3.x','VWS_rf_m3.y')], na.rm=TRUE)
		vws$VWS_m3 <- rowSums(vws[,c('VWS_m3.x','VWS_m3.y')], na.rm=TRUE)
		vws <- vws[,c('State.ANSI','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Harvest_Ac','Production_Bu')]
		vws[vws <= 0] <- NA

		write.csv(vws,vws_path,row.names=FALSE)
		vws <- read.csv(vws_path)
	}

	# Save min and max for manual assignment across years
	if (!file.exists(minmax.path)){
		#vws[,identifier][vws[,identifier]<=0] <- NA #convert zeros to NA
		minima <- min(vws[,identifier],na.rm=T)
		maxima <- max(vws[,identifier],na.rm=T)
		tempdf <- data.frame(commodity, identifier, year, minima, maxima)
		names(tempdf) <- c('Commodity','Identifier','Year','Minima','Maxima')
		mmdata <- rbind(mmdata, tempdf)
		return(mmdata)
		next
	}

	mmdata.sub <- mmdata[mmdata$Commodity == commodity & mmdata$Identifier == identifier, ]

	if (file.exists(path)){
		next
	}
	
	# Determine minima and maxima for plotting limits
	minima <- min(mmdata.sub$Minima,na.rm=T)
	maxima <- max(mmdata.sub$Maxima,na.rm=T)

	if (minima == floor(minima)){
		minima <- minima - 1
	} else {
		minima <- floor(minima)
	}

	if (maxima == ceiling(maxima)){
		maxima <- maxima + 1
	} else {
		maxima <- ceiling(maxima)
	}

	# Create temp df
	data <- data.frame(id=rownames(states@data),
			   State.ANSI=states@data$STATEFP,
			   NAME=states@data$NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)

	# Correct formatting of vws data for proper merge
    vws$State.ANSI <- as.numeric(vws$State.ANSI)
	vws$State.ANSI <- sprintf('%02d',vws$State.ANSI)
	
	# Merge databases
	data.merge <- merge(data, vws, by='State.ANSI')

	# Fortify data to extract spatial information
	states.fort <- fortify(states)
	map.df <- join(states.fort, data.merge, by='id')
	map.df$plot_fill <- map.df[,identifier]
	map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA

    # Uppercase first letter in string
    simpleCap <- function(x) {
        s <- strsplit(x, ' ')[[1]]
        paste(toupper(substring(s,1,1)),substring(s,2),sep='',collapse=' ')
    }

    # Rename commodity name for plots
    if (commodity == 'total') {
        commoditylab = 'All Commodities'
    } else {
        commoditylab = simpleCap(tolower(str_replace_all(commodity,',',' - ')))
    }

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(name='',
                    palette='YlGnBu',
				    limits=c( minima, maxima ),
				    direction=1, 
				    na.value='grey90') +
		#labs(title=sprintf('%s\n%s, %s', str_replace_all(identifier,'_',' '), simpleCap(tolower(commoditylab)), year),
		    #subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
		labs(x='',
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

    # Function for plotting fractional VWS
    fractVWS <- function(df,path,lab) {
	    # Plot data
	    ggplot(map.df, aes(x=long,y=lat,group=group)) + 
	    	geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
	    	coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		    scale_fill_distiller(name='',
                        palette='Blues',
	    			    limits=c( 0,101 ),
	    			    direction=1, 
	    			    na.value='grey90') +
	    	#labs(title=sprintf('%s\n%s, %s', lab, simpleCap(tolower(commoditylab)), year),
	    	    #subtitle='Min: 0, Max: 100',
	    	labs(x='',
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

    # Function for plotting change over time 
    cot <- function(df,path,limit, label, yr1, yr2) {
	    # Plot data
	    ggplot(map.df, aes(x=long,y=lat,group=group)) + 
	    	geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
	    	coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		    scale_fill_distiller(name='',
                        palette='RdBu',
	    			    limits=c( -limit-1, limit+1 ),
                        direction = 1,
	    			    na.value='grey90') +
	    	#labs(title=sprintf('%s Difference\n%s, %s to %s', label, simpleCap(tolower(commoditylab)), yr1, yr2),
		        #subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
	    	labs(x='',
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

    # If VWS, plot fractional contribution plots...
	if (identifier == 'VWS_m3') {
        # Once for Irrigated VWS
        map.df$plot_fill <- map.df$VWS_ir_m3 / map.df$VWS_m3 * 100.
	    map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA
	    newpath <- sprintf('vws_plots/%s/%s_%s_vws_ir_fraction.png', tolower(commodity), year, tolower(commodity))
	    if (!file.exists(newpath)){
            fractVWS(map.df,newpath,'Irrigated VWS Contribution')
	    }
        
        # Again for Rainfed VWS
        map.df$plot_fill <- map.df$VWS_rf_m3 / map.df$VWS_m3 * 100.
	    map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA
	    newpath <- sprintf('vws_plots/%s/%s_%s_vws_rf_fraction.png', tolower(commodity), year, tolower(commodity))
	    if (!file.exists(newpath)){
            fractVWS(map.df,newpath,'Rainfed VWS Contribution')
	    }
    }

        if (year == '2012') {
            # Time trend plots, 2002 vs. 2007
            vws.2002 <- read.csv(sprintf('vws_plot_aggregates/2002_aggregate_%s_data.csv',tolower(commodity)))
            vws.2007 <- read.csv(sprintf('vws_plot_aggregates/2007_aggregate_%s_data.csv',tolower(commodity)))
            vws.2012 <- read.csv(sprintf('vws_plot_aggregates/2012_aggregate_%s_data.csv',tolower(commodity)))

        	# Correct formatting of vws data for proper merge
        	vws.2002$State.ANSI <- sprintf('%02d',vws.2002$State.ANSI)
        	vws.2007$State.ANSI <- sprintf('%02d',vws.2007$State.ANSI)
        	vws.2012$State.ANSI <- sprintf('%02d',vws.2012$State.ANSI)

            # Change column names for merging
            colnames(vws.2002) <- c('State.ANSI','Storage_Bu.2002','VWS_ir_m3.2002','VWS_rf_m3.2002','VWS_m3.2002','Harvest_Ac.2002','Production_Bu.2002')
            colnames(vws.2007) <- c('State.ANSI','Storage_Bu.2007','VWS_ir_m3.2007','VWS_rf_m3.2007','VWS_m3.2007','Harvest_Ac.2007','Production_Bu.2007')
            colnames(vws.2012) <- c('State.ANSI','Storage_Bu.2012','VWS_ir_m3.2012','VWS_rf_m3.2012','VWS_m3.2012','Harvest_Ac.2012','Production_Bu.2012')
        	
        	# Merge databases
            vws <- merge(vws.2002, vws.2007, by='State.ANSI')
            vws <- merge(vws, vws.2012, by='State.ANSI')
        	data.merge <- merge(data, vws, by='State.ANSI')
            write.csv(data.merge,'vws_plot_aggregates/vws_combined.csv')
        
        	# Fortify data to extract spatial information
        	states.fort <- fortify(states)
        	map.df <- join(states.fort, data.merge, by='id')

            # Create difference columns
        	map.df$VWS_m3.2002to2007 <- map.df$VWS_m3.2007 - map.df$VWS_m3.2002
        	map.df$VWS_m3.2007to2012 <- map.df$VWS_m3.2012 - map.df$VWS_m3.2007
        	map.df$VWS_m3.2002to2012 <- map.df$VWS_m3.2012 - map.df$VWS_m3.2002
        	map.df$VWS_ir_m3.2002to2007 <- map.df$VWS_ir_m3.2007 - map.df$VWS_ir_m3.2002
        	map.df$VWS_ir_m3.2007to2012 <- map.df$VWS_ir_m3.2012 - map.df$VWS_ir_m3.2007
        	map.df$VWS_ir_m3.2002to2012 <- map.df$VWS_ir_m3.2012 - map.df$VWS_ir_m3.2002
        	map.df$VWS_rf_m3.2002to2007 <- map.df$VWS_rf_m3.2007 - map.df$VWS_rf_m3.2002
        	map.df$VWS_rf_m3.2007to2012 <- map.df$VWS_rf_m3.2012 - map.df$VWS_rf_m3.2007
        	map.df$VWS_rf_m3.2002to2012 <- map.df$VWS_rf_m3.2012 - map.df$VWS_rf_m3.2002
        	map.df$Storage_Bu.2002to2007 <- map.df$Storage_Bu.2007 - map.df$Storage_Bu.2002
        	map.df$Storage_Bu.2007to2012 <- map.df$Storage_Bu.2012 - map.df$Storage_Bu.2007
        	map.df$Storage_Bu.2002to2012 <- map.df$Storage_Bu.2012 - map.df$Storage_Bu.2002
        	map.df$Harvest_Ac.2002to2007 <- map.df$Harvest_Ac.2007 - map.df$Harvest_Ac.2002
        	map.df$Harvest_Ac.2007to2012 <- map.df$Harvest_Ac.2012 - map.df$Harvest_Ac.2007
        	map.df$Harvest_Ac.2002to2012 <- map.df$Harvest_Ac.2012 - map.df$Harvest_Ac.2002
        	map.df$Production_Bu.2002to2007 <- map.df$Production_Bu.2007 - map.df$Production_Bu.2002
        	map.df$Production_Bu.2007to2012 <- map.df$Production_Bu.2012 - map.df$Production_Bu.2007
        	map.df$Production_Bu.2002to2012 <- map.df$Production_Bu.2012 - map.df$Production_Bu.2002

            # Plot Scale Limits
            vws_lim <- max(max(map.df$VWS_m3.2002to2007,na.rm=TRUE), 
                           max(map.df$VWS_m3.2007to2012,na.rm=TRUE), 
                           max(map.df$VWS_m3.2002to2012,na.rm=TRUE), 
                           abs(min(map.df$VWS_m3.2002to2007,na.rm=TRUE)),
                           abs(min(map.df$VWS_m3.2007to2012,na.rm=TRUE)),
                           abs(min(map.df$VWS_m3.2002to2012,na.rm=TRUE)))
            vws_ir_lim <- max(max(map.df$VWS_ir_m3.2002to2007,na.rm=TRUE), 
                              max(map.df$VWS_ir_m3.2007to2012,na.rm=TRUE), 
                              max(map.df$VWS_ir_m3.2002to2012,na.rm=TRUE), 
                              abs(min(map.df$VWS_ir_m3.2002to2007,na.rm=TRUE)),
                              abs(min(map.df$VWS_ir_m3.2007to2012,na.rm=TRUE)),
                              abs(min(map.df$VWS_ir_m3.2002to2012,na.rm=TRUE)))
            vws_rf_lim <- max(max(map.df$VWS_rf_m3.2002to2007,na.rm=TRUE), 
                              max(map.df$VWS_rf_m3.2007to2012,na.rm=TRUE), 
                              max(map.df$VWS_rf_m3.2002to2012,na.rm=TRUE), 
                              abs(min(map.df$VWS_rf_m3.2002to2007,na.rm=TRUE)),
                              abs(min(map.df$VWS_rf_m3.2007to2012,na.rm=TRUE)),
                              abs(min(map.df$VWS_rf_m3.2002to2012,na.rm=TRUE)))
            stor_lim <- max(max(map.df$Storage_Bu.2002to2007,na.rm=TRUE), 
                            max(map.df$Storage_Bu.2007to2012,na.rm=TRUE), 
                            max(map.df$Storage_Bu.2002to2012,na.rm=TRUE), 
                            abs(min(map.df$Storage_Bu.2002to2007,na.rm=TRUE)),
                            abs(min(map.df$Storage_Bu.2007to2012,na.rm=TRUE)),
                            abs(min(map.df$Storage_Bu.2002to2012,na.rm=TRUE)))
            harv_lim <- max(max(map.df$Harvest_Ac.2002to2007,na.rm=TRUE), 
                            max(map.df$Harvest_Ac.2007to2012,na.rm=TRUE), 
                            max(map.df$Harvest_Ac.2002to2012,na.rm=TRUE), 
                            abs(min(map.df$Harvest_Ac.2002to2007,na.rm=TRUE)),
                            abs(min(map.df$Harvest_Ac.2007to2012,na.rm=TRUE)),
                            abs(min(map.df$Harvest_Ac.2002to2012,na.rm=TRUE)))
            prod_lim <- max(max(map.df$Production_Bu.2002to2007,na.rm=TRUE), 
                            max(map.df$Production_Bu.2007to2012,na.rm=TRUE), 
                            max(map.df$Production_Bu.2002to2012,na.rm=TRUE), 
                            abs(min(map.df$Production_Bu.2002to2007,na.rm=TRUE)),
                            abs(min(map.df$Production_Bu.2007to2012,na.rm=TRUE)),
                            abs(min(map.df$Production_Bu.2002to2012,na.rm=TRUE)))

            # Plot difference maps for VWS and Storage and Capture Efficiencies
            # 2007 - 2002
            # VWS
        	map.df$plot_fill <- map.df$VWS_m3.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_lim,'VWS','2002','2007')
	        }

            # VWS Irrigated
        	map.df$plot_fill <- map.df$VWS_ir_m3.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_ir_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_ir_lim,'VWS Irrigated','2002','2007')
	        }

            # VWS Rainfed
        	map.df$plot_fill <- map.df$VWS_rf_m3.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_rf_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_rf_lim,'VWS Rainfed','2002','2007')
	        }

            # Storage
        	map.df$plot_fill <- map.df$Storage_Bu.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/storage_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,stor_lim,'Storage','2002','2007')
	        }

            # Harvested Area
        	map.df$plot_fill <- map.df$Harvest_Ac.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/harv_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,harv_lim,'Harvested Area','2002','2007')
	        }

            # Production
        	map.df$plot_fill <- map.df$Production_Bu.2002to2007
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/prod_diff_2007_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,prod_lim,'Production','2002','2007')
	        }

            # 2012 - 2007
        	# VWS
            map.df$plot_fill <- map.df$VWS_m3.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_lim,'VWS','2007','2012')
	        }

        	# VWS Irrigated
            map.df$plot_fill <- map.df$VWS_ir_m3.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_ir_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_ir_lim,'VWS Irrigated','2007','2012')
	        }

        	# VWS Rainfed
            map.df$plot_fill <- map.df$VWS_rf_m3.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_rf_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_rf_lim,'VWS Rainfed','2007','2012')
	        }

            # Storage
        	map.df$plot_fill <- map.df$Storage_Bu.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/storage_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,stor_lim,'Storage','2007','2012')
	        }

            # Harvested Area
        	map.df$plot_fill <- map.df$Harvest_Ac.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/harv_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,harv_lim,'Harvested Area','2007','2012')
	        }

            # Production
        	map.df$plot_fill <- map.df$Production_Bu.2007to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/prod_diff_2012_vs_2007.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,prod_lim,'Production','2007','2012')
	        }

            # 2012 - 2002
            # VWS
        	map.df$plot_fill <- map.df$VWS_m3.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_lim,'VWS','2002','2012')
	        }

            # VWS Irrigated
        	map.df$plot_fill <- map.df$VWS_ir_m3.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_ir_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_ir_lim,'VWS Irrigated','2002','2012')
	        }

            # VWS Rainfed
        	map.df$plot_fill <- map.df$VWS_rf_m3.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/vws_rf_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,vws_rf_lim,'VWS Rainfed','2002','2012')
	        }

            # Storage
        	map.df$plot_fill <- map.df$Storage_Bu.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/storage_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,stor_lim,'Storage','2002','2012')
	        }

            # Harvested Area
        	map.df$plot_fill <- map.df$Harvest_Ac.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/harv_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,harv_lim,'Harvested Area','2002','2012')
	        }

            # Production
        	map.df$plot_fill <- map.df$Production_Bu.2002to2012
        	map.df$plot_fill[map.df$plot_fill==0] <- NA #convert zeros to NA
	        newpath <- sprintf('vws_plots/%s/prod_diff_2012_vs_2002.png', tolower(commodity), tolower(commodity))
	        if (!file.exists(newpath)){
                cot(map.df,newpath,prod_lim,'Production','2002','2012')
	        }

        }

	return(mmdata)
}

# Import polygon shapefile
states_data <- readOGR('cb_2016_us_state_500k','cb_2016_us_state_500k')

# Select only by certain commodity
commodities <- c('BARLEY','CORN,GRAIN','CORN,SILAGE','OATS','PEAS,DRYEDIBLE','RYE','SORGHUM,GRAIN','SORGHUM,SILAGE','SOYBEANS','SUNFLOWER','WHEAT','SAFFLOWER','CANOLA','MUSTARD,SEED','FLAXSEED','LENTILS','PEAS,AUSTRIANWINTER','RAPESEED','total')

# Select years to iterate over
years <- c('2002','2007','2012')

# List of identifiers and labels
#identifiers <- c('Storage_Bu','Harvest_Ac','Percent_Harvest','Production_Bu','CWU_bl_m3yr','CWU_gn_m3yr','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency')
#labels <- c('storage','harvest','percent_harvest','production','cwu_irrigated','cwu_rainfed','vws_irrigated','vws_rainfed','vws','precip','precip_volume','capture_efficiency')
identifiers <- c('Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Harvest_Ac','Production_Bu')
labels <- c('storage','vws_irrigated','vws_rainfed','vws','harvest','production')

#identifiers <- c('Storage_Bu')
#labels <- c('storage')
commodities <- c('total')

df <- data.frame(identifiers, labels)
print(df)

# Retrieve minima and maxima data
minmax.path <- 'vws_plots/minmax_database.csv'

if (file.exists(minmax.path)){
	minmax.data <- read.csv(minmax.path)
} else {
    print('Creating Min/Max Database')
	minmax.data <- data.frame(matrix(ncol=5,nrow=0))
	minmax.names <- c('Commodity','Identifier','Year','Minima','Maxima')
	colnames(minmax.data) <- minmax.names
}

# Create plots for all commodity-year-identifier pairs
for (c in commodities) {
	for (i in 1:nrow(df)) {
		for (y in years){
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])
			# Read in VWS data
			vws_state_data <- read.csv( sprintf('final_results/final_state_%s.csv', y) )[, c('State.ANSI','Commodity','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Harvest_Ac','Production_Bu')]
			vws_state_data$State.ANSI <- sprintf('%02d',vws_state_data$State.ANSI)

			vws_county_data <- read.csv( sprintf('final_results/final_county_%s.csv', y) )[, c('GEOID','Commodity','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3')]
			vws_county_data$GEOID <- sprintf('%05d',vws_county_data$GEOID)
			vws_county_data$State.ANSI <- substr(vws_county_data$GEOID,start=1,stop=2)
			vws_county_data$State.ANSI <- as.numeric(vws_county_data$State.ANSI)
			vws_county_data$State.ANSI <- sprintf('%02d',vws_county_data$State.ANSI)

			# Plot data
			#print( sprintf('Plotting %s for commodity %s, year %s', id, c, y) )
			tryCatch({
			       	minmax.data <- plot_vws(states_data, vws_state_data, vws_county_data, c, y, id, label, minmax.data, ncats=8)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}

if (!file.exists(minmax.path)){
	minmax.data <- data.table(minmax.data)
	minmax.data[ , list(Minima = min(Minima), Maxima = max(Maxima)), by=c('Commodity','Identifier') ]
	write.csv(minmax.data,minmax.path,row.names=FALSE)
    print('Min/Max Database created. Please run script again to create plots.')
}
