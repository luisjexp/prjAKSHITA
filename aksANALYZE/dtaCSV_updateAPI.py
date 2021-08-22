#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 15:51:26 2021

@author: luis
"""
import pandas as pd
from sodapy import Socrata
import os
import json
import requests

import urllib.request
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

def updateAPI():

# %% UPDATE SANTA CLARA COUNTY API DATA SETS
    client_StCl = Socrata("data.sccgov.org", None)
    data_id_StCl = "k7e9-hszp"
    results_stclara = client_StCl.get(data_id_StCl)
    
    dfSantaClara = pd.DataFrame.from_records(results_stclara)
    fileName_SantaClara = os.getcwd() + '/' + 'dtaCSV_county_santaclara_case.csv'
    dfSantaClara.to_csv(fileName_SantaClara)
    
    print('updated data set:\n\t' + fileName_SantaClara)
    
    
# %% UPDATE SAN FRANCISCO API DATA SETS   
    client_Sanfran = Socrata("data.sfgov.org", None)
    data_id_sanfran = "vqqm-nsqg"
    results_sanfran = client_Sanfran.get(data_id_sanfran)
    df_sanfran = pd.DataFrame.from_records(results_sanfran)
    fileName_sanfran = os.getcwd() + '/' + 'dtaCSV_sanfran_case_vs_race.csv'
    df_sanfran.to_csv(fileName_sanfran)
    
    print('updated data set:\n\t' + fileName_sanfran)
    
# %% UPDATE CALIFIRNIA RACE DEATH AND CASE DATA (FROM GIT DATE SET)   
    urlCSV_cal_git = 'https://raw.githubusercontent.com/datadesk/california-coronavirus-data/master/cdph-race-ethnicity.csv'
    df_cal_git = pd.read_csv(urlCSV_cal_git)
    filename_cal_git = os.getcwd() + '/' + 'dtaCSV_statewide_case_vs_race_git.csv'
    df_cal_git.to_csv(filename_cal_git)   
    
    print('updated data set:\n\t' + filename_cal_git)

    

# %% UPDATE COUNTY TIER STATUS (FROM GIT DATA SET)   
    urlCSV_cal_county_git = 'https://raw.githubusercontent.com/datadesk/california-coronavirus-data/master/cdph-reopening-tiers.csv'
    df_cal_county_git = pd.read_csv(urlCSV_cal_county_git)
    filename_cal_county_git = os.getcwd() + '/' + 'dtaCSV_git_county_tier.csv'
    df_cal_county_git.to_csv(filename_cal_county_git)   
    
    print('updated data set:\n\t' + filename_cal_county_git)



# %% CAL RACE AND CASE DATA (FROM CAL DATA.COM )
    ### FOLLOWING CODE RETURNS WRONG DATA FILE?? WHY?? JUST DOWNLOAD FOR NOW
    ### urlCSV_cal_wwwcaldta = 'https://data.ca.gov/datastore/odata3.0/67c82c61-370a-4b4c-9067-15a68400b9ff'
    ### df_cal_wwwcaldta = pd.read_csv(urlCSV_cal_wwwcaldta)
    ### filename_cal_wwwcaldta = os.getcwd() + '/' + 'dtaCSV_statewide_case_vs_race_wwwcaldta.csv'
    ### df_cal_wwwcaldta.to_csv(filename_cal_wwwcaldta) 

     print('updated data set:\n\t' + filename_cal_wwwcaldta)
   
    
# %% CALIFORNIA 'NPI' DATA (is world wide data)
    # measurelist_url = 'https://raw.githubusercontent.com/amel-github/CCCSL-Codes/master/COVID19_non-pharmaceutical-interventions_version2_utf8_static_2020-07-12.csv'
    # df_sanfran = pd.read_csv(measurelist_url, sep=",")
    # fileName_sanfran = os.getcwd() + '/' + 'a file name.csv'
    
    

