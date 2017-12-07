# import gdal, ogr, osr, numpy
# import sys

# Reference rasterstats: https://github.com/perrygeo/python-rasterstats
# Reference rasterstats: http://www.perrygeo.com/index2.html
# Reference rasterstats: http://www.perrygeo.com/python-rasterstats.html

# Raster to tiff: https://gis.stackexchange.com/questions/54819/gdal-translate-converting-esri-grid-to-geotiff-in-batch
# Read raster with GDAL: https://automating-gis-processes.github.io/2016/Lesson7-read-raster.html
# Read ESRI gdb ideas: https://pcjericks.github.io/py-gdalogr-cookbook/vector_layers.html#get-all-layers-in-an-esri-file-geodatabase
# Zonal statistics in straight-up python: https://pcjericks.github.io/py-gdalogr-cookbook/raster_layers.html

def zonal_stats_csv(polygon,raster,headers,filename):
    print 'Calculating zonal statistics for...'
    print 'Polygon: {0}'.format(polygon)
    print 'Raster: {0}'.format(raster)
    print 'Headers: {0}'.format(headers)
    print 'Filename: {0}'.format(filename)

    import rasterstats
    import geopandas

    stats = rasterstats.zonal_stats(
    	polygon,
    	raster,
    	stats='mean',
    	# copy_properties=True
    	# categorical=True
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
            f.write(','.join(s))
            f.write('\n')

if __name__ == '__main__':
    # Polygon path
    polygon = '../../../research/grain_storage/cb_2016_us_county_500k/cb_2016_us_county_500k.shp'
    
    # Convert raster from ascii to tif
    # asc = 'data/PRISM_ppt_stable_4kmM3_2012_all_asc/PRISM_ppt_stable_4kmM3_2012_asc.asc'
    # asc_to_tif = 'gdal_translate -of "GTiff" {0}.asc prism_precipitation_2012.tif'.format(asc.split('.')[0])
    # print asc_to_tif
    # import os
    # os.sys(asc_to_tif)
    raster = 'data/prism_elevation_1981-2010.tif'  # ascii raster path
    
    # Extra information
    headers = ['STATEFP','COUNTYFP','GEOID','NAME','ALAND','mean']
    filename = 'data/prism_elevation_1981-2010.csv'
    
    # Collect zonal statistics
    zonal_stats_csv(
    	polygon=polygon,
    	raster=raster,
    	headers=headers,
    	filename=filename)
