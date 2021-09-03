# To Do and Ideas

Analysis

- analyze tier de-restriction 
- Write python code for akshita



# Statewide analysis

## Introduction

The problem

Hypothesis...

Figure of NPI policies

<img src="/Users/luis/Library/Application Support/typora-user-images/image-20210829205005017.png" alt="image-20210829205005017" style="zoom:25%;" />

## Data 

<u>Covid death data and race data</u> 

We use publically available datasets published by the california government departmet of health [**REFERENCE**]. The data set contains

-  daily counts of **DV_RAW** for  accross time begining on **START DATE** and ending on **END DATE**
-  The DV is measured for four ethnic groups: White, African American, Latino and Asian.
-  For each ethnic group, we convert the **DV_RAW** to a percentage, **DV**, by dividing **DV_raw** with the etihnic group's total population size within that county. 
   - an ethnic group's population size was aquired from [**reference** for county 1 2 3] 
-  The ethnic groups **DV** was then smoothed using a moving average of 7 days.

<u>NPIs and county Tier status...</u>

- We use a publicly available dataset that tracks non-pharemcutical interventions (NPI's) in each of California county accross time  [**reference**]. 

- Specifically, an NPI is defined as as a change in the county's *tier status*. 

  - When the tier of county changes,  restictions are imposed on social and economic activity accross the county 

  - For example give example of policy restrictions at each tier (see  [tier_status_details.pdf](aksPAPERS/tier_status_details.pdf) )

- Counties varied in the number of tier changes they underwent.  



## Analysis (what we do)

For each racial group, we assess the efficacy of a NPI on **DV** of that racial group.  

We define the onset of an NPI policy as the day in which NPI was declared, thereby imposing restrictions on social and economic activity from that day and forward.

We assess the **DV** following the onset of an NPI, from one to 29 days after, averaging accross all days, and NPIs.

This analysis was performed for each county individually, and in a seperate analysis,  accross all counties. 



## Results (what we find)

The results are summarized in figure [X].



However, following the onset of the NPI **DV** of  Latinos and Asians   was larger  than **DV** of Whites (F = xx.xx, p = x.xx)



<img src="aksASSETS/draft_figure_anova.png" alt="image-20210829205106500" style="zoom:25%;" />



## Discussion

Limitations

- no baseline measurment

- only 1-2 npis are being assessed. this may not be enough data.

  





## <u>CODE</u>

### Data

#### Types of data files

##### raw data files

general format

Types

- cal gov data files
- git county tier data file
- global npi data file
- santa clara data files
- san francisco data files


- chicago
  - case data (https://data.cityofchicago.org/Health-Human-Services/Daily-COVID-19-Cases-by-Race-Ethnicity/4jg2-s2f8)



##### Time table files

time table files, no transmissability variable

- format
- description: these are fully (nearly) processed data files. there is one variable that they are missing, and thats the transmissablity (R) variable 

time table files, with transmissability variabl

- format
- description



Data file name formats
the names of the data files have a specific format


For raw csv files.

- suffix 
  dtaCSV_00format_dtaCSV_LEVEL_V1_vs_V2_datesource







