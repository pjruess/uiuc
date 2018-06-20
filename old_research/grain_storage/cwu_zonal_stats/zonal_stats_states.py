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
		stats='mean',
		# copy_properties=True
		# categorical=True
		geojson_out=True
		)#,stats='count min mean max median')

        # print stats[0]['properties']

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
	polygon = '../cb_2016_us_state_500k/cb_2016_us_state_500k.shp'
	headers = ['STATEFP','NAME','ALAND','mean']
	# raster_names = [f for f in os.listdir('raw_tiffs/') if f.endswith('.tif')]
        # Override raster_names to only include names relevant to grain_storage research
        import pandas
        u2w = pandas.read_csv('../usda_to_wfn.csv')
        raster_names = []
        for i in ['bl','gn_ir','gn_rf']:
            raster_names = raster_names + ['cwu{0}_{1}.tif'.format(x,i) for x in u2w['wfn_code'].values] #'cwu103_bl','cwu71_bl','cwu15_bl','cwu75_bl','cwu83_bl','cwu44_bl','cwu27_bl','cwu97_bl','cwu79_bl','cwu89_bl']
        print raster_names
	for r in raster_names:
		filename = 'state_outputs/{0}.csv'.format(r.split('.')[0])
                print filename
		raster = 'raw_tiffs/{0}'.format(r)
		zonal_stats_csv(
			polygon=polygon,
			raster=raster,
			headers=headers,
			filename=filename)
