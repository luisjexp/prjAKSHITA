classdef csvimporter < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

%% NAMING VARIABLES WITH RACE VALUES
properties (Constant)
    raceoptions_all = {'white',...
        'black',...
        'latino',...
        'asian',...
        'american indian or alaska native',...
        'Multi-Race',...
        'native hawaiian and other pacific islander'}
    
    tag_white   = 'wht';
    tag_black   = 'blk';
    tag_asian   = 'asn';
    tag_latino  = 'ltn';
    tag_multi = 'mlt';
    tag_native = 'ntv';
    tag_pacific = 'pcf';
    tag_allraces = {csvimporter.tag_white,...
        csvimporter.tag_black,...
        csvimporter.tag_asian,...
        csvimporter.tag_latino,...
        csvimporter.tag_multi,...
        csvimporter.tag_native,...
        csvimporter.tag_pacific};
    
    tag_add_to_var_name_format = '%s_%s'; %eg X = blk_epiestimR
    
    
end

methods (Static)
    %% - - - tagg variable names
    function vars_names_tagged = tagvarnames(tt, tag)
        C = csvimporter;
        vars_names_tagged = cellfun(@(var_name_array) sprintf(C.tag_add_to_var_name_format, tag, var_name_array),...
            tt.Properties.VariableNames,'UniformOutput',false);   
    end
    
    %% - - - convert race value to race tag
    function race_tag = convert_raceval_2_racetag(race_str)
            C = csvimporter;
            switch upper(race_str)
                case 'WHITE'
                    race_tag = C.tag_white;
                case {'BLACK', 'AFRICAN AMERICAN'};...
                        race_tag = C.tag_black;
                case ('ASIAN');...
                        race_tag = C.tag_asian;
                case {'LATINO', 'HISPANIC/LATINO'};...
                        race_tag = C.tag_latino;
                case upper('american indian or alaska native');...
                        race_tag = C.tag_native;
                case 'MULTI-RACE';...
                        race_tag = 'mlt';
                case upper({'native hawaiian AND other pacific islander',...
                        'native hawaiian OR other pacific islander'})
                        race_tag = C.tag_pacific;
                otherwise
                    error('LUIS')

            end
    end
    
end

%% RAW DATA SETS - - - - - - - 
%% - - - RAW DATA FILE NAME FORMATS
properties (Constant)
    data_file_path              = '/Users/luis/Box/prjAKSHITA/aksDATA/'
    fname_tt_statewide_format     = [csvimporter.data_file_path, 'TT_statewide_%s.csv'];       
    fname_tt_santaclara_format    = [csvimporter.data_file_path,'TT_santaclara_%s.csv'];      
    fname_tt_sanfrancisco_format  = [csvimporter.data_file_path,'TT_sanfrancisco_%s.csv'];    
end

    
    
%% - - - CAL GOV STATE WIDE                                      
properties (Constant)
    calgov_varnames_raw_to_extract          = {'total_cases',  'percent_cases', 'deaths', 'percent_deaths'};
    calgov_varnames_new_names               = {'calgov_case_count_cum','calgov_case_pct_cum', 'calgov_death_count_cum',  'calgov_death_pct_cum'} ; 
    calgov_varname_case_count_daily         = 'calgov_case_count_daily';
    calgov_varname_case_count_daily_wkave   = 'calgov_case_count_daily_wkave';
    calgov_varname_case_pctchange_daily_wkave = 'calgov_case_pctchange_daily_wkave';
end

