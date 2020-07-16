#com <- read.csv('cropcommodity_tradelist.csv')

load('E0.Rdata')

load('P0.RData')

load('R0.RData')

#head(com)
#head(E0)
#head(Pkbyc)
#head(R0)

#dim(com)
#attributes(com)

#dim(E0)
#attributes(E0)
write.csv(as.matrix(E0),'E0.csv')

#dim(Pkbyc)
#attributes(Pkbyc)
#head(Pkbyc)
#ls(Pkbyc)
#str(Pkbyc)
write.csv(as.matrix(Pkbyc['P0']),'P0.csv')

#dim(R0)
#attributes(R0)
#head(R0)
write.csv(as.matrix(R0),'R0.csv')
