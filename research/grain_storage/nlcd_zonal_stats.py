import rasterstats
import geopandas
import gdal

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
	import os
	polygon = 'cb_2016_us_county_500k/cb_2016_us_county_500k.shp'
        raster_path = os.path.join( os.path.expanduser('~'), 'Downloads', 'nlcd_2011_landcover_2011_edition_2014_10_10', 'nlcd_2011_landcover_2011_edition_2014_10_10.img' )
	# headers = ['STATEFP','COUNTYFP','GEOID','NAME','ALAND','mean']
	filename = 'script_outputs/nlcd_2011_rasterstats.csv'
        
        

        raster = gdal.Open(raster_path)
        print type(raster)
        raster_array = raster.ReadAsArray()
        print raster_array
        import numpy
        print numpy.sum(raster_array)

        # 597234572
        # 509321599181

        stats = rasterstats.zonal_stats(polygon,raster_path)#,stats='count')
        print stats

        1/0
	zonal_stats_csv(
		polygon=polygon,
		raster=raster,
		headers=headers,
		filename=feilename)
