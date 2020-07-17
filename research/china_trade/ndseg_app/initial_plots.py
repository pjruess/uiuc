import pandas

unc = pandas.read_csv('comtrade_usa_to_china_allyears.csv',usecols=['Exporter','Importer','Resource','Year','Value_1000USD','Weight_1000kg'])

faf = pandas.read_csv('faf4_usa_states_to_china_allyears.csv')

print unc.head()
print faf.head()

print unc['Resource'].unique()
print faf['SCTG2'].unique()
