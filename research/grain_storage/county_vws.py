import pandas

harvest = pandas.read_csv('county_storage_vwc.csv')

# Read in USDA yield data
# ***NEED THIS NEXT***

# Calculate VWS in cubic meters
harvest['VWS_m3'] = harvest['Grain_Storage_Capacity_Bushels'] * (258.999/1) * harvest['VWC_m3ha']# 258.999 ha / 1 sqmi

harvest.to_csv('county_vws.csv',index=False)