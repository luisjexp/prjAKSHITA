#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 09:16:38 2021

@author: luis
"""
# reset
# %% GET LIBRARIES
# export PYTHONPATH="/path/to/caiman:$PYTHONPATH"
import pandas as pd
from sodapy import Socrata
import os
import glob
import ast
import numpy as np
import matplotlib.pyplot as plt
from  convert2timetable import * 
from view_timeseries import * 
from dtaApiUpdate import *
# %pip install sodapy


# %% UPDATE API DATA
updateAPI()

# %% CONVERT CSV TO TIME TABLE
tf_cal_tier_v_county    = csv_to_tt('dtaCSV_CAL_tier_vs_time.csv', 'date', 1)
tf_cal_tier_v_county = tf_cal_tier_v_county[[ 'county', 'tier']]
tf_stclara_tier  = tf_cal_tier_v_county[tf_cal_tier_v_county['county'] == 'Santa Clara']
print(tf_stclara_tier)


tf_stclara_case_v_race  = csv_to_tt('dtaCSV_stclara_case_vs_race.csv', 'start_date', 1)
tf_stclara_case_v_race = tf_stclara_case_v_race[[ 'new_cases', 'race_ethnicity']]
newcases = tf_stclara_case_v_race['new_cases']
newcases_pct_change = newcases.pct_change()
tf_stclara_case_v_race['new_cases_pct_change'] = newcases_pct_change
print(tf_stclara_case_v_race)


# %% JOINT TABLES
df_merged  = pd.merge_ordered(tf_stclara_case_v_race, tf_stclara_tier, on = 'time', how="outer")
tf =  df_to_tt(df_merged, 'time', 0)

print(tf)
print(df.describe(include = 'all'))




# %% Exract Race data
tf_white = tf[tf['race_ethnicity'] == 'White' ]
tf_asian = tf[tf['race_ethnicity'] == 'Asian' ]
tf_paisa = tf[tf['race_ethnicity'] == 'Hispanic/Latino' ]
tf_black = tf[tf['race_ethnicity'] == 'African American' ]

# print(df)

# %% PLOT NUM CASES
ax = plt.subplot(1,1,1)
# time_vs_XY(df_white, 'new_cases', 'tier', ax, ax)


tf.plot( kind = 'line', style = '-o',
        y = 'tier', color = 'Blue',
        linewidth = 3,
        figsize=(15, 5), ax=ax)

# plt.vlines(x, ymin, ymax, colors=None, linestyles='solid', label='', *, data=None,
                         
                         
tf_paisa.plot(kind = 'line',  style = '-',
        y = 'new_cases', secondary_y = True,
        color = 'green',  linewidth = 10, alpha=0.9,
        ax = ax)  

tf_asian.plot(kind = 'line',  style = '-',
        y = 'new_cases', secondary_y = True,
        color = 'orange',  linewidth = 10, alpha=0.7,
        ax = ax)    

tf_white.plot(kind = 'line',  style = '-',
        y = 'new_cases', secondary_y = True, 
        color = 'Red',  linewidth = 10, alpha=0.6, 
        ax = ax)

tf_black.plot(kind = 'line',  style = '-',
        y = 'new_cases', secondary_y = True,
        color = 'black',  linewidth = 10, alpha=0.5, 
        ax = ax)  


# %% PLOT PERCENT CHANGE

ax1 = plt.subplot(1,1,1)

dv = 'new_cases_pct_change'

tf.plot( kind = 'line', style = '-o',
        y = 'tier', color = 'Blue',
        linewidth = 3,
        figsize=(15, 5), ax=ax1)


tf_paisa.plot(kind = 'line',  style = '-',
        y = dv, secondary_y = True,
        color = 'green',  linewidth = 10, alpha=0.9,
        ax = ax1)  

tf_asian.plot(kind = 'line',  style = '-',
        y = dv, secondary_y = True,
        color = 'orange',  linewidth = 10, alpha=0.7,
        ax = ax1)    

tf_white.plot(kind = 'line',  style = '-',
        y = dv, secondary_y = True, 
        color = 'Red',  linewidth = 10, alpha=0.6, 
        ax = ax1)

tf_black.plot(kind = 'line',  style = '-',
        y = dv, secondary_y = True,
        color = 'black',  linewidth = 10, alpha=0.5, 
        ax = ax1)  
    
