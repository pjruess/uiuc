

crops <- c('corngrain','rice','soybeans','wheat')

for (c in crops){

    print(sprintf('Starting %s',c))

    # Read in agricultural data
    df <- read.csv(sprintf('nass/survey_alldata_%s_state_allyears.csv',c))[,c('Year','State.ANSI','Data.Item','Value')]
    
