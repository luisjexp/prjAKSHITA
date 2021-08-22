#!/usr/bin/env python
# coding: utf-8

# # DATA PREPROCESSING AND VISUALIZATION

# In[1]:


# IMPORT STUFF
# scipy
import scipy
print('scipy: %s' % scipy.__version__)
# numpy
import numpy as np
print('numpy: %s' % np.__version__)
# matplotlib
import matplotlib.pyplot as plt
print('matplotlib: %s' % plt)
import time
# pandas
import pandas as pd
print('pandas: %s' % pd.__version__)
# statsmodels
import statsmodels as md
print('statsmodels: %s' % md.__version__)
# scikit-learn
import sklearn as sk
print('sklearn: %s' % sk.__version__)

import os
print(os.path.abspath(os.getcwd()))


# In[2]:


vars2load=["date","state", "death", 'deathProbable']

df = pd.read_csv('DATA_all-states-history.csv',skiprows=0)

print(df.head(5))
# print(df.dtypes)


# In[4]:


stateList = pd.unique(df['state'])
dfState = pd.DataFrame(stateList)

print(stateList)

plt.figure(figsize=(15,4))
for stateUs in stateList:
    dfState = df[df['state'] == stateUs] 
    t = dfState['date'];
    #t = np.linspace(1, 100, num=len(x));
    x = dfState['death'];
    plt.scatter(t, x)    
    plt.show


# In[ ]:




