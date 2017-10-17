# Converts ESRI GRID rasters to TIFF rasters

# Import libraries
import arcpy
import os

# Generate data paths
cwu_data = 'U:/grain_storage/data/CropWaterUse_USvalues/'

# Collect names for different Crop Water Use (CWU) types based on directory with ESRI GRIDS
cwu_types = [f for f in os.listdir(cwu_data) if os.path.isdir(os.path.join(cwu_data+f))]
# Iterate over all files and subdirectories in path to collect commodity identifiers
for cwu_type in cwu_types:
    cwu_path = cwu_data + cwu_type
    commodities = []
    for (dirpath,dirnames,filenames) in os.walk(cwu_path):
        commodities.extend(dirnames) # add all directory names (commodity names) to commodities list
    commodities = filter(lambda x: x != 'info', commodities) # remove occurrences of 'info' in commodities list

    # Iterate over commodities
    for c in commodities:
        # Convert ESRI GRID files to TIFF files for all commodities
        inValueRaster_GRID = cwu_data + cwu_type + '/' + c
        pathValueRaster = 'U:/grain_storage/data/vwc_tiffs/' + c + '.tif'
        if os.path.isfile(pathValueRaster): # if TIFF file already exists, grab the file
            pass
        else: # if TIFF does not exist, create it
            arcpy.RasterToOtherFormat_conversion(inValueRaster_GRID,'U:/grain_storage/data/vwc_tiffs/','TIFF')
