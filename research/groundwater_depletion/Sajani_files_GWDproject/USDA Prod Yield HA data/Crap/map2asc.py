#Convert PCRaster map to ASCII format
#Created by Yoshihide Wada, February 2015

#import modules
#import pcraster as pcr
#import pcraster.framework as pcrm
import os,sys
import glob

#-specify the directory where the input data exist and output data are written
dirInput= 'F:\\Models\\MIRCA2000\\IrrigationWD\\results\\nrgw\\crop_%02d'

#iterate for all files to convert .map file to .asc file
for crop in range(1,27,1):
 for month in range(1,13,1):
  #list all files with .map extension
  listMap = glob.glob(os.path.join(dirInput % crop,'*.0%02d' % (month)))

  for fileName in listMap:
   #-print input fileName
   print fileName
 
   #making output file names with .pcr extenstion (not physically created yet)
   outputFileName= os.path.splitext(fileName)[0] + '%02d' % (month) + '.asc'
   print outputFileName
 
   #use gdal_translate to convert .map file to .pcr file (one by one)
   command = 'map2asc -a  -m -9999 -s " "  %s %s' % \
            (fileName,outputFileName)
   #operate the command
   os.system(command)
