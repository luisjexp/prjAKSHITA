%% SCRATCHs
cd /Users/luis/Box/prjAKSHITA/
addpath /Users/luis/Box/prjAKSHITA/aksDATA/
addpath /Users/luis/Box/prjAKSHITA/aksANALYZE/
edit /Users/luis/Box/prjAKSHITA/aksANALYZE/csvimporter.m

clear;
clc
V = ttviewer;
C = csvimporter;


%% ----------------- ANALYZE LOS ANGELES ----------------- 
%% LOAD TABLE FIRST

clc
tt = C.gentt_LOSANGELES_master();
tt.Properties.VariableNames'

%% ASSESS TIER DECREASE
clc
Y_var_name          = 'death_pctof_racepop'; 
event_idx           = tt.('tier_decrease') == 1;
event_times_list         = tt.('Time')(event_idx) ;

clf
C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = {})

% z = tt{:, ["asn_case_pctof_racepop", "ltn_case_pctof_racepop",...
%     "pcf_case_pctof_racepop", ...
%     "wht_case_pctof_racepop",...
%     "mlt_case_pctof_racepop"]};
% clf
% plot(z)
% figure(gcf)
%% ASSESS TIER INCREASE
clc
Y_var_name          = 'death_pctof_racepop'; 
event_idx           = tt.('tier_increase') == 1;
event_times_list         = tt.('Time')(event_idx) ;

C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = {})
% 
% z = tt{:, ["asn_case_pctof_racepop", "ltn_case_pctof_racepop",...
%     "pcf_case_pctof_racepop", ...
%     "wht_case_pctof_racepop",...
%     "mlt_case_pctof_racepop"]};
% clf
% plot(z)
% figure(gcf)




%% ----------------- ANALYZE SANTA CLARA RACIAL COVID CASES ----------------- 
%% LOAD TABLE FIRST
clc
tt = C.gentt_SANTACLARA_master();
tt.Properties.VariableNames'

%% LETS ASSESS SANTA CLARA
clc
Y_var_name          = 'case_pctof_racepop'; 
event_idx           = tt.('tier_decrease') == 1;
% event_idx = event_idx(1);
event_times_list         = tt.('Time')(event_idx) ;

C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = {})

%% SCRATCH

z = tt{:, ["asn_case_pctof_racepop", "ltn_case_pctof_racepop",...
    "pcf_case_pctof_racepop", ...
    "wht_case_pctof_racepop"]};
clf
plot(z)
figure(gcf)

%% ----------------- ANALYZE SAN FRANCISCO RACIIAL COVID CASES ----------------- 
%% LOAD TABLE FIRST
clc
tt = C.gentt_SANFRANCISCO_master();
tt.Properties.VariableNames'

%% LETS ASSESS SANTA FRAN
clc
Y_var_name          = 'death_pctof_racepop'; 
event_idx           = tt.('tier_decrease') == 1;
% event_idx = event_idx(1);
event_times_list         = tt.('Time')(event_idx) ;

C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = {})

%% SCRATCH

z = tt{:, ["asn_death_pctof_racepop",...
    "ltn_death_pctof_racepop",...
    "blk_death_pctof_racepop", ...
    "pcf_death_pctof_racepop",...
    "wht_death_pctof_racepop"]};

clf
plot(z)
legend({'asn', 'ltn', 'blk', 'pcf', 'wht'}) 

figure(gcf)




%% ----------------- ANALYZE STATEWIDE RACIAL COVID CASES ----------------- 

clc
tt = C.gentt_STATEWIDE_master();
tt.Properties.VariableNames'


% tt = removevars(tt,{'',...
%     'pcf_epiestimR', 'mlt_epiestimR', 'ntv_epiestimR', 'blk_epiestimR'});
% 
% tt = removevars(tt,{'',...
%     'pcf_epiestimR', 'mlt_epiestimR', 'ntv_epiestimR', 'blk_epiestimR'});




%% -- analyze
clc
% Y_var_name     = 'epiestimR'; 
Y_var_name     = 'death_pctof_racepop'
event_idx           = tt.('aks_npi_onset') == 1;
event_times_list    = tt.('Time')(event_idx) ;
event_description   = tt.('aks_npi_description')(event_idx);  


C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = event_description)






