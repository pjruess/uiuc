#Extract values per area of interest
#Last update - March 2016


import os
import pcraster as pcr
import numpy as np
from pcraster import pcr2numpy,numpy2pcr

#-time management
staYear= 2000
endYear= 2001
staMonth= 1
endMonth= 13

#-input maps
country= pcr.readmap('F:\\Dropbox\\Data\\AQURA\\maps\\country.map')
cellArea= pcr.readmap('F:\\Dropbox\\Data\\AQURA\\maps\\cellarea30.map')
countryLocations= pcr.readmap('F:\\Dropbox\\Data\\AQURA\\maps\\country_lat_lon.map')

conv= 1e3
cntTot= int(255)
MV= -9999.


def valueReport(val,valName,outDir):
    #-return global and country values
    #-open text files    
    valNameFile= '%s\\%s.txt' % (outDir,valName)
    if year == staYear and month == staMonth:
        valName= open(valNameFile,'w')
    else:
        valName= open(valNameFile,'a') 
    #-calculate country value (km3/year)
    cntValue= pcr.areatotal(val,country)/conv
    for nrCnt in range(cntTot+1):
        if year == staYear and month == staMonth:
            valName.write('%d ' % (nrCnt))
    for nrCnt in range(cntTot+1):
        cntPoint= pcr.ifthen(countryLocations==int(nrCnt),cntValue)
        cntPoint= pcr.cellvalue(pcr.maptotal(cntPoint),int(1))[0]
        if nrCnt==int(0):
            valName.write('\n%04d %02d ' % (year,month))
        else:
            valName.write('%02f ' % (cntPoint))
    #-calculate global total (km3/year)
    glbValue= pcr.maptotal(val)/conv
    glbPoint= pcr.cellvalue(glbValue,int(1))[0]
    valName.write('%02f' % (glbPoint))
    #-close text files
    valName.close()
    return cntValue,glbValue,valName

for crop in range(1,27):
    for year in range(staYear,endYear):
        for month in range(staMonth,endMonth):
            print crop,year,month
        
            #-variable of interest
            inFile= pcr.readmap('crop_%02d\\ng%02d2000.0%02d' % (crop,crop,month))

            #-report statistics
            outFile= valueReport(inFile,'crop%02d' % (crop),'stats')
