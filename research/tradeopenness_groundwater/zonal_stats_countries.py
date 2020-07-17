import rasterstats
import geopandas

# import gdal, ogr, osr, numpy
# import sys

# Reference rasterstats: https://github.com/perrygeo/python-rasterstats
# Reference rasterstats: http://www.perrygeo.com/index2.html
# Reference rasterstats: http://www.perrygeo.com/python-rasterstats.html

# Raster to tiff: https://gis.stackexchange.com/questions/54819/gdal-translate-converting-esri-grid-to-geotiff-in-batch
# Read raster with GDAL: https://automating-gis-processes.github.io/2016/Lesson7-read-raster.html
# Read ESRI gdb ideas: https://pcjericks.github.io/py-gdalogr-cookbook/vector_layers.html#get-all-layers-in-an-esri-file-geodatabase
# Zonal statistics in straight-up python: https://pcjericks.github.io/py-gdalogr-cookbook/raster_layers.html

def zonal_stats_csv(polygon,raster,headers,filename,year):
    stats = rasterstats.zonal_stats(
        polygon,
        raster,
        stats='sum',
        geojson_out=True
        )#,stats='count min mean max median')

    # Default encoding to utf-8 for odd string characters
    import sys
    reload(sys)
    sys.setdefaultencoding('utf-8')

    # Write to CSV
    with open(filename,'w') as f:
        f.write(','.join(headers))
        f.write('\n')
        for x in stats: 
    	    p = x['properties']
	    s = [str(p[h]).encode('utf-8') for h in headers]
            s[1] = s[1].replace(',','')
	    f.write(','.join(s))
	    f.write('\n')

if __name__ == '__main__':
    import os
    polygon = 'TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp'
    headers = ['ISO3','NAME','UN','sum']
    for year in range(2000,2011):
        for crop in ['Wheat','Maize','Rice','Barley','Rye','Millet','Sorghum','Soybeans','Sunflower','Potatoes','Cassava','Sugar cane','Sugar beets','Oil palm','Rapeseed','Groundnuts','Pulses','Citrus','Date palm','Grapes','Cotton','Cocoa','Coffee','Others perennial','Managed grassland','Others annual']:
            filename = 'rawdata/gwd_csv/{0}/{1}_gwd_{0}.csv'.format(year,crop)
            print filename
            raster = '../iiasa_yssp/gwd/disagg/{0}/{1}_gwd_{0}.tif'.format(year,crop)
            zonal_stats_csv(
                polygon=polygon,
                raster=raster,
                headers=headers,
                filename=filename,
                year=year)
