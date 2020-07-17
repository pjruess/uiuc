df <- read.csv('corn_simplified_state.csv')

df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,', '),recursive=F))

print(head(df))
