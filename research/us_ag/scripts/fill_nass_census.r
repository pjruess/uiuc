### Functions for filling USDA NASS redacted Census data and unreported Survey data
# Written by Paul J. Ruess
# January, 2020

# Fill function
# Format must be NASS dataframe with columns: 
fill <- function(df,cnty,type) {

    # Remove data that can't be reconciled with county resolution
    df <- df[(!df$Geo.Level %in% c('AMERICAN INDIAN RESERVATION','WATERSHED')),]

    # Convert code columns to character (Census reads as integer)
    df$State.ANSI <- sprintf('%02d',df$State.ANSI)
    df$Ag.District.Code <- sprintf('%02d',df$Ag.District.Code)
    df$County.ANSI <- sprintf('%03d',df$County.ANSI)

    # Remove commas in value column
    df$Value <- gsub(',','',df$Value)

    # Convert value column to numeric (Census reads as character)
    df$Value <- as.numeric(df$Value)

    # Define GEOID column for merging
    df$GEOID <- paste( sprintf('%02d', as.numeric(df$State.ANSI)), sprintf('%03d', as.numeric(df$County.ANSI)), sep='' )

    write.csv(df,sprintf('../data/compare_census_survey/output/census/soybeans_census_raw_clean_%s_allyears.csv',type),row.names=F)

    final <- data.frame()

    # For each year, merge with counties dataframe to 
    for (y in unique(df$Year)) {

        # Create empty dataframe for year data
        year.df <- data.frame()

        # Select year
        temp <- df[df$Year == y,]

        # Merge with list of all counties
        temp <- merge(temp,cnty,by='GEOID',all=T)

        # Select only useful columns
        temp <- temp[,c('GEOID','Year','Geo.Level','State','State.ANSI','Ag.District','Ag.District.Code','County','County.ANSI','Commodity','Data.Item','Value')]

        # Remove 'OTHER STATES' values to avoid discrepancies
        temp <- temp[!(temp$Geo.Level=='STATE' & temp$State == 'OTHER STATES'),]

        # Remove 'OTHER DISTRICTS, ALL COUNTIES' to avoid discrepancies
        temp <- temp[!(temp$Geo.Level=='AGRICULTURAL DISTRICT' & temp$Ag.District == 'OTHER DISTRICTS, ALL COUNTIES'),]

        # Remove 'OTHER DISTRICTS, ALL COUNTIES' to avoid discrepancies
        temp <- temp[!(temp$Geo.Level=='COUNTY' & temp$County == 'OTHER (COMBINED) COUNTIES'),]

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
        state.red <- temp.all.states[is.na(temp.all.states$Value),]$State.ANSI
        state.miss <- setdiff(all.states,states)

        # Add missing state rows with appropriate value based on dif b/w national and sum of states
        for (s in state.red) {
            temp.all.states[temp.all.states$State.ANSI == s & temp.all.states$Geo.Level == 'STATE',]$Value = state.diff/length(state.red)
        }

        for (s in state.miss) {
            temp.all.states[nrow(temp.all.states)+1,] = list(NA,y,'STATE',NA,s,NA,NA,NA,NA,comm,dati,NA)
        }

        # Add state data to final df
        year.df <- rbind(year.df,temp.all.states)

        ### For each state, distribute dif b/w state total and sum of ag dists to remaining ag dists
        for (s in temp.all.states$State.ANSI) { 

            # Get list of all ag districts in current state
            all.cntys <- unique(cnty[cnty$State.Code == s,]$GEOID)

            if (s %in% state.miss) {
                temp.all.cntys <- temp.all.states[0,]
            } else {
                temp.all.cntys <- temp[temp$Geo.Level=='COUNTY' & !is.na(temp$Geo.Level) & temp$State.ANSI == s,]
            }

            # Extract state value to variable
            state.tot <- as.numeric(temp.all.states[temp.all.states$Geo.Level=='STATE' & !is.na(temp.all.states$Geo.Level) & temp.all.states$State.ANSI == s,]$Value)

            # Sum total for ag dists in state and calculate difference
            cnty.sum <- sum(as.numeric(temp.all.cntys$Value),na.rm=T)
            cntys <- unique(sprintf('%05d',as.numeric(temp.all.cntys$GEOID)))
            cnty.diff <- state.tot - cnty.sum
            cnty.red <- temp.all.cntys[is.na(temp.all.cntys$Value),]$GEOID
            cnty.miss <- setdiff(all.cntys,cntys)

            # Add missing ag dist rows w appropriate value based on dif b/w state and sum of ag dists
            for (c in cnty.red) {
                temp.all.cntys[temp.all.cntys$GEOID == c & temp.all.cntys$Geo.Level == 'COUNTY',]$Value = cnty.diff/length(cnty.red)
            }

            for (c in cnty.miss) {
                temp.all.cntys[nrow(temp.all.cntys)+1,] = list(c,y,'COUNTY',NA,s,NA,NA,NA,NA,comm,dati,NA)
            }

            # Add ag district data to final df
            year.df <- rbind(year.df,temp.all.cntys)

        }


        # Save output for selected year
        write.csv(year.df,sprintf('../data/compare_census_survey/output/census/soybeans_census_filled_%s_%s.csv',type,y),row.names=F)

        # Add to final dataframe for comprehensive, all-years data
        final <- rbind(final,year.df)
    }

    # Save output for all years
    write.csv(final,sprintf('../data/compare_census_survey/output/census/soybeans_census_filled_%s_allyears.csv',type),row.names=F)

}

# All counties, ag districts, and states
cnty <- read.csv('../../always_data/state_district_county_clean.csv')

# Format county columns for merge with census and survey data
cnty$State.Code <- sprintf('%02d',cnty$State)
cnty$District.Code <- sprintf('%02d',cnty$District)
cnty$County.Code <- sprintf('%03d',cnty$County)
cnty$GEOID <- sprintf('%05d',cnty$GEOID)
cnty <- cnty[,c('State.Code','District.Code','County.Code','GEOID','Name')]

# Survey data path
for (i in c('area','prod')){
    path <- read.csv(sprintf('../data/compare_census_survey/census_soybeans_%s.csv',i))
    fill(path,cnty,type=i)
}
