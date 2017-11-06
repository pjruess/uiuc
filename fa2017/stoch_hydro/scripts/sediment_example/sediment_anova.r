sed <- read.csv('Sediment_example.csv')

sed$Method = as.numeric(sed$Method)

# Method+Month uses variables only, with no interaction
# Method*Month uses both variables and interaction
# Method:Month uses only interaction
sed.aov2 <- aov(SedimentTPD~Method*Month,data=sed)
summary(sed.aov2)

# model.tables(sed.aov2)
