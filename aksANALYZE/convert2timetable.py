#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 09:51:45 2021

@author: luis
"""
import pandas as pd


def csv_to_tt(file_name_csv, var_name_time, viewResultingTf):
    df_raw = pd.read_csv(file_name_csv)

    print('NOW PROCESSING::: '+ file_name_csv)
    var_names_list = df_raw.columns

    ####### LOOK FOR TIME VARIABLE
    df_dateVarNames = [var_names_list for var_names_list in var_names_list if var_name_time in var_names_list]
    if not bool(df_dateVarNames):
        print("\t Did not find so called ''%s'' variable in data frame" % (var_name_time))
    else:
        print("\t '%s' variable succesfully found in data frame" % (var_name_time))

    df_raw.rename(columns = {var_name_time: "time"}, inplace=True)
    ####### CONVERT DATA FRAME TO TIME SERIES
    df_raw['time'] = pd.to_datetime(df_raw['time'])
    df_raw.set_index('time', inplace = True)
    tf = df_raw;

#     df_raw.drop(['time'], axis=1, inplace=True)
    print("\t Data frame converted to time series???")

#     print('\t\t from object eg: ', df_raw[var_name_time][0])
#     print('\t\t to to date  eg: ', tf[var_name_time][0])

    # SORT TIME SERIES BY TIME VARIABLE
    tf = tf.sort_values(by='time')
    print('\t Time series Sorted by time...')

    if viewResultingTf:
        print(tf)
#         print(tf.describe())


    print('\t DONE PROCESSING \n\n\n')
    return tf


def df_to_tt(df_raw, var_name_time, viewResultingTf):

    print('NOW PROCESSING::: ')
    var_names_list = df_raw.columns

    ####### LOOK FOR TIME VARIABLE
    df_dateVarNames = [var_names_list for var_names_list in var_names_list if var_name_time in var_names_list]
    if not bool(df_dateVarNames):
        print("\t Did not find so called ''%s'' variable in data frame" % (var_name_time))
    else:
        print("\t '%s' variable succesfully found in data frame" % (var_name_time))

    df_raw.rename(columns = {var_name_time: "time"}, inplace=True)
    
    ####### CONVERT DATA FRAME TO TIME SERIES
    df_raw['time'] = pd.to_datetime(df_raw['time'])
    df_raw.set_index('time', inplace = True)
    tf = df_raw;

    print("\t Data frame converted to time series???")

    # SORT TIME SERIES BY TIME VARIABLE
    tf = tf.sort_values(by='time')
    print('\t Time series Sorted by time...')

    if viewResultingTf:
        print(tf)


    print('\t DONE PROCESSING \n\n\n')
    return tf