methods (Static)
    % - - -  - - -  import cal gov  statewide cases by race
    function tt = impcsv_statewide_case_vs_race_calgov(race_str)
        C = csvimporter;   

        fname               = [C.data_file_path, 'dtaCSV_statewide_case_vs_race_calgov.csv'];
        varname_datetime    = 'report_date';
        pullracedata        =  @(tt) tt (contains(tt.('demographic_category'), 'Race Ethnicity') &...
            contains(upper(tt.('demographic_value')),upper(race_str)), :); 

    % NOTE KEEP THIS PROCEDURE IN THIS ORDER...
        %   GET CALI DATA   
        opts    = detectImportOptions(fname);
        tbl     = readtable(fname, opts);
        %   PULL DATA FROM SPECIFIC RACIAL GROUP FIRST
        tbl = pullracedata(tbl);

        %   CONVERT TO TIME TABLE (rename, sort rows, then retime)
        tt     = table2timetable(tbl, 'RowTimes', varname_datetime); 

        % rename datetime var to 'Time' for joining tables 
        tt.Properties.DimensionNames{1} = 'Time';

        % retime: to fill in gaps left by pulling race data
        tt              = retime(sortrows(tt), 'daily', 'previous');

        % PULL RELEVENT VARIABLES AND RENAME THEM 
        tt = tt(:, C.calgov_varnames_raw_to_extract);  
        tt.Properties.VariableNames = C.calgov_varnames_new_names; 


        % ADD VARIABLES TO CALGOV DATA SET
        tt = ttvargenerator.stationtest(tt, 'calgov_case_count_cum',...
            var_name_new = 'calgov_case_count_daily', num_stations = 1); 
        tt.calgov_case_count_daily(tt.calgov_case_count_daily<0) = 0; 


        tt = ttvargenerator.smoothvar(tt, 'calgov_case_count_daily', 7,...
            var_name_new = 'calgov_case_count_daily_wkave');   


        tt = ttvargenerator.diffOfLogsCont(tt, 'calgov_case_count_daily_wkave',...
            var_name_new = 'calgov_case_pctchange_daily_wkave');

        
    %                                         'calgov_death_count_cum', 'difference', 'calgov_death_count_daily',...    
    %   ADD VARIABLE DESCRIPTIONS
        % demographic_category: 8612×1 cell array of character vectors
        % demographic_value: 8612×1 cell array of character vectors
        % total_cases: 8612×1 double
        % percent_cases: 8612×1 double
        % deaths: 8612×1 double
        % percent_deaths: 8612×1 double
        % percent_of_ca_population: The race's percentage of the overall state population in this age bracket. 
        % report_date: 8612×1 datetime    



    end
    
end

%%  - - - GIT HUB STATE WIDE 
properties (Constant)                                 
    git_varnames_raw_to_extract = {'confirmed_cases_total', 'population_percent', 'deaths_total', 'deaths_percent'};
    git_varnames_new_names      = {'git_case_count_cum',  'git_case_pct_cum', 'git_death_count_cum',  'git_death_pct_cum'} ;    
end
    
methods (Static)
    % - - - - - - import git hub statewide cases by race
    function [tt] = impcsv_statewide_case_vs_race_git(race)     
        C = csvimporter;
         fname               = [C.data_file_path, 'dtaCSV_statewide_case_vs_race_git.csv'];
        varname_datetime    = 'date';
        pullracedata        = @(tt) tt(contains(upper(tt.('race')),upper(race)) &...
            contains(tt.('age'),'all'), :);        

        
        % NOTE KEEP THIS PROCEDURE IN THIS ORDER...
            % Get cali data -> pull race group data -> convert to TT -> pull 
            % relevent vars -> rename vars
        % GET CALI DATA   
            opts    = detectImportOptions(fname);
            tbl     = readtable(fname, opts);

        % PULL DATA FROM SPECIFIC RACIAL GROUP FIRST
            tbl = pullracedata(tbl);

        % CONVERT TO TIME TABLE (rename, sort rows, then retime)
            tt     = table2timetable(tbl, 'RowTimes', varname_datetime); 
            % rename datetime var to 'Time' for joining tables 
            tt.Properties.DimensionNames{1} = 'Time';

            % retime: to fill in gaps left by pulling race data
            tt           = retime(sortrows(tt), 'daily', 'previous');

        % PULL RELEVENT VARIABLES AND RENAME THEM 
            tt = tt(:, csvimporter.git_varnames_raw_to_extract);
            tt.Properties.VariableNames = csvimporter.git_varnames_new_names; 

        % ADD VARIABLE DESCRIPTIONS
                    % field		description
                    % date                      The date when the data were retrieved in ISO 8601 format.
                    % race                      The race being tallied.
                    % age                       The age bracket being tallied
                    % confirmed_cases_total		The cumulative number of confirmed coronavirus case amoung this race and age at that time.
                    % confirmed_cases_percent	The case totals percentage of the total in this age bracket
                    % deaths_total              The cumulative number of deaths case amoung this race and age at that time.
                    % deaths_percent            The death totals percentage of the total in this age bracket.
                    % population_percent		The race's percentage of the overall state population in this age bracket.    
                

    
    
    end
end

%% - - - AKSHITA STATE WIDE NPI 
properties (Constant)
    aks_varnames_raw_to_extract = {'npi_on', 'policy_description'} 
    aks_varnames_new_names      = {'aks_npi_onset',  'aks_npi_description'} ;    
end

