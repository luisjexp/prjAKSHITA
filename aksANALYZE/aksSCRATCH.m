%% SCRATCHs
cd /Users/luis/Box/prjAKSHITA/
addpath /Users/luis/Box/prjAKSHITA/aksDATA/
addpath /Users/luis/Box/prjAKSHITA/aksANALYZE/
addpath /Users/luis/Box/prjAKSHITA/
edit /Users/luis/Box/prjAKSHITA/aksANALYZE/csvimporter.m

clear;
clc
C = csvimporter;


%% ----------------- ANALYZE STATEWIDE RACIAL COVID CASES ----------------- 

clc
tt = C.gentt_STATEWIDE_master();
tt.Properties.VariableNames'


%% -- analyze

clc
% Y_var_name     = 'epiestimR'; 
Y_var_name     = 'death_pctof_racepop';
event_idx           = tt.('aks_npi_onset') == 1;
event_times_list    = tt.('Time')(event_idx) ;
event_description   = tt.('aks_npi_description')(event_idx);  

close all
[dR, var_names] = C.ANZ_effect_of_npi_STA(tt, Y_var_name, event_times_list,...
    event_description = event_description);



%% T TESTS
idx_asn = 1;
idx_blk = 2;
idx_ltn = 3;
idx_mlt = 4;
idx_ntv = 5;
idx_pcf = 6;
idx_wht = 7;

clc
[P,ANOVA_cell,STATS] = anova1(dR, var_names);
h = get(gca, 'YLabel');
set(h, 'String', 'Log Change in Mortality');
ANOVA_tbl = cell2dataset(ANOVA_cell);



[c,~,~,gnames] = multcompare(STATS);
TTEST_tbl = cell2table([gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6))]);
TTEST_tbl.Properties.VariableNames = {'group_i', 'group_j', 'CI_lower', 'dMEANS',  'CI_upper', 'pval'};

TTEST_tbl = [TTEST_tbl,  table(TTEST_tbl.pval<.025, 'VariableNames', {'is_sig'})]



%% Print Figures

figs = findobj(0, 'type', 'figure');
d = round(clock);
d =  sprintf('%d', d(1:3));
for k=1:length(figs)
    % print each figure in figs to a separate .eps file 
    fname = sprintf('/Users/luis/Box/prjAKSHITA/aksCOMM/file%d_%s.svg', k, d);
    print(figs(k), '-dsvg', fname) 
end


%% ----------------- COUNTY ANALYSIS ----------------- 


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








