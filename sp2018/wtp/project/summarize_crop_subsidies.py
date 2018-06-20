import pandas

total = pandas.read_csv('data/crop_subsidies.csv')

corn_us = pandas.read_csv('data/corn_data_ewg_us.csv')
total = total.merge(corn_us,left_on='year',right_on='corn_us_year',how='outer')
total.drop('corn_us_year',axis=1,inplace=True)

corn_il = pandas.read_csv('data/corn_data_ewg_il.csv')
total = total.merge(corn_il,left_on='year',right_on='corn_il_year',how='outer')
total.drop('corn_il_year',axis=1,inplace=True)

soy_us = pandas.read_csv('data/soy_data_ewg_us.csv')
total = total.merge(soy_us,left_on='year',right_on='soy_us_year',how='outer')
total.drop('soy_us_year',axis=1,inplace=True)

soy_il = pandas.read_csv('data/soy_data_ewg_il.csv')
total = total.merge(soy_il,left_on='year',right_on='soy_il_year',how='outer')
total.drop('soy_il_year',axis=1,inplace=True)

# total.to_csv('data/crop_subsidies_compiled.csv')

total = total[['year','us_mil$','il_mil$','corn_us_total','corn_il_total','soy_us_total','soy_il_total']]

total['others_us_total'] = total['us_mil$'] - total['corn_us_total'] - total['soy_us_total']
total['others_il_total'] = total['il_mil$'] - total['corn_il_total'] - total['soy_il_total']

total.to_csv('data/crop_subsidies_simplified.csv')