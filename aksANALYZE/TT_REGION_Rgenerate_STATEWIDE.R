# STATEWIDE VERSION. EXACT SAME THING AS COUNTY VERSION EXCEPT USE STATEWIDE DATA
rm(list = ls())
library(EpiEstim)
library(readr)
library(tidyverse)
library(data.table)
#####
data_region = 'statewide'
print('ADDING EPISTEM VARIABLE TO STATE WIDE TIME TABLE IN R')
#####
data_path <-"/Users/luis/Box/prjAKSHITA/aksDATA/"
#data_region <- readline(prompt="Enter data region(statewide or santaclara: ")


    if (data_region == "statewide") {
      fname_2import_prefix <- "TT_statewide_noR.csv"
      fname_2export_prefix <- "TT_statewide_yesR.csv"
      incidince_var_name_suffix <- "calgov_case_count_daily"
      } else if (data_region == "santaclara") {
        fname_2import_prefix <- "TT_santaclara_noR.csv"
        fname_2export_prefix <- "TT_santaclara_yesR.csv"
        incidince_var_name_suffix <- "new_cases"
        
      } else if (data_region == "sanfrancisco") {
      }
 
fname_2_import <- paste(data_path, fname_2import_prefix, sep='')
fname_2_export <- paste(data_path, fname_2export_prefix, sep='')
print(fname_2_import)
tt <-read_csv(fname_2_import, col_names = TRUE)


race_tag_list <- list('ltn','pcf','mlt','blk','asn','wht','ntv')
incidince_var_name_list <- paste(race_tag_list, incidince_var_name_suffix, sep="_")  
epiestimR_var_name_list <-paste(race_tag_list, 'epiestimR', sep="_") 

tt_incidince <-tt %>% select(incidince_var_name_list)
tt_incidince[is.na(tt_incidince)] <- NaN

find_first_last_non_nan <- function(x) {
  mn = min(which(complete.cases(x)))
  mx = max(which(complete.cases(x)))
  mn_mx = c(mn,mx)
}

get_R <- function(I) {
  
if (sum(complete.cases(I))>10) {
    mn_mx = find_first_last_non_nan(I)
    mn = mn_mx[1]
    mx = mn_mx[2]
    I_clipped = I[mn:mx]
    num_incidence = NROW(I_clipped)
    
    Mean.SI = 4.46
    Std.SI = 2.23
    method = "parametric_si"
    Mean.Prior = 1.2
    Std.Prior = .2
    t_start = seq(2, num_incidence-1)
    t_end   = t_start + 1
    
    R_info <- estimate_R(I_clipped,
                         method=method,
                         config = make_config(
                           list(t_start = t_start,
                                t_end = t_end,
                                mean_si = Mean.SI,
                                std_si = Std.SI))
    )
    R_clipped <- R_info$R$`Mean(R)`
    R_reset<- c(rep(NA,mn+1),R_clipped,rep(NA,NROW(I)-mx))
} else{R_reset = I}
    
    
    return(R_reset)
}

list_r_wrong_names <- apply(tt_incidince,2,get_R)
tt_r_wrong_names = as.data.frame(list_r_wrong_names)
tt_r_correct_names = set_names(tt_r_wrong_names,epiestimR_var_name_list )

tt_new <- cbind(tt,tt_r_correct_names )

write.csv(tt_new,fname_2_export, row.names = FALSE)
print(fname_2_export)
print('DONE PROCESSING, R ADDED TO *****STATEWIDE**** TIME TABLE')




