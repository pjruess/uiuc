library(reshape2)
library(stringi)

# Control scientific notation
#options(scipen=-999) # -999 for scientific notation, 999 for non-scientific notation

# Compile all GWD data for WRR publication

# Read State FIPS codes
fips <- read.csv('state_fips.csv')[,c(3,4)]
fips <- fips[fips$FIPS != 0,]

# Read FAF id data
#faf <- read.csv('cfs_faf4_crosswalk.csv')
#faf$id <- stri_pad_right(paste('E330000US0',faf$STFIPS,faf$CFSMA,sep=''),16,0)
#faf <- faf[,c(6,8)]
faf <- read.csv('cfs_faf4_crosswalk_edit.csv')[,c(6,8)]

# Read DWE
dwe02.s.2 <- read.csv('DWE/2000/GWDexports2000_SCTG2intl_state.csv')
dwe02.s.3 <- read.csv('DWE/2000/GWDexports2000_SCTG3intl_state.csv')
dwe02.s.4 <- read.csv('DWE/2000/GWDexports2000_SCTG4intl_state.csv')
dwe12.s.2 <- read.csv('DWE/2010/GWDexports2010_SCTG2intl_state.csv')
dwe12.s.3 <- read.csv('DWE/2010/GWDexports2010_SCTG3intl_state.csv')
dwe12.s.4 <- read.csv('DWE/2010/GWDexports2010_SCTG4intl_state.csv')
dwe12.f.2 <- read.csv('DWE/2010/GWDexports2010_SCTG2intl_faf.csv')
dwe12.f.3 <- read.csv('DWE/2010/GWDexports2010_SCTG3intl_faf.csv')
dwe12.f.4 <- read.csv('DWE/2010/GWDexports2010_SCTG4intl_faf.csv')

# Read DWT
dwt02.s.2 <- read.csv('DWT/2000/GWDtransfers2000_SCTG2dom_state.csv')
dwt02.s.3 <- read.csv('DWT/2000/GWDtransfers2000_SCTG3dom_state.csv')
dwt02.s.4 <- read.csv('DWT/2000/GWDtransfers2000_SCTG4dom_state.csv')
dwt12.s.2 <- read.csv('DWT/2010/GWDtransfers2010_SCTG2dom_state.csv')
dwt12.s.3 <- read.csv('DWT/2010/GWDtransfers2010_SCTG3dom_state.csv')
dwt12.s.4 <- read.csv('DWT/2010/GWDtransfers2010_SCTG4dom_state.csv')
dwt12.f.2 <- read.csv('DWT/2010/GWDtransfers2010_SCTG2dom_faf.csv')
dwt12.f.3 <- read.csv('DWT/2010/GWDtransfers2010_SCTG3dom_faf.csv')
dwt12.f.4 <- read.csv('DWT/2010/GWDtransfers2010_SCTG4dom_faf.csv')

clean <- function(df,ori,des,sctg) {
    df <- df[c(-1)]
    colnames(df)[1] <- 'id' 
    df <- melt(df,id.vars='id')
    colnames(df) <- c(ori,des,sctg)
    return(df)
}

# Merge DWE 2002
dwe02.s.2 <- clean(dwe02.s.2,'ori','des','sctg2')
dwe02.s.3 <- clean(dwe02.s.3,'ori','des','sctg3')
dwe02.s.4 <- clean(dwe02.s.4,'ori','des','sctg4')
dwe02 <- merge(merge(dwe02.s.2,dwe02.s.3),dwe02.s.4)
dwe02 <- merge(dwe02,fips,by.x='ori',by.y='FIPS')
dwe02$ori <- dwe02$Name
dwe02$Name <- NULL
dwe02$year <- 2002
dwe02$ori_res <- 'state'
dwe02$des_res <- 'country'
#print(head(dwe02,20))

# Merge DWT 2002
dwt02.s.2 <- clean(dwt02.s.2,'ori','des','sctg2')
dwt02.s.3 <- clean(dwt02.s.3,'ori','des','sctg3')
dwt02.s.4 <- clean(dwt02.s.4,'ori','des','sctg4')
dwt02 <- merge(merge(dwt02.s.2,dwt02.s.3),dwt02.s.4)
dwt02$des <- substr(dwt02$des,2,nchar(as.character(dwt02$des)))
dwt02 <- merge(dwt02,fips,by.x='ori',by.y='FIPS')
dwt02$ori <- dwt02$Name
dwt02$Name <- NULL
dwt02 <- merge(dwt02,fips,by.x='des',by.y='FIPS')
dwt02$des <- dwt02$Name
dwt02$Name <- NULL
dwt02$year <- 2002
dwt02$ori_res <- 'state'
dwt02$des_res <- 'state'
#print(head(dwt02,20))

