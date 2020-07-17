import numpy as np
import math
import pandas as pd
import matplotlib.pyplot as plt
from scipy.sparse import diags
from scipy.linalg import lu_factor, lu_solve
import itertools

## Question 3a
# Numerical parameters
D_script = 1
dx = 0.1
dt = D_script*dx**2 # assume hydraulic diffusivity (D) is 1
grid = np.arange(0+dx, 1, dx)
N = len(grid)
b = np.zeros(N)

tridiag = np.array([-D_script*np.ones(N-1), (1+2*D_script)*np.ones(N), -D_script*np.ones(N-1)])
offset = [-1, 0, 1]
A = diags(tridiag, offset).toarray()

index = np.arange(0, N, 1)
h = np.ones(N)
for x, i in itertools.zip_longest(grid, index): # for loop to udpate blank h
  if x < 0.5:
    h[i] = 2*x
  elif x > 0.4:
    h[i] = 2*(1-x)

print(A)
print(b)
print(h)

LU, P = lu_factor(A)
print(LU)
h_new = lu_solve((LU, P), h+b)

print(h_new)

plt.figure(dpi=200)
plt.plot(grid, h_new, marker='s', markerfacecolor='none', markersize=3, 
                 linestyle='-', color='C0', label='Fully Implicit')
plt.xlabel('x')
plt.ylabel('h')
plt.title('t = 0')
plt.legend(loc="best", facecolor="white", edgecolor="black", framealpha=1)

result = pd.DataFrame(columns=["Time","Position","Head"])
i = 0

for t in (0,.01,.05,.1):
        for x in np.linspace(0,1,11):
                    head = 0
                            for n in range(1,200,2):
                                            head = head + 1/n**2*math.e**(-n**2*math.pi**2*t)*math.sin(.5*n*math.pi)*math.sin(n*math.pi*x)
                                                    head = head*8/math.pi**2
                                                            result.loc[i,["Time","Position","Head"]] = t,x,head
                                                                    i = i + 1

                                                                        plt.plot(result[result["Time"]==t]["Position"], result[result["Time"]==t]["Head"], marker='s', markerfacecolor='none', markersize=3,
                                                                                             linestyle='-', color='C0')
                                                                            plt.show()
