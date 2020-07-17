### Functions for filling USDA NASS redacted Census data and unreported Survey data
# Written by Paul J. Ruess
# January, 2020

# Fill function
# Format must be NASS dataframe with columns: 
fill <- function(path,cnty,crop,type) {

    # Read in Survey data
    df <- read.csv(path)

    # Select crop
    df <- df[df$Commodity == crop,]

    # Iterate to accurately calculate Wheat stuff



    # Lowercase crop label
    clab <- tolower(crop)

    # Remove 'YEAR - FORECAST' BS (only present in survey data)
    df <- df[df$Period == 'YEAR',]

    # Convert code columns to character
    df$State.ANSI <- sprintf('%02d',df$State.ANSI)
    df$Ag.District.Code <- sprintf('%02d',df$Ag.District.Code)
    df$County.ANSI <- sprintf('%03d',df$County.ANSI)

    # Remove commas in value column
    df$Value <- gsub(',','',df$Value)

    # Convert value column to numeric
    df$Value <- as.numeric(df$Value)

    # Define GEOID column for merging
    df$GEOID <- paste( sprintf('%02d', as.numeric(df$State.ANSI)), sprintf('%03d', as.numeric(df$County.ANSI)), sep='' )

    # If Wheat, merge all three unique types
    #if (crop == 'WHEAT'){
    #    if (type == 'area') df$Data.Item <- 'WHEAT - ACRES HARVESTED'
    #    if (type == 'prod_mass') df$Data.Item <- 'WHEAT - PRODUCTION, MEASURED IN BU'
    #    library(data.table)
    #    setDT(df)[ ,
    #              .(Program=which.max(Program,na.rm=T),
    #                Year=which.max(Year,na.rm=T),
    #                Period=which.max(Period,na.rm=T),
    #                Week.Ending=which.max(Week.Ending,na.rm=T),
    #                Geo.Level=which.max(Geo.Level,na.rm=T),
    #                State=which.max(State,na.rm=T),
    #                State.ANSI=which.max(State.ANSI,na.rm=T),
    #                Ag.District=which.max(Ag.District,na.rm=T),
    #                Ag.District.Code=which.max(Ag.District.Code,na.rm=T),
    #                County=which.max(County,na.rm=T),
    #                County.ANSI=which.max(County.ANSI,na.rm=T),
    #                Zip.Code=which.max(Zip.Code,na.rm=T),
    #                Region=which.max(Region,na.rm=T),
    #                watershed_code=which.max(watershed_code,na.rm=T),
    #                Watershed=which.max(Watershed,na.rm=T),
    #                Commodity=which.max(Commodity,na.rm=T),
    #                Data.Item=which.max(Data.Item,na.rm=T),
    #                Domain=which.max(Domain,na.rm=T),
    #                Domain.Category=which.max(Domain.Category,na.rm=T)),
    #    by = GEOID ]

    #    print(head(df))
    #    temp <- aggregate(Value~Program+Year+Period+Week.Ending+Geo.Level+State+State.ANSI+Ag.District+Ag.District.Code+County+County.ANSI+Zip.Code+Region+watershed_code+Watershed+Commodity+Data.Item+Domain+Domain.Category,df,sum)
    #    #df <- merge(temp,df,by='GEOID')
    #    print(head(temp))
    #    print(head(df))
    #    break
    #    #df <- merge(aggregate(Value~GEOID,df,sum),df,by='GEOID')
    #}

    # Remove 'OTHER STATES' values to avoid discrepancies
    df <- df[!(df$Geo.Level=='STATE' & df$State == 'OTHER STATES'),]

    # Remove 'OTHER DISTRICTS, ALL COUNTIES' to avoid discrepancies
    df <- df[!(df$Geo.Level=='AGRICULTURAL DISTRICT' & df$Ag.District == 'OTHER DISTRICTS, ALL COUNTIES'),]

    # Remove 'OTHER DISTRICTS, ALL COUNTIES' to avoid discrepancies
    df <- df[!(df$Geo.Level=='COUNTY' & df$County == 'OTHER (COMBINED) COUNTIES'),]

    write.csv(df,sprintf('output/survey/%s/survey_clean_%s_%s.csv',type,type,clab),row.names=F)

    final <- data.frame()

    # For each year, merge with counties dataframe to 
    for (y in c(2012,2013,2014,2015,2016,2017,2018)){#unique(df$Year)) {

        # Create empty dataframe for year data
        year.df <- data.frame()

        # Select year
        temp <- df[df$Year == y,]

        # Merge with list of all counties
        temp <- merge(temp,cnty,by='GEOID',all=T)

        # Select only useful columns
        temp <- temp[,c('GEOID','Year','Geo.Level','State','State.ANSI','Ag.District','Ag.District.Code','County','County.ANSI','Commodity','Data.Item','Value')]

        ### For nation, distribute b/w national total and sum of states to remaining states

        # Extract national value to variable
        natl <- temp[temp$Geo.Level=='NATIONAL' & !is.na(temp$Geo.Level),]
        natl.tot <- as.numeric(natl$Value)
        comm <- temp[temp$Geo.Level=='NATIONAL' & !is.na(temp$Geo.Level),]$Commodity
        dati <- temp[temp$Geo.Level=='NATIONAL' & !is.na(temp$Geo.Level),]$Data.Item

        # Add national data to final df
        year.df <- rbind(year.df,natl)

        # Sum total for states and calculate difference
        temp.all.states <- temp[temp$Geo.Level=='STATE' & !is.na(temp$Geo.Level),]
        state.sum <- sum(as.numeric(temp.all.states$Value),na.rm=T)
        all.states <- unique(cnty$State.Code)
        states <- unique(sprintf('%02d',as.numeric(temp.all.states$State.ANSI)))
        state.diff <- natl.tot - state.sum
        state.miss <- setdiff(all.states,states)

        # Add missing state rows with appropriate value based on dif b/w national and sum of states
        if (state.diff == 0) {
            for (s in state.miss) {
                temp.all.states[nrow(temp.all.states)+1,] = list(NA,y,'STATE',NA,s,NA,NA,NA,NA,comm,dati,NA)
            }
        } else {
            for (s in state.miss) {
                temp.all.states[nrow(temp.all.states)+1,] = list(NA,y,'STATE',NA,s,NA,NA,NA,NA,comm,dati,state.diff/length(state.miss))
            }
        }

        # Add state data to final df
        year.df <- rbind(year.df,temp.all.states)

        ### For each state, distribute dif b/w state total and sum of ag dists to remaining ag dists
        for (s in temp.all.states$State.ANSI) { 

            # Get list of all ag districts in current state
            all.dists <- unique(cnty[cnty$State.Code == s,]$District.Code)

            if (s %in% state.miss) {
                temp.all.dists <- temp.all.states[0,]
                for (d in all.dists) {
                    temp.all.dists[nrow(temp.all.dists)+1,] = list(NA,y,'AGRICULTURAL DISTRICT',NA,s,NA,d,NA,NA,comm,dati,NA)
                }
            } else { 

                # Extract state value to variable
                state.tot <- as.numeric(temp[temp$Geo.Level=='STATE' & !is.na(temp$Geo.Level) & temp$State.ANSI == s,]$Value)

                # Sum total for ag dists in state and calculate difference
                temp.all.dists <- temp[temp$Geo.Level=='AGRICULTURAL DISTRICT' & !is.na(temp$Geo.Level) & temp$State.ANSI == s,]
                dist.sum <- sum(as.numeric(temp.all.dists$Value),na.rm=T)
                dists <- unique(sprintf('%02d',as.numeric(temp.all.dists$Ag.District.Code)))
                dist.diff <- state.tot - dist.sum
                dist.miss <- setdiff(all.dists,dists)

                # Add missing ag dist rows w appropriate value based on dif b/w state and sum of ag dists
                if (dist.diff == 0) {
                    for (d in dist.miss) {
                        temp.all.dists[nrow(temp.all.dists)+1,] = list(NA,y,'AGRICULTURAL DISTRICT',NA,s,NA,d,NA,NA,comm,dati,NA)
                    }
                } else {
                    for (d in dist.miss) {
                        temp.all.dists[nrow(temp.all.dists)+1,] = list(NA,y,'AGRICULTURAL DISTRICT',NA,s,NA,d,NA,NA,comm,dati,dist.diff/length(dist.miss))
                    }
                }
            }

            # Add ag district data to final df
            year.df <- rbind(year.df,temp.all.dists)

            # For each ag district, distribute remainder to unreported counties
            for (d in temp.all.dists$Ag.District.Code) {

                # Get list of all ag districts in current state
                all.cntys <- unique(cnty[cnty$State.Code == s & cnty$District == d,]$GEOID)

                # If district is not represented
                if (d %in% dist.miss) {
                    temp.all.cntys <- temp.all.dists[0,]
                    for (c in all.cntys) {
                        temp.all.cntys[nrow(temp.all.cntys)+1,] = list(c,y,'COUNTY',NA,s,NA,d,NA,NA,comm,dati,NA)
                    }
                } else { 

                    # Extract district value to variable
                    dist.tot <- as.numeric(temp[temp$Geo.Level=='AGRICULTURAL DISTRICT' & !is.na(temp$Geo.Level) & temp$Ag.District.Code == d & temp$State.ANSI == s,]$Value)

                    # If state is not at all represented in database, make value zero
                    if ( length(dist.tot) == 0 ) dist.tot <- 0

                    # Sum total for ag dists in state and calculate difference
                    temp.all.cntys <- temp[temp$Geo.Level=='COUNTY' & !is.na(temp$Geo.Level) & temp$Ag.District.Code == d & temp$State.ANSI == s,]
                    cnty.sum <- sum(as.numeric(temp.all.cntys$Value),na.rm=T)
                    cntys <- unique(sprintf('%05d',as.numeric(temp.all.cntys$GEOID)))
                    cnty.diff <- dist.tot - cnty.sum
                    cnty.miss <- setdiff(all.cntys,cntys)

                    # Add missing county rows w appropriate value based on dif b/w dist and sum of counties
                    if (cnty.diff == 0) {
                        for (c in cnty.miss) {
                            temp.all.cntys[nrow(temp.all.cntys)+1,] = list(c,y,'COUNTY',NA,s,NA,d,NA,NA,comm,dati,NA)
                        }
                    } else {
                        for (c in cnty.miss) {
                            temp.all.cntys[nrow(temp.all.cntys)+1,] = list(c,y,'COUNTY',NA,s,NA,d,NA,NA,comm,dati,cnty.diff/length(cnty.miss))
                        }
                    }
                }

                # Add county data to final df
                year.df <- rbind(year.df,temp.all.cntys)

            }

        }

        # Save output for selected year
        #write.csv(year.df,sprintf('output/survey/%s/survey_filled_%s_%s_%s.csv',type,type,clab,y),row.names=F)

        # Add to final dataframe for comprehensive, all-years data
        final <- rbind(final,year.df)
    }

    # Save output for all years
    write.csv(final,sprintf('output/survey/%s/survey_filled_%s_%s_allyears.csv',type,type,clab),row.names=F)

}

# All counties, ag districts, and states
cnty <- read.csv('../../../../research/always_data/state_district_county_clean.csv')

# Format county columns for merge with census and survey data
cnty$State.Code <- sprintf('%02d',cnty$State)
cnty$District.Code <- sprintf('%02d',cnty$District)
cnty$County.Code <- sprintf('%03d',cnty$County)
cnty$GEOID <- sprintf('%05d',cnty$GEOID)
cnty <- cnty[,c('State.Code','District.Code','County.Code','GEOID','Name')]

# List of crops
crops <- c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT')

# Fill Survey data
for (i in c('area','prod_mass')){#,'prod_val')){ # calc yield from filled area and prod
    for (crop in crops){
        path <- sprintf('survey_%s_sctg2_2012-2018.csv',i)
        fill(path,cnty,crop,type=i)
    }
}
