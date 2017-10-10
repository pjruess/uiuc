import pandas

# Read in data
flows = pandas.read_csv('food_aid_flows_2005.csv')
vwc = pandas.read_csv('commodity_vwc.csv')
# vwc = vwc.rename(columns={'DR Congo': 'Demogratic Republic of the Congo (DRC)'})
# flows['Donor'][flows['Donor'] == 'Demogratic Republic of the Congo (DRC)'].value = 'DR Congo'

headers = list(vwc.columns[:5].values) + list(flows['Donor'].unique())
print vwc[headers]
# KeyError: "['Andorra' 'Democratic Republic of the Congo (DRC)' 
# 'European Community'\n 'Faeroe Islands' 'Lybian Arab Jamahiriya' 
# 'Netherlands, the' 'NGOs'\n 'OTHER' 'PRIVATE' 'Republic of Korea, the'
# 'Syrian Arab Republic, the'\n 'Taiwan, Province of China'
# 'United Arab Emirates, the' 'United Kingdom'\n 'UNITED NATIONS'
# 'United States of America'] not in index"




# Determine virtual water content of all flows



# print flows.groupby(['Donor','Recipient'])