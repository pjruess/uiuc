# Calculate average Virtual Water Content of commodities for each US county
# based on VWC grid-cells within that US county

# Import libraries
import arcpy
from arcpy import env
from arcpy.sa import *
import os
import shutil

# Check out ArcGIS Spatial Analysis extension license
arcpy.CheckOutExtension('Spatial')

# Set environment
env.workspace = 'U:/grain_storage/'

# Set zone feature class
inZoneData = 'U:/grain_storage/data/cb_2016_us_county_500k/cb_2016_us_county_500k.shp'

# Set zone field
zoneField = 'GEOID'

# Set no data value
noDataOption = 'DATA' #DATAOPT: 'NODATA' or 'DATA'

# Set Statistics Type: MEAN, SUM, MAX, MIN, ... or ALL
zonalSummaryType = 'MEAN'

# Collect all unique raster names
raster_list = []
for file in os.listdir('U:/grain_storage/data/vwc_tiffs/'):
    if file.endswith('.tif'):
        raster_list.append(os.path.splitext(file)[0]) 

# List of grain-related rasters to prioritize
# raster_list = ['cwu15_bl','cwu15_gn_ir','cwu15_gn_rf',
#                'cwu27_bl','cwu27_gn_ir','cwu27_gn_rf',
#                'cwu44_bl','cwu44_gn_ir','cwu44_gn_rf',
#                'cwu56_bl','cwu56_gn_ir','cwu56_gn_rf',
#                'cwu71_bl','cwu71_gn_ir','cwu71_gn_rf',
#                'cwu75_bl','cwu75_gn_ir','cwu75_gn_rf',
#                'cwu79_bl','cwu79_gn_ir','cwu79_gn_rf',
#                'cwu83_bl','cwu83_gn_ir','cwu83_gn_rf',
#                'cwu89_bl','cwu89_gn_ir','cwu89_gn_rf',
#                'cwu97_bl','cwu97_gn_ir','cwu97_gn_rf',
#                'cwu103_bl','cwu103_gn_ir','cwu103_gn_rf',
#                'cwu108_bl','cwu108_gn_ir','cwu108_gn_rf']

for raster in raster_list:
    # Set output table path
    outputTable = 'U:/grain_storage/data/results/' + raster + '_' + noDataOption + '.dbf' # DATAOPT

    # Break if this table already exists
    if os.path.isfile(outputTable):
        print 'Output already exists for {0}. Skipping to next iteration.'.format(raster)
        continue
    
    # Set value raster path
    inValueRaster = 'U:/grain_storage/data/vwc_tiffs/' + raster + '.tif'

    # Print statements for reader feedback during script run
    print 'inZoneData: ',inZoneData
    print 'zoneField: ',zoneField
    print 'noDataOption: ', noDataOption
    print 'zonalSummaryType: ',zonalSummaryType
    print 'inValueRaster: ',inValueRaster
    print 'outputTable: ',outputTable
    
    # Execute ZonalStatistics
    outZonalStatistics = ZonalStatisticsAsTable(inZoneData,zoneField,inValueRaster,
                                                outputTable,noDataOption,zonalSummaryType)
    
    # If an error is received, run script over again
    # try: outZonalStatistics = ZonalStatisticsAsTable(inZoneData,zoneField,inValueRaster,
    #                                             outputTable,noDataOption,zonalSummaryType)
    # except:
    #     import sys
    #     os.execv(sys.executable, ['python'] + sys.argv) # restart script when error is received
    
    # Convert output DBF table to CSV file
    arcpy.TableToTable_conversion(outputTable,
        'U:/grain_storage/data/results/',
        raster + '_' + noDataOption + '.csv') # DATAOPT
    print 'CSV output saved to: U:/grain_storage/data/results/' + raster + '_' + noDataOption + '.csv' # DATAOPT

    # Remove processing files that were created during this iteration
    # temp_files = os.listdir('U:/grain_storage/')
    # temp_files = filter(lambda x: x != 'data', temp_files) # remove 'data' folder from list
    # for  f in temp_files:
    #     shutil.rmtree(f)