methods (Static)
    % - - -  - - - import akshita npi
    function [tt, retime_method] = impcsv_cali_policy_vAkshita()
        C = csvimporter;
        % READ CSV DATA INTO TABLE
        fname_calpol   = [C.data_file_path, 'dtaCSV_LumiereDataset.csv'];
        opts_calpil    = detectImportOptions(fname_calpol);
        tbl      = readtable(fname_calpol, opts_calpil);


        % PULL NPI REALTED POLICIES ONLY (NO VACCINATIONS)
        % PULL STATE LEVEL POLICIES ONLY (NO COUNTY RESTRICTIONS)
        npi_state_Idx   = contains( upper(tbl.('policy_regional_level')), 'STATE');
        tbl             = tbl(npi_state_Idx, :);      


        tt              = table2timetable(tbl, 'RowTimes', 'Time');         
        tt.Properties.DimensionNames{1} = 'Time'; % for consistency 
        tt = retime( sortrows(tt), 'daily', 'fillwithmissing');
        retime_method = 'fillwithmissing';


        tt = tt(:, csvimporter.aks_varnames_raw_to_extract);  
        tt.Properties.VariableNames = csvimporter.aks_varnames_new_names;     





        % ADD VARIABLE DESCRPTIONS

        % PRINT TABLE
    %     summary(tt_cali_policy_vAkshita)
    %     head(tt_cali_policy_vAkshita)

    % {'Time'}    
    % {'policy_description'}
    % {'is_npi_policy'}
    % {'npi_on'}
    % {'policy_regional_level'}
    % {'county'}
    % {'target_age'}
    % {'Industry'}    

    end
end

%% - - - HAUG 2020 STATE/COUNTRY NPI
properties (Constant)
    haug_varnames_raw_to_extract = {'Measure_L1', 'Measure_L2', 'Measure_L3'} 
    haug_varnames_new_names      = {'haug_npi_type', 'haug_npi_type_sub',  'haug_npi_type_subsub'} ;  
end

methods (Static)
    % - - - - - - import haug
    function [tt, retime_method] = impcsv_cal_npi_haug(options)
        arguments
            options.region_level = 'state'
        end
        C = csvimporter;
        % GET GLOBAL DATA
        fname_cases   = [C.data_file_path, 'dtaCSV_global_npi.csv'];
        opts_cases    = detectImportOptions(fname_cases);
        tbl           = readtable(fname_cases, opts_cases);

        tbl           = tbl(contains(tbl.('Country'), 'United States of America'),:);  % get statewide data only       

        if strcmpi(options.region_level, 'STATE')
            tbl           = tbl(contains(tbl.('State'), 'California'),:);  % get statewide data only          
        elseif strcmpi(options.region_level, 'COUNTRY')       
            idx         = contains(tbl.('State'), 'United States of America')   ;    
            tbl           = tbl(idx, :);  % get statewide data only          
        end

        % CONVERT TO TIME TABLE (rename, sort rows, then retime)
        tt       = table2timetable(tbl, 'RowTimes', 'Date');     
        tt.Properties.DimensionNames{1} = 'Time'; 
        tt          = retime(sortrows(tt), 'daily', 'firstvalue'); 
        retime_method = 'firstvalue';    


        % PULL RELEVENT VARIABLES AND RENAME THEM 
        tt = tt(:, csvimporter.haug_varnames_raw_to_extract());
        tt.Properties.VariableNames = csvimporter.haug_varnames_new_names; 

        tt = ttvargenerator.makedummy(tt, 'haug_npi_type',...
                var_name_new='haug_npi_any_onset', ifempty_set2nan = true);


    % - - - - - - Variable Descriptions
    % ID – Unique identifier for each individually implemented measure. 
    %           ID is also used in the Google Form to report erroneous entries.    
    % Country – The country where the measure was implemented.    
    % ISO3 – Three-letter country code as published by the International Organization for Standardization. 
    % State – Subnational geographic area. State where the measure was implemented; 
    %           the country name otherwise. Used for Germany, India, and USA. 
    % Region – Subnational geographic area (e.g. region, department, municipality, city) 
    %           where the NPI has been locally implemented (i.e. the measure was not implemented nationwide as of the mentioned date). 
    %           The country or the state name otherwise (i.e. measure implemented nationwide). 
    % Date – Date of implementation of the NPI. 
    %           Date of announcement was used when the date of implementation of the NPI could not be found and this was specified in the field Comment. 
    % L1_Measure – Theme (L1 of the classification scheme). Eight themes were defined (see Online-only Table 1). 
    % L2_Measure – Category (L2 of the classification scheme). Online-only Table 1 provides the list of the categories for each theme.
    % L3_Measure – Subcategory (L3 of the classification scheme). Provides detailed information on the corresponding category (L2). 
    % L4_Measure – Code (L4 of the classification scheme). Corresponds to the finest level of description of the measure. 
    % Status – Indicates whether the measure is a prolongation of a previously implemented measure (“Extended”) or not (“”). 
    % Comment – Provides the description of the measure as found in the text data source, translated into English. This field allows to judge the quality of the label for the different levels of the coding scheme and enables to re-assign the measure to the correct theme/category/subcategory/code in case of error or misinterpretation by the data collector21. When available, duration of the restriction, as officially announced, is mentioned in this field. Source – Provides the reference for each entry, i.e. URL. Enables to trace back potential changes in the meaning of the label during the translation21. Enables to access the description of the measure in the source language and/or to access to the information as it was dispatched originally
    end
