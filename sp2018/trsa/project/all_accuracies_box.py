import pandas
import matplotlib.pyplot as plt

df = pandas.read_csv('all_accuracies.csv')
print df.head()
df.boxplot(column=['ResubAccuracy','SepAccuracy'],return_type='axes')
# df['ResubAccuracy'].plot(kind='box')
# df['SepAccuracy'].plot(kind='box')
plt.xticks([1,2],['Resubstited','Separated'])
plt.savefig('accuracy_spread.png')