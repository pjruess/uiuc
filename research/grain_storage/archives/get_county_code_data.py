import pandas
import requests
import csv
import re

url = 'https://www.nass.usda.gov/Data_and_Statistics/County_Data_Files/Frequently_Asked_Questions/county_list.txt'

r = requests.get(url,stream=True)

with open('usda_nass_data/county_codes.csv','w') as f:
    w = csv.writer(f)
    w.writerow(['State','District','County','Name','History_Flag'])
    count = 0
    for line in r.iter_lines():
        if count >= 12: w.writerow(re.split(r'\s{2,}',line))
        count += 1
