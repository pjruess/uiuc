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

def zonal_stats_csv(polygon,raster,headers,filename):
	stats = rasterstats.zonal_stats(
		polygon,
		raster,
		#stats='mean',
                stats=('sum','mean','count'),
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
	import pandas
	import itertools
	h = ['STATEFP','COUNTYFP','GEOID','NAME','ALAND','sum','mean','count']
	years = ['2002','2007','2012']
	polygons = ['county','state']
	for year, poly in list(itertools.product(years,polygons)):
		p = 'cb_2016_us_{0}_500k/cb_2016_us_{0}_500k.shp'.format(poly)
		r = 'precipitation_data/PRISM_ppt_stable_4kmM3_{0}_all_asc/PRISM_ppt_stable_4kmM3_{0}_asc.asc'.format(year)
		f = 'raw_data/{0}_{1}_precip.csv'.format(year,poly)
		h = []
		if poly == 'county': h = ['STATEFP','COUNTYFP','GEOID','NAME','ALAND','sum','mean','count']
		elif poly == 'state': h = ['STATEFP','NAME','ALAND','sum','mean','count']
		zonal_stats_csv(
			polygon=p,
			raster=r,
			headers=h,
			filename=f)
