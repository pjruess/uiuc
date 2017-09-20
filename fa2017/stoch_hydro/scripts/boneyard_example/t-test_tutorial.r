boneyard2012 <- read.csv('Boneyard_2012todate.csv')
boneyard1948 <- read.csv('Boneyard_1948-1960.csv')

# colnames(boneyard1948)

# T-test
# Mudeveloped(2012) - Mundeveloped(1948) > 0 <-- greater
t.test(x=boneyard2012$FlowCFS,y=boneyard1948$FlowCFS,alternative='greater',var.equal=FALSE)

# P-value is smaller than alpha, so reject null hypothesis