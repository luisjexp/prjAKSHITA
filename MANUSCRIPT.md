# To Do and Ideas

Analysis

- Write python code for akshita
- Anova Code in Python
- Akshita assignment: 
   - fix plots using power point or illustrator
   - finish writing methods and results
   - Begin outlining and writing conclusion/discussion
   - prepare formating for publication 

# Introduction

The problem

> "Comparing the trajectory of the COVID-19 epidemic in the United States to that of other countries can provide important insights into how the virus is progressing in the United States and the effectiveness of our response"
>
> Elvery 2020

Hypothesis...

Figure of NPI policies



# Methods 

## Raw Daily Mortality Counts

We use a publically available dataset provided by California's Covid19 Recourse Website (https://covid19.ca.gov/state-dashboard/). From the data set we used the 

-  Daily number of covid-related mortalities begining on **April 2020** and ending on **July 2021**
-  We obtain daily mortality counts obtained for **7** different ethnic groups: Asian, African American, Latino, multi-ethnic, Native-American, Pacific-Islander and White.

## Daily Death Rates

Motivation

- An ethnic groups **daily number of mortalities** depends on the size of the groups population, and is therefore an inappropriate measure to use.  

Solution

- To resolve this issue we divide the mortality on the *i_th* day by the group's population size in California. We refer to this outcome variable as the *death rate*....

$$
m_{d_i} = NumberOfMortalities/EthnicPopulation
$$

- Ethnic group's population size in the California was taken from 2019 census counts conducted by the [United States Census Bureau](https://data.census.gov). 

-  Death rates are then smoothed using a moving average of 7 days.

[Figure X](this) shows each ethnicity's daily death rates from April 2020 - July 2021. 



## NPI

We also aquired the dates that non-pharemcutical interventions (NPIs) were implemented by the state of California. Specifically, we define **NPIs** as government policies that impose restictions on social and economic activity accross the state.

In the analysis, we assess the impact of **7** NPIs on death rates occuring between April 2020 and July 2021. An example NPI was implemented on **DATE** where the state of california imposed a mask mandate reqiuring, by law, all of its residents to wear a mask when outdoors.

Data on NPIs were manually collected from a report written by Richard Procter. The [website to the report can be found here](https://calmatters.org/health/coronavirus/2021/03/timeline-california-pandemic-year-key-points/), and a PDF of the most current report used in this analysis can be [found here](aksPAPERS/2021Procter_Timeline_ NPIs.pdf)



The vertical lines in **Figure ()** show the dates a short description of the NPIs that were used in this analysis. 

<img src="aksCOMM/file0_202197.png" alt="image-20210829205106500" style="zoom:50%;" />

## Analysis 

To determine the effect of non-pharemcutical interventions (NPIs) on the **daily** **death rates** of an ethinic group, we compute the **mean change mortality rate** following the onset of an NPI.  Specifically, after the onset date of an NPI we compute the change in mortality rate for each day following the NPI for up to 15 days. We then take the average of the changes in mortality rates accross the 15 days and accross all NPIs. This average change in mortality was computed seperately for each ethnic population. 


$$
{\Delta}\bar{M}{_{ethnicity}} =  \dfrac{1}N\sum_{n=1}^{N}{  {\Delta}{m_{n}} }
$$

$$
where, {\Delta}{m_n} = \dfrac{1}D\sum_{i=1}^{D}(m_{d_0} - m_{d_i})
$$

# Results

The results of the analysis are summarized in figure [X]. 

## ANOVA

We begin by testing the hypothesis that the **mean change in mortality** following an NPI is similar for all ethnic groups. Using a one way ANOVA, we reject this hypothesis  [ F(6,105) = 17.40, p = 0.00].



<img src="aksCOMM/file1_202197.svg" alt="image-20210829205106500" style="zoom:25%;" />

<img src="aksCOMM/file2_202197.svg" alt="image-20210829205106500" style="zoom:25%;" />

<img src="aksCOMM/file3_202197.svg" alt="image-20210829205106500" style="zoom:50%;" />



## T-Tests

Second we ask if minority ethnic groups and Whites are impacted by NPIs to the same degree. 

As shown in **FIGURE X**

- we find a significant difference in the **mean change in mortality** of whites versus latinos after NPIs (t = x.xx, p = x.xx). 
- Similarly, we find that, following an NPI, the **DV** of whites is smaller than the following ETHNIC GROUPS, whites and ETHNIC group and whites  

<img src="aksCOMM/NEED FIGURES HERE" alt="image-20210829205106500" style="zoom:50%;" />

<img src="aksCOMM/NEED FIGURES HERE" alt="image-20210829205106500" style="zoom:50%;" />

<img src="aksCOMM/NEED FIGURES HERE" alt="image-20210829205106500" style="zoom:50%;" />

<img src="aksCOMM/NEED FIGURES HERE" alt="image-20210829205106500" style="zoom:50%;" />



# Discussion

Limitations

- no baseline measurment

- only 1-2 npis are being assessed. this may not be enough data.

  