end

%% - - - COUNTY TIER STATUS 
properties
    countytier_varnames_raw_to_extract = {'tier'} 
    countytier_varnames_new_names      = {'tier_status'};
end
methods
    % - - - - - -  import country tier stats
    function tt_tier_retime         = impcsv_county_unique_tier(county)
        C                           =  csvimporter;
        
        fname_tier_allCounties      =  [C.data_file_path, 'dtaCSV_git_county_tier.csv'];
        opts_tier_allcounties       = detectImportOptions(fname_tier_allCounties);
        tb_tier_allcounties         = readtable(fname_tier_allCounties, opts_tier_allcounties);

        countyIdx = contains(upper(tb_tier_allcounties.('county')), upper(county));   
        
        tb_tier_county = tb_tier_allcounties(countyIdx,{'tier', 'date'});

        % NOTE: When importing county tier data, do not rearrange this code...
        tt_tier         = timetable(tb_tier_county.tier, 'RowTimes',tb_tier_county.date);
        tt_tier.Properties.DimensionNames{1} = 'Time'; 
        tt_tier.Properties.VariableNames = C.countytier_varnames_new_names;


        tt_tier_sort = sortrows(tt_tier);
        tt_tier_retime = retime(tt_tier_sort, 'daily', 'previous');

        tt_tier_retime.tier_decrease = [0; diff( tt_tier_retime.('tier_status') ) <0];
        tt_tier_retime.tier_increase = [1; diff( tt_tier_retime.('tier_status') ) >0];      


    end
end


%% PREPROCESSING 
properties (Constant)
    fname_tag_epistem_notadded      = 'noR'
    fname_tag_epistem_added         = 'yesR'    
    epistem_varname_R               = 'epistem_R';   
    
end

methods (Static)
    %% - - - Add epiestim to table 
    function tt_added_var = preproc_addvar_epiestim(data_region)
        C = csvimporter;

        switch upper(data_region)
            case 'STATEWIDE'
                !/Library/Frameworks/R.framework/Versions/3.5/Resources/bin/Rscript /Users/luis/Box/prjAKSHITA/aksANALYZE/TT_REGION_Rgenerate_STATEWIDE.R                
                fname_with_R_tt     =   sprintf(C.fname_tt_statewide_format, C.fname_tag_epistem_added );  
                csv_imp_opts        = detectImportOptions(fname_with_R_tt); 
                varOpts = setvartype(csv_imp_opts, {'aks_npi_onset','haug_npi_any_onset'}, 'double') ; 
                

            case 'SANTACLARA'
                !/Library/Frameworks/R.framework/Versions/3.5/Resources/bin/Rscript /Users/luis/Box/prjAKSHITA/aksANALYZE/TT_REGION_Rgenerate_SANTACLARA.R                
                fname_with_R_tt     =   sprintf(C.fname_tt_santaclara_format, C.fname_tag_epistem_added);  
                csv_imp_opts = detectImportOptions(fname_with_R_tt);
                varOpts = setvartype(csv_imp_opts, {'ntv_new_cases','mlt_new_cases','pcf_new_cases',...
                    'pcf_epiestimR','mlt_epiestimR', 'ntv_epiestimR',...
                    'tier_status','tier_increase', 'tier_decrease',...
                    'haug_npi_any_onset'}, 'double') ; 

            case 'SANFRANCISCO'

            otherwise
            error('luis')
            
            
        end
        
        tt_added_var =   readtable(fname_with_R_tt, varOpts);


        
    end
end


