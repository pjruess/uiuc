import pandas
import matplotlib.pyplot as plt

df = pandas.read_csv('all_accuracies_resub.csv')
print df.head()
df.boxplot(column='Accuracy', return_type='axes');
plt.savefig('accuracy_spread.png')