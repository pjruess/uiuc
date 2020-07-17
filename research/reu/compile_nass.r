# Script for compiling multiple dataframes

# Initiate empty data frame
df <- data.frame()

# Define directory
dir <- 'Corn/'

# Loop through all filenames in the directory
for (f in list.files(dir)){

    # Create file path as (dir) variable plus (filename) with no separation between
    path <- paste(dir,f,sep='')
    print(path)

    # Read temporary csv from current file path
    tmp <- read.csv(path)
    print(head(tmp))

    # Add temporary csv to bottom of existing compiled dataframe (df)
    df <- rbind(df,tmp)

}

# Save compiled df to path 'corn_compiled.csv' with no rownames (ie. no ID columns: 1, 2, 3, ...)
write.csv(df,'corn_compiled.csv',row.names=F)