%% GENERATE TIME TABLES
methods (Static)
    %% - - - STATEWIDE TABLE: statewide covid cases and npis for all races
    function tt_statwide = gentt_STATEWIDE_master()
        C = csvimporter;

        tt_covidcase_allraces   = C.gentt_statewide_covidcase_for_allraces();
        tt_NPIs                 =  C.gentt_statewide_NPIs;

        tt_statwide = outerjoin(tt_covidcase_allraces,tt_NPIs,...
            'MergeKeys', true); 

        % write to csv (note that this does not contain R variable)
        fname_tt_without_R   = sprintf(C.fname_tt_statewide_format, C.fname_tag_epistem_notadded );    
        writetimetable(tt_statwide, fname_tt_without_R);  

        fprintf('\n\n DELETING OLD PROCESSED TABLE WITH R\n\n')
        fname_tt_with_R_outdated   = sprintf(C.fname_tt_statewide_format, C.fname_tag_epistem_added );            
        delete(fname_tt_with_R_outdated)   
        
        
        tt_statwide = C.preproc_addvar_epiestim('statewide') ;
        fprintf('\n\n FINISHED ADDING EPISTEM TO STATEWIDETIME TABLE, NEW FILE ADDED\n\n')        
        
         
    end

    % - - - - - - - get statewide covid cases (no npis) for ALL races
    function tt = gentt_statewide_covidcase_for_allraces()
        C = csvimporter;
        tt = timetable;

        for i = C.raceoptions_all
            race_val        = i{:};
            tt_race_merged  = gentt_statewide_covidcase_for_onerace(race_val);
            tag             = C.convert_raceval_2_racetag(race_val);
            tt_race_merged.Properties.VariableNames = C.tagvarnames(tt_race_merged, tag);        
            tt              = outerjoin(tt,tt_race_merged, 'MergeKeys', true);
        end
        
        
        % - - - get statewide covid cases for one race onlys    
        function tt = gentt_statewide_covidcase_for_onerace(race_val)
            % GIT HUB covid case data for one race
            [tt_case_race_git]     = csvimporter.impcsv_statewide_case_vs_race_git(race_val); 

            % CAL WEB covid case data for one race
            [tt_case_race_calweb] =  csvimporter.impcsv_statewide_case_vs_race_calgov(race_val);               

            % JOIN
            tt = csvimporter.jointimetables(tt_case_race_git, tt_case_race_calweb,...
                'previous', 'previous');     
        end
        
        
    
    end
    
    %% - - - STATEWIDE NPI TABLE 
    function tt = gentt_statewide_NPIs()
            % HAUG 2020 NPI DATA_
            [tt_npi_haug, retime_haug] = csvimporter.impcsv_cal_npi_haug(); 

            % AKSHITA POLICY DATA
            [tt_policy_vAkshita, retime_akshita] =...
                csvimporter.impcsv_cali_policy_vAkshita() ;   

            %JOIN
            tt = csvimporter.jointimetables(tt_policy_vAkshita, tt_npi_haug,...
                'fillwithmissing', 'fillwithmissing');      

            tt.('alldta_npi_any_onset') =  any([tt.aks_npi_onset, tt.haug_npi_any_onset],2);                 
    end

    
    %% - - - SANTACLARA TABLE: stclara covid cases, tiers, and cal npis for all races
    function TT_case_tier_npi = gentt_SANTACLARA_master() 
        % Get Santa Clara Data
        C = csvimporter;
        fname_tt_without_R  =  [C.data_file_path, 'dtaCSV_county_santaclara_case.csv'];
        tbl                 = readtable(fname_tt_without_R, detectImportOptions(fname_tt_without_R));
        tbl.start_date      = datetime(tbl.start_date, 'Format', 'yyyy-MM-dd');
        tbl.end_date        = datetime(tbl.end_date, 'Format', 'yyyy-MM-dd');
        tbl.Time            = mean([tbl.start_date, tbl.end_date],2);


        race_val_list = upper(C.raceoptions_all);

        tt = sortrows(timetable('RowTimes', tbl.Time));
         for i = 1:numel(race_val_list)
            race_val = race_val_list{i};

            switch race_val
                case 'BLACK'
                    race_val = 'AFRICAN AMERICAN';
                case 'LATINO'
                    race_val = 'HISPANIC/LATINO'; 
                case upper('native hawaiian AND other pacific islander'),...
                        race_val = upper('native hawaiian OR other pacific islander');              

            end


            raceIdx             = contains(upper(tbl.('race_ethnicity')), race_val);   
            tbl_race_unique     = tbl(raceIdx,{'Time', 'new_cases'});    
            tt_race_unique      = table2timetable(tbl_race_unique);
            race_tag            = C.convert_raceval_2_racetag(race_val);
            vars_names_tagged   = C.tagvarnames(tt_race_unique, race_tag);
            tt_race_unique.Properties.VariableNames = vars_names_tagged;


            tt = synchronize(tt, tt_race_unique);
         end


         TT_case_stclara = retime(tt, 'daily', 'previous');
         TT_tier_stclara = C.impcsv_county_unique_tier('santa clara');
         TT_case_and_tier = synchronize(TT_case_stclara,TT_tier_stclara);

         % NOTE: joining table leaves dates where there are no tiers. these
         % dates are assumed to have 'no tiers', which are defined as tier 5, the
         % a tier above the highest tier (4)
         TT_case_and_tier.tier_status ( isnan(TT_case_and_tier.tier_status) ) = 5;
         TT_case_and_tier.tier_decrease = [0; diff( TT_case_and_tier.('tier_status') ) <0];
         TT_case_and_tier.tier_increase = [0; diff( TT_case_and_tier.('tier_status') ) >0];      

         TT_npi_statewide = C.impcsv_cal_npi_haug() ;   
         TT_case_tier_npi = synchronize(TT_case_and_tier,TT_npi_statewide);


         if ~isregular(TT_case_tier_npi)
             error('LUIS')
         end


         % NOTE: SAVE AS CSV, This tt table does not contain R vairbale. 
         fname_tt_without_R   = sprintf(C.fname_tt_santaclara_format, C.fname_tag_epistem_notadded );            
         writetimetable(TT_case_tier_npi, fname_tt_without_R);

         % NOTE: will delete the TT with an R variable, to prevent accidental
         % usage of outdated time table. This will force you to generate the TT
         % using the newest version of the raw data
    %      fname_tt_with_R_outdated   = sprintf(C.fname_tt_santaclara_format, C.fname_tag_epistem_added );            
    %      delete(fname_tt_with_R_outdated)


    end


    %% - - - SAN FRANCISCO TABLE: (BUILDING)
    function tf = impcsv_county_sanfran_races_all() 
        % GET SAN FRAN DATA
        fname_cases   = 'dtaCSV_sanfran_case_vs_race.csv';
        opts_cases    = detectImportOptions(fname_cases);
        tb_cases      = readtable(fname_cases, opts_cases);
        tb_cases.specimen_collection_date = datetime(tb_cases.specimen_collection_date, 'Format', 'yyyy-MM-dd');

        % PULL DESIRED RACE DATA
        raceIdx = contains(upper(tb_cases.('race_ethnicity')), upper(race));        
        tb_cases    = tb_cases(raceIdx,{'specimen_collection_date', 'new_confirmed_cases'});            
        tt_race     = table2timetable(tb_cases);   

        % RENAME ROWS VAR TO 'TIME'
        tt_race.Properties.DimensionNames{1} = 'Time'; 

        % IMPORT TIER DATA
        tt_tier = csvimporter.county_tier('san francisco');

        % JOIN TABLES
        tf = outerjoin(tt_tier,tt_race, 'MergeKeys', true);
        tf.tier = fillmissing(tf.tier,'previous');

    end


