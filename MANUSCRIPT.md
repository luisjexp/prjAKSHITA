# To Do and Ideas

Analysis

- Write python code for akshita
- Anova Code in Python
- Akshita assignment: 
   - fix plots using power point or illustrator
   - finish writing methods and results
   - Begin outlining and writing conclusion/discussion
   - prepare formating for publication 

# Statewide analysis

## Introduction

The problem

Hypothesis...

Figure of NPI policies

<img src="/Users/luis/Library/Application Support/typora-user-images/image-20210829205005017.png" alt="image-20210829205005017" style="zoom:25%;" />

## Data 

<u>Covid death data and race data</u> 

We use publically available datasets published by the california government departmet of health [**REFERENCE**]. The data set contains

-  daily counts of **DV_RAW** accross time begining on **START DATE** and ending on **END DATE**
-  The DV is measured for four ethnic groups: White, African American, Latino and Asian.
-  For each ethnic group, we convert the **DV_RAW** to a percentage by dividing **DV_raw** with the etihnic group's total population size in California . We refer to this outcome variable as **DV**.
   - an ethnic group's population size was aquired from [**reference** for county 1 2 3]. These population estimates are estimates from the census counts in 2019. 
-  **DV** was then smoothed using a moving average of 7 days.

<u>NPIs</u>

- We are interested in the effect of  non-pharemcutical interventions NPIs on the DV. We define NPIs as government policies that imposed restictions on social and economic activity accross the state of California. 
- We manually collected N different NPIs, occuring between **start date** to **end date**  [**reference**]. These NPIs were manually collected from the following website (**reference**).
   - For example, on DATE, the state of california implemented a mask mandate, which required, by law all of its residents to wear a mask when out doors.
   - When the tier of county changes,  

   - For example give example of policy restrictions at each tier (see  [tier_status_details.pdf](aksPAPERS/tier_status_details.pdf) )
- Counties varied in the number of tier changes they underwent.  

## Analysis (what we do)

We asses assess the **DV** following the onset of an NPI, from one to 10 days after its implementation. We average the values of the DV  accross all days and NPIs.

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









