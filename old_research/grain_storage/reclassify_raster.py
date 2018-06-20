import os
import itertools

# Find location of gdal_calc.py
# https://stackoverflow.com/questions/5776148/how-to-find-a-file-in-ubuntu

# os.system('find / -iname gdal_calc.py 2>/dev/null') # 2>/dev/null withholds error messages

# Reclassify all values to 1 and NoData to 0 using gdal_calc.py
# http://www.gdal.org/gdal_calc.html

# https://gis.stackexchange.com/questions/245170/reclassifying-raster-using-gdal
# Example: python gdal_calc.py -A input.tif --outfile=output.file --calc="10*(A<=12)+20*(A==20)+30*(A==30)+40*(A==40)+50*(A==50)+60*((A>50)*(A<=62))" --NoDataValue=0

# https://gis.stackexchange.com/questions/116473/reclassifying-rasters-using-gdal-and-python
# Example: gdal_calc.py -A C:temp\raster.tif --outfile=result.tiff --calc="0*(A<3)" --calc="1*(A>3)"

crops = ['15','27','44','56','71','75','79','83','89','97','103','108']
watertypes = ['bl','gn_rf','gn_ir']

for c,w in itertools.product(crops,watertypes):
    call = 'python /usr/bin/gdal_calc.py -A cwu_zonal_stats/raw_tiffs/cwu{0}_{1}.tif --outfile=test_rasters/cwu{0}_{1}_reclass.tif --calc="1*(A>0)" --NoDataValue=0'.format(c,w)
    print call
    os.system(call)