%% - - - SOME FXNS FOR GEN TABLES
    %% - - - - - - join 2 tables
    function TT_merged_retimed = jointimetables(tt1, tt2, tt1_retime_method, tt2_retime_method)

        TT_merged = outerjoin(tt1,tt2, 'MergeKeys', true);

        tt1_merged = TT_merged(:,tt1.Properties.VariableNames);
        tt2_merged = TT_merged(:,tt2.Properties.VariableNames);

        % in case one table has more time stamps than the other one
        tt1_merged_retimed = retime(tt1_merged,'daily', tt1_retime_method);
        tt2_merged_retimed = retime(tt2_merged,'daily', tt2_retime_method);

        TT_merged_retimed =[tt1_merged_retimed, tt2_merged_retimed];
        TT_merged_retimed = sortrows(TT_merged_retimed);

    end






%% ANALYSYS 
function ANZ_effect_of_npi_STA(tt_all_race, y_var_name, event_times_list, options)
    %% - - - EFFECT OF NPIs ON change in outcomes
    arguments
        tt_all_race
        y_var_name
        event_times_list
        options.event_description cell = repmat({'event'}, numel(event_times_list),1)
    end
    %% - - - - - - Initialize
    C = csvimporter;

    time_stamps = tt_all_race.Time;
    time_stamps_numberof = numel(time_stamps);
    var_names = tt_all_race.Properties.VariableNames(contains(tt_all_race.Properties.VariableNames ,y_var_name));
    var_names_ordered = sort(var_names);
    var_names_numof = numel(var_names_ordered);
    
    tt_R = table2timetable(tt_all_race(:, var_names_ordered ), 'RowTimes', time_stamps);

    
    npi_events_number = numel(event_times_list);
    
    figure(1)
    clf;    

    days_pre_event_num      = 7;
    day_of_event_num        = days_pre_event_num;
    days_post_event_num     = 7;
    days_prior_event  = days(days_pre_event_num);
    days_post_event   = days(days_post_event_num);
    
    
    dim_race = 2;
    dim_event = 3;
    dim_rand_iteration = 4;    

    %% - - - - - - Event Triggered average: random events 
    dR_random = [];
    V_random = [];

    time_stamps_clipped = time_stamps(days_pre_event_num+1:time_stamps_numberof-days_post_event_num-1);
    time_stamps_clipped_numof = numel(time_stamps_clipped);
    num_iterations = 5;

        for i = 1:num_iterations
            for k = 1:npi_events_number
                npi_event_date_random = time_stamps_clipped(randi(time_stamps_clipped_numof));
                tau_window_random = npi_event_date_random - days_prior_event:...
                    days(1):...
                    npi_event_date_random + days_post_event;

                V_random =  tt_R(tau_window_random,:).Variables ;
    %             dR_random(:,:,k, i) = V_random(day_of_event_num,:) - V_random;
                dR_random(:,:,k, i) = V_random;


            end
        end
    

    
    % RANDOM dR BY RACE OR BY EVENTS
        % BY EVENT
        dR_rand_events_pancake_race_mu        = nanmean(nanmean(dR_random, dim_race),dim_rand_iteration );
        dR_rand_events_pancake_race_std       = nanstd(nanmean(dR_random, dim_race),0,dim_rand_iteration );
            % squeeze all
            dR_rand_events_pancake_race_mu        = squeeze(dR_rand_events_pancake_race_mu);
            dR_rand_events_pancake_race_std       = squeeze(dR_rand_events_pancake_race_std);
            
        % BY RACE
        dR_random_race_pancake_events_mu        = nanmean(nanmean(dR_random, dim_event),dim_rand_iteration);
        dR_random_race_pancake_events_std       = nanstd(nanmean(dR_random, dim_event),0,dim_rand_iteration);
            
        % squeeze all
            dR_random_race_pancake_events_mu    = squeeze(dR_random_race_pancake_events_mu);
            dR_random_race_pancake_events_std   = squeeze(dR_random_race_pancake_events_std);            
    
    
    % RANDOM dR IGNORE RACE AND EVENTS
    dR_random_pancake_race_and_events_mu    = nanmean(nanmean (nanmean(dR_random,dim_race),dim_event),dim_rand_iteration );
    dR_random_pancake_race_and_events_std   = nanstd(nanmean(nanmean(dR_random,dim_race),dim_event),0,dim_rand_iteration );
    
    %% - - - - - - NPI triggered average: true events    
    V = []    ;
    dR = [];
    R = []
    
    
    for k = 1:npi_events_number
        npi_event_date = event_times_list(k);
        tau_window = npi_event_date - days_prior_event:...
            days(1):...
            npi_event_date + days_post_event;
        
        V = tt_R(tau_window,:).Variables ;
