%% SCRATCHs
cd /Users/luis/Box/prjAKSHITA/
addpath /Users/luis/Box/prjAKSHITA/aksDATA/
addpath /Users/luis/Box/prjAKSHITA/aksANALYZE/
edit /Users/luis/Box/prjAKSHITA/aksANALYZE/csvimporter.m

%% LOAD THIS FIRST
clear;
clc
V = ttviewer;
C = csvimporter;

%%
C.gentt_statewide_covidcase_for_allraces()
tt = C. gentt_STATEWIDE_master()

%% Get final processed time table, with all variables 
%  GET CALIFORNIA DATA TABLE
% then to R studio and add R to the time table
ttcal = C.epistem_read_add_TT_from_R('statewide'); % then load the updated time table

% GET SANTA CLARA DATA TABLE
ttsc = C.epistem_read_add_TT_from_R('santaclara'); % then load the updated time table
ttsc.npi_all = [ttsc.tier_decrease | ttsc.haug_npi_any_onset == 1]; % lets add one more variable


%% LETS ASSESS SANTA CLARA FIRST
clc
clf

ttsc_Y_var_name          = 'new_cases'; 

ttsc_npi_identifier     = 'npi_all';
ttsc_npi_identifier     = 'tier_decrease';
ttsc_npi_identifier     = 'haug_npi_any_onset';


switch ttsc_npi_identifier
    case 'haug_npi_any_onset'
        event_idx = ttsc.(ttsc_npi_identifier) == 1 ;
        event_times             = ttsc.Time(event_idx);
%         event_times           = event_times(15:end);  % events 1:15 have no coinsiding recorded cases
        event_description       = ttsc{event_idx, 'haug_npi_type'}  ;
        
    case 'tier_decrease'
        event_times             = ttsc.Time(ttsc.(ttsc_npi_identifier) == 1 );
        event_description       = repmat({'restriction eases'}, numel(event_times),1); 
        
    case 'npi_all'
        event_times             = ttsc.Time(ttsc.(ttsc_npi_identifier) == 1 );
        event_description       = repmat({'event'}, numel(event_times),1);          
end
    

C.ANZ_effect_of_npi_STA(ttsc,...
    ttsc_Y_var_name,...
    event_times,...
    event_description =  event_description)