# Merge all 2002 data
dwf02 <- rbind(dwe02,dwt02)
dwf02$year <- 2002
#print(dwf02)

# Merge DWE 2012
# States
dwe12.s.2 <- clean(dwe12.s.2,'ori','des','sctg2')
dwe12.s.3 <- clean(dwe12.s.3,'ori','des','sctg3')
dwe12.s.4 <- clean(dwe12.s.4,'ori','des','sctg4')
dwe12.s <- merge(merge(dwe12.s.2,dwe12.s.3),dwe12.s.4)
dwe12.s <- merge(dwe12.s,fips,by.x='ori',by.y='FIPS')
dwe12.s$ori <- dwe12.s$Name
dwe12.s$Name <- NULL
dwe12.s$ori_res <- 'state'
dwe12.s$des_res <- 'country'
dwe12.s$year <- 2012

# FAF zones
dwe12.f.2 <- clean(dwe12.f.2,'ori','des','sctg2')
dwe12.f.3 <- clean(dwe12.f.3,'ori','des','sctg3')
dwe12.f.4 <- clean(dwe12.f.4,'ori','des','sctg4')
dwe12.f <- merge(merge(dwe12.f.2,dwe12.f.3),dwe12.f.4)
dwe12.f <- merge(dwe12.f,faf,by.x='ori',by.y='id')
dwe12.f$ori <- dwe12.f$CFSAREANAM
dwe12.f$CFSAREANAM <- NULL
dwe12.f$ori_res <- 'faf'
dwe12.f$des_res <- 'country'
dwe12.f$year <- 2012

#dwe12 <- rbind(dwe12.s,dwe12.f)
#print(dwe12)

# Merge DWT 2012
# States
dwt12.s.2 <- clean(dwt12.s.2,'ori','des','sctg2')
dwt12.s.3 <- clean(dwt12.s.3,'ori','des','sctg3')
dwt12.s.4 <- clean(dwt12.s.4,'ori','des','sctg4')
dwt12.s <- merge(merge(dwt12.s.2,dwt12.s.3),dwt12.s.4)
dwt12.s$des <- substr(dwt12.s$des,2,nchar(as.character(dwt12.s$des)))
dwt12.s <- merge(dwt12.s,fips,by.x='des',by.y='FIPS')
dwt12.s$des <- dwt12.s$Name
dwt12.s$Name <- NULL
dwt12.s <- merge(dwt12.s,fips,by.x='ori',by.y='FIPS')
dwt12.s$ori <- dwt12.s$Name
dwt12.s$Name <- NULL
dwt12.s$ori_res <- 'state'
dwt12.s$des_res <- 'state'
dwt12.s$year <- 2012

# FAF zones
dwt12.f.2 <- clean(dwt12.f.2,'ori','des','sctg2')
dwt12.f.3 <- clean(dwt12.f.3,'ori','des','sctg3')
dwt12.f.4 <- clean(dwt12.f.4,'ori','des','sctg4')
dwt12.f <- merge(merge(dwt12.f.2,dwt12.f.3),dwt12.f.4)
dwt12.f <- merge(dwt12.f,faf,by.x='des',by.y='id')
dwt12.f$des <- dwt12.f$CFSAREANAM
dwt12.f$CFSAREANAM <- NULL
dwt12.f <- merge(dwt12.f,faf,by.x='ori',by.y='id')
dwt12.f$ori <- dwt12.f$CFSAREANAM
dwt12.f$CFSAREANAM <- NULL
dwt12.f$ori_res <- 'faf'
dwt12.f$des_res <- 'faf'
dwt12.f$year <- 2012

# Combine 2002 states and 2012 faf information
dwf <- rbind(dwe02,dwt02,dwe12.s,dwe12.f,dwt12.s,dwt12.f)
dwf <- dwf[,c(6,7,8,1,2,3,4,5)]
dwf$total <- dwf$sctg2 + dwf$sctg3 + dwf$sctg4
print(head(dwf))
write.csv(dwf,'dwf.csv',row.names=F)