%         dR(:,:,k) =  V;
        dR(:,:,k) = V(day_of_event_num,:) - V;
        

    end
    
  
    % COMBINE DATA



    dR_events_pancake_race = squeeze(nanmean(dR, dim_race));
    
    dR_races_pankake_events = squeeze(nanmean(dR, dim_event));
    dR_races_pankake_events_std = squeeze(nanstd(dR, 0, dim_event));
    
    
    dR_pancake_race_and_events = nanmean(nanmean(dR,dim_race),dim_event);
    dR_pancake_race_and_events_std = nanstd(nanmean(dR,dim_race),0,dim_event);
    
%% - - - - - - PLOT DATA
%                   NOW LETS PLOT
    figure(1)
    clf
%     nexttile
%     plot(tt_R.Time,tt_R.Variables); 
%     legend(tt_R.Properties.VariableNames, 'Interpreter', 'none')
%     axis tight
% 
%     ttviewer.vars_and_events(tt_R,...
%             Y_var_name_axis_left = '',...
%             Y_var_name_axis_right = '',...
%             event_times         = event_times_list,...
%             event_description   = options.event_description,...
%             ax                  = gca);
        
        
% % % % % % % % % % % % % % % % %         
    
    x = [-days_pre_event_num:days_post_event_num]';
    ymin = nanmin([dR(:) ;dR_random(:)]);
    ymax = nanmax([dR(:) ;dR_random(:)]);
    ymin = nanmin(nanmean([dR(:) ;dR_random(:)]))
    ymax = nanmax(nanmean([dR(:) ;dR_random(:)])    )
%     ymin = -1000
%     ymax = 1000
%     
    
    % Plot the temporal kernel of each event. Ignore races.
    for i = 1:npi_events_number
        nexttile
        y_rand_mu       = dR_rand_events_pancake_race_mu(:,i);
        y_rand_std      = dR_rand_events_pancake_race_std(:,i);
        y_data_dR       = dR_events_pancake_race(:,i);
        
        errorbar(x,y_rand_mu,y_rand_std); hold on;
        plot(x, y_data_dR, 'LineWidth', 6)   
        set(gca, 'XLim', [min(x), max(x)]) 
        
        title_string = sprintf('%s\nt=[%s]', y_var_name, event_times_list(i));
        title(title_string, 'Interpreter', 'none')
        drawnow
    end
    
    
    figure(2)
    clf
    nexttile
    for i = 1:var_names_numof
        nexttile
        y_rand_mu   = dR_random_race_pancake_events_mu(:,i);
        y_rand_std  = dR_random_race_pancake_events_std(:,i);
        y_data      = dR_races_pankake_events(:,i);
        y_std       = dR_races_pankake_events_std(:,i);
        errorbar(x, y_data, y_std)

