

rawdata <- read.csv('Production_Crops_E_All_Data_NOFLAG.csv')[,c(2,4,6,8:64)]

#print(head(rawdata))
#rawdata[is.na(rawdata)] <- 0

#print(unique(rawdata$Item))

# Iterate through countries
for (c in unique(rawdata$Area)) {
    df <- subset(rawdata, Area == c)
    df$total <- rowSums(df[4:60],na.rm=T) # sum total over all years to determine most important crops
    # Iterate over elements (harvest, production, and yield)
    for (e in c('Area harvested','Production','Yield')) {
        temp <- subset(df, Element == e)
        sum <- sum(temp$total) # sum of element over all years
        temp$fract <- temp$total / sum # fraction of element attributable to each crop
        temp <- temp[order(-temp$fract),] # sort largest to smallest fraction to select important crops
        print(head(temp[,c(1:3,62)],20))

        # Plot total with top 5 crops for this country-element pair

        break

    }
    break
}
