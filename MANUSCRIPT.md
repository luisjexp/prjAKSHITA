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

We use a publically available dataset provided by the California Departmet of Health [**REFERENCE**]. The data set contains

-  daily counts of **DV_RAW** accross time begining on **START DATE** and ending on **END DATE**
-  Data is obtained for N different ethnic groups: White, African American, Latino and Asian.
-  For the analysis, **DV_RAW** is converted to a percentage by dividing **DV_raw** with the etihnic group's total population size in California. We refer to this outcome variable as **DV**.
   - an ethnic group's population size was aquired from [**reference** for county 1 2 3]. These population counts are estimates from the census counts in 2019. 
-  **DV** is smoothed using a moving average of 7 days.

Figure () shows the **DV** accross N days, for each ethnic group considered in this analysis. 

<u>NPIs</u>

- We are interested in the effect of non-pharemcutical interventions (NPIs) on the DV of each ethinic group. We define NPIs as government policies that impose restictions on social and economic activity accross the state of California. 
- In the analysis, we include N NPIs occuring between **start date** to **end date**  [**reference**]. These NPIs were manually collected from **this reference**.
   - An example NPI was implemebted on **DATE**, where the state of california imposed a mask mandate reqiuring, by law, all of its residents to wear a mask when out doors.

The vertical lines in **Figure ()** reveal the dates a short description of the NPIs used in this report. 



## Analysis 

To determine the effect of non-pharemcutical interventions (NPIs) on the **DV** of each ethinic group, we ask how much **DV changed** following the onset of an NPI.  Specifically, after each NPI, we compute change in the **DV** for D days following the NPI. We then take the average of the change in the DV accross the D days and accross all NPIs. We refer to this final value as **dY**.


$$
{\Delta}{Y_n} = \dfrac{1}D\sum_{i=1}^{D}(Y_{d_0} - Y_{d_i})
$$

$$
{\Delta}\bar{Y} =  \dfrac{1}N\sum_{n=1}^{N}{  {\Delta}{Y_n} }
$$



## Results (what we find)

The results are summarized in figure [X]. 

- We begin by assuming the **average change in DV** following an NPI is similar for all ethnic groups. Using a one way anova test,  we  reject this hypothesis  (F = xx.xx, p = x.xx). 
- Second we ask if minority ethnic groups (Latinos, native Americans) are impacted by NPIs in the same manner as Whites. As shown in **FIGURE X**
   - we find a significant difference in the **DV**  for whites versus latinos (t = x.xx, p = x.xx). 
   - Similarly, we find that, following an NPI, the **DV** of whites is smaller than the following ETHNIC GROUPS, whites and ETHNIC group and whites  



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