%         plt_race_or_event(x, y_rand_mu, y_rand_std,y_data) 
%         set(gca, 'YLim', [ymin, ymax])
        
        title(sprintf('dR_RACE_%s', var_names_ordered{i}), 'Interpreter', 'none')   
        xlabel('Days before/after npi')
        ylabel(sprintf('Change in %s', y_var_name), 'Interpreter', 'none')
        
        
    end   
       nexttile

%         y_rand_mu   = dR_random_pancake_race_and_events_mu;
%         y_rand_std  = dR_random_pancake_race_and_events_std;
%         y_data      = dR_pancake_race_and_events;
%         plt_race_or_event(x, y_rand_mu, y_rand_std,y_data) 

        y_data      = dR_pancake_race_and_events;
        y_std       = dR_pancake_race_and_events_std;
        errorbar(x, y_data, y_std)

%         set(gca, 'YLim', [ymin, ymax])
        
        title(sprintf('dR'), 'Interpreter', 'none')   
        xlabel('Days before/after npi')
        ylabel(sprintf('Change in %s', y_var_name), 'Interpreter', 'none')
        
    
    
   
    function plt_race_or_event(x,y_rand_mu,y_rand_std, y_data)
        errorbar(x,y_rand_mu,y_rand_std); hold on;
        plot(x, y_data, 'LineWidth', 6)
        set(gca, 'XLim', [min(x), max(x)])
    end
    
    
end


%% - - - LASSO REGRESSION BY HAUG  
function [tt_lagged,var_names_lagged] =  ANZ_effect_of_npi_lasso(tt, var_name_2_shift, shift_amount_list)
    arguments
        tt
        var_name_2_shift
        shift_amount_list = 1:28;
    end
    VG = ttvargenerator;
    
    [tt_lagged, var_names_lagged]  = VG.timeshift(tt,...
        var_name_2_shift,...
        shift_amount_list);       
    

        [lamdas, L] = lasso(X_lagged, Y ,...
            'CV', 10,...
            'PredictorNames',...
            IVs_to_train);

        % % % % % % % % % % % % % % % % 
        % RUN REFINED Linear Models
        tbl = timetable2table(tt);

        
        % Fit sparsest model within one standard error of the minimum MSE.
        idxLambda1SE = L.Index1SE;
        L.model_sparse_predictor_nmes   = L.PredictorNames(lamdas(:,idxLambda1SE)~=0);
        L.model_sparse_fit              = fitlm(tbl,...
            'ResponseVar', DV_name,...
            'PredictorVars', L.model_sparse_predictor_nmes);
        L.model_sparse_predictor_weights =  L.model_sparse_fit.Coefficients(L.model_sparse_predictor_nmes,:).Estimate;  
        
        
        
        %--------------------
        % Fit model that corresponds to the minimum cross-validated mean squared error (MSE).
        
        idxLambdaMinMSE       = L.IndexMinMSE;        
        L.model_minMSE_predictor_nmes   = L.PredictorNames(lamdas(:,idxLambdaMinMSE)~=0);     

        L.model_minMSE_fit              = fitlm(tbl,...
            'ResponseVar', DV_name,...
            'PredictorVars', L.model_minMSE_predictor_nmes);
        
        L.model_minMSE_predictor_weights =  L.model_minMSE_fit.Coefficients(L.model_minMSE_predictor_nmes,:).Estimate;  
        


        
                % Visually examine the cross-validated error of various levels of regularization.
        % 
        % close all;
        % lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');
        % lassoPlot(B,FitInfo,'PlotType','CV');
        % legend('show') % Show legend
        % 
        % text(.4,.6,sprintf(['The green circle and dotted line\n',...
        %    '\tlocate the Lambda with minimum cross-validation error.\n',...
        %     'The blue circle and dotted line\n',...
        %     '\tlocate the point with minimum cross-validation error plus one standard deviation.']),...
        %     'Units', 'normalized')
        

        nexttile
        plot(t, Y, '-'); hold on;
        
        plot(t, L.model_minMSE_fit.predict, '-',...
            'color', [.1, 1, .8, .7],...
            'LineWidth', 7); hold on;
        
        plot(t, L.model_sparse_fit.predict, '-',...
            'color', [.8, 1, .1, .4],...
            'LineWidth', 5); hold on;          
        
        legend({'true return',...
            'prediction of minMSE model',...
            'prediction of sparse model'})
        ylabel(DV_name, 'Interpreter', 'none')
        
        title(options.plot_title)
        drawnow    
    
    
        
        
        
        
end


end
    
    
    
    
    
    
end
    
