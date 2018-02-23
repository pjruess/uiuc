import os
import itertools

# For each crop
crops = ['{0:02d}'.format(i) for i in range(1,27)]
wtypes = ['rainfed','irrigated']

for crop,watertype in itertools.product(crops,wtypes):
    
    # List of all current MIRCA ascii files
    fgeneric = 'MIRCA2000/monthly_growing_area_grids/crop_{0}_{1}_{2}'

    months = ['{0:03d}'.format(m) for m in range(1,13)]
    # print months
    letters = list(map(chr, range(ord('A'), ord('L')+1))) # only need first 12 letters, for 12 months
    # print letters

    tif_list = []

    # Convert ascii files to tifs
    for letter, month in zip( letters, months ):
        # Convert ascii to tif
        fpath = fgeneric.format( crop, watertype, month)
        asc_to_tif = 'gdal_translate -of "GTiff" {0}.asc {0}.tif'.format(fpath)
        # print asc_to_tif
        # os.system( asc_to_tif )
        tif_list.append( '-{0} {1}.tif'.format( letter, fpath ) )
    
    joined_tifs = ' '.join( tif_list )
    # print joined_tifs
    
    fout = fgeneric.format(crop,watertype,'0')
    fout = '{0}_total'.format( fout.rsplit('_',1)[0] )
    # print fout

    call = 'python /usr/bin/gdal_calc.py {0} --outfile={1}.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L" --NoDataValue=0'.format(joined_tifs, fout) # list of tifs to join (-A path/to/tif.tif); output; 
    print call
    os.system( call )
