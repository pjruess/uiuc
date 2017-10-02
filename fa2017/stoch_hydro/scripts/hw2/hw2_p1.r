# Consider two 5-acre experimental watersheds, one continually maintained with a
# low-density brush cover (Watershed 1) and the other allowed to naturally develop
# a more dense brush cover (Watershed 2) over the 11-year period of record. The
# annual maximum discharges were recorded for each year of record on both
# watersheds, with the results given in the table below. We expect that the annual
# maximum discharge would be greater in Watershed 1 with low-density brush
# cover. Is there a statistically significant difference in medians of annual maximum
# discharge for the two watersheds?

wsheds <- read.csv('hw2_data.csv')

# Wilcox test of medians
library(exactRankTests)
library(coin)
wilcox.exact(wsheds$Watershed1_cms,wsheds$Watershed2_cms,alternative='greater')

# Result: p-value: 0.034
# p < alpha = 0.05, so reject Ho -> medians are different. 