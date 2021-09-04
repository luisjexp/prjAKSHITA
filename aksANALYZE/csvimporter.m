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
                case {'BLACK', 'AFRICAN AMERICAN','BLACK/AFRICAN AMERICAN'};...
                        race_tag = C.tag_black;
                case ('ASIAN');...
                        race_tag = C.tag_asian;
                case {'LATINO', 'HISPANIC/LATINO', 'LATINO/HISPANIC'};...
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
        tt     = readtable(fname, opts);
        %   PULL DATA FROM SPECIFIC RACIAL GROUP FIRST
        tt = pullracedata(tt);

        %   CONVERT TO TIME TABLE (rename, sort rows, then retime)
        tt     = table2timetable(tt, 'RowTimes', varname_datetime); 

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


            switch upper(race_str)
                case 'WHITE'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(14356081, height(tt),1 );
                    
                case 'BLACK'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(2171989, height(tt),1);
                    

                case 'LATINO'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(15574882, height(tt),1);
                    
                        
                case 'ASIAN'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(5786711, height(tt),1);
                    
                    
                case 'AMERICAN INDIAN OR ALASKA NATIVE'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(149063, height(tt),1);
                    
                    
                case 'MULTI-RACE'
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(1224113, height(tt),1);
                    
                    
                case upper('native hawaiian AND other pacific islander')
                    tt.death_pctof_racepop = tt.calgov_case_count_daily./repmat(141846, height(tt),1);
                    
      
                    
            end
            
%         tt = 100.*(tt.calgov_case_count_daily_wkave/tt.population);            

        
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
        tbl             = tbl(tbl.npi_on == 1,:);


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
properties (Constant)
    countytier_varnames_raw_to_extract = {'tier'} 
    countytier_varnames_new_names      = {'tier_status'};
end
methods (Static)
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

        tier_status_normal_dates = [tt_tier_retime.Time(1)-day(1);...
            tt_tier_retime.Time(end)+day(1)];
        tier_5 = timetable([5;5], 'RowTimes', tier_status_normal_dates, 'VariableNames', {'tier_status'});
        tt_tier_retime = sortrows([tt_tier_retime; tier_5]);
        
        tt_tier_retime.tier_decrease = [0; diff( tt_tier_retime.('tier_status') ) <0];
        tt_tier_retime.tier_increase = [0; diff( tt_tier_retime.('tier_status') ) >0];      


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
    
    
    %% - - - clip days with no case data
    function tt = preproc_tt_clip_tt_missing_cases(tt)
        tt
        
        
    end
    
end


%% GENERATE TIME TABLES
methods (Static)
    %% - - - STATEWIDE MASTER TABLE: statewide covid cases and npis for all races
    function tt_statwide = gentt_STATEWIDE_master()
        C = csvimporter;

        tt_covidcase_allraces   = C.gentt_STATEWIDE_covidcase_for_allraces();
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
        tt_statwide = table2timetable(tt_statwide, 'RowTimes', 'Time');
        if ~isregular(tt_statwide)
            error('luis')
        end
        writetimetable(tt_statwide, [C.data_file_path 'TT_statewide_gcollab.csv'])
        
        fprintf('\n\n FINISHED ADDING EPISTEM TO STATEWIDETIME TABLE, SAVED TABLE\n\n')        
        
         
    end

    % - - - - - - - get statewide covid cases (no npis) for ALL races
    function tt = gentt_STATEWIDE_covidcase_for_allraces()
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

    
    %% - - - SANTACLARA MASTER TABLE: stclara covid cases, tiers, and cal npis for all races
    %% - - - - - - NOTE: table does not include epiestim variable
    function TT_case_and_tier = gentt_SANTACLARA_master() 
        % Get Santa Clara Data
        C = csvimporter;
        fname_tt_without_R  =  [C.data_file_path, 'dtaCSV_county_santaclara_case.csv'];
        tbl                 = readtable(fname_tt_without_R, detectImportOptions(fname_tt_without_R));
        tbl.start_date      = datetime(tbl.start_date, 'Format', 'yyyy-MM-dd');
        tbl.end_date        = datetime(tbl.end_date, 'Format', 'yyyy-MM-dd');
        tbl.Time            = mean([tbl.start_date, tbl.end_date],2);


        race_val_list = upper(C.raceoptions_all);
        tt = timetable;
         for i = 1:numel(race_val_list)
            race_val = race_val_list{i};

            switch race_val
                case 'WHITE'
                    tbl.population = repmat(586461, height(tbl),1 );
                    race_tag = 'wht';
                    
                    
                case 'BLACK'
                    race_val = 'AFRICAN AMERICAN';
                    tbl.population = repmat(46306, height(tbl),1);
                    race_tag = 'blk';
                    

                case 'LATINO'
                    race_val = 'HISPANIC/LATINO'; 
                    tbl.population = repmat(482298, height(tbl),1);
                    race_tag = 'ltn';
                    
                        
                case 'ASIAN'
                    tbl.population = repmat(724178, height(tbl),1);
                    race_tag = 'asn';      
                    
                    
                case 'AMERICAN INDIAN OR ALASKA NATIVE'
                    tbl.population = repmat(3213, height(tbl),1);
                    race_tag = 'ntv';
                    
                    
                case 'MULTI-RACE'
                    tbl.population = repmat(71933, height(tbl),1);
                    race_tag = 'mlt';                    
                    
                    
                case upper('native hawaiian AND other pacific islander')
                    race_val = upper('native hawaiian OR other pacific islander');                      
                    tbl.population = repmat(6752, height(tbl),1);
                    race_tag = 'pcf';
                    
            end
              

   
            % get raw variables
            raceIdx             = contains(upper(tbl.('race_ethnicity')), race_val);  
            tbl_single_race     = tbl(raceIdx,{'Time', 'new_cases', 'population'});    
            
            % Genearate new variables
            tbl_single_race.new_cases = movmean(tbl_single_race.new_cases, 7);           
            tbl_single_race.case_pctof_racepop = 100.*(tbl_single_race.new_cases./tbl_single_race.population);            
            
            % convert to tt and rename vars
            tt_single_race      =  table2timetable(tbl_single_race, 'RowTimes', 'Time');
            tt_single_race = renamevars(tt_single_race, 'new_cases', 'cases');
            tt_single_race = renamevars(tt_single_race, 'case_pctof_racepop', 'case_pctof_racepop');
            
            
            % Add race tags to vars
            vars_names_tagged   = C.tagvarnames(tt_single_race, race_tag);
            tt_single_race.Properties.VariableNames = vars_names_tagged;

            % Append
            tt_single_race      = sortrows(tt_single_race);
            tt = synchronize(tt, tt_single_race);            
            
         end

        
         
         % ORIGINAL
         TT_case = retime(tt, 'daily', 'previous');
         TT_tier_stclara = C.impcsv_county_unique_tier('santa clara');
         TT_case_and_tier = synchronize(TT_case,TT_tier_stclara);

         % NOTE: joining table leaves dates where there are no tiers. these
         % dates are assumed to have 'no tiers', which are defined as tier 5, the
         % a tier above the highest tier (4)
         TT_case_and_tier.tier_status ( isnan(TT_case_and_tier.tier_status) ) = 5;
         TT_case_and_tier.tier_decrease = [0; diff( TT_case_and_tier.('tier_status') ) <0];
         TT_case_and_tier.tier_increase = [0; diff( TT_case_and_tier.('tier_status') ) >0];      



         if ~isregular(TT_case_and_tier)
             error('LUIS')
         end


         % NOTE: SAVE AS CSV, This tt table does not contain R vairbale. 
         fname_tt_without_R   = sprintf(C.fname_tt_santaclara_format, C.fname_tag_epistem_notadded );            
         writetimetable(TT_case_and_tier, fname_tt_without_R);



    end
    
    %% - - - LOS ANGELES MASTER TABLE: covid cases, tiers, and cal npis for all races
    %% - - - - - - NOTE: table does not include epiestim variable
    function TT_case_tier_npi = gentt_LOSANGELES_master() 
        C = csvimporter;
        fname_tt_without_R  =  [C.data_file_path, 'dtaCSV_county_losangeles_case.csv'];
        tbl                 = readtable(fname_tt_without_R, detectImportOptions(fname_tt_without_R));


        race_val_list = upper(C.raceoptions_all);
        tt = timetable;
         for i = 1:numel(race_val_list)
            race_val = race_val_list{i};

            switch race_val
                case 'WHITE'
                    race_tag = 'wht';
                case 'BLACK'
                    race_val = upper('Black/African American');
                    race_tag = 'blk';
                    
                case 'LATINO'
                    race_val = upper('Latino/Hispanic');
                    race_tag = 'ltn';
                    
                case 'ASIAN'
                    race_tag = 'asn';      
                    
               case 'AMERICAN INDIAN OR ALASKA NATIVE'
                    race_tag = 'ntv';
                    
                case 'MULTI-RACE'
                    race_tag = 'mlt';                    
                    
                case   {'NATIVE HAWAIIAN AND OTHER PACIFIC ISLANDER'}
                    race_val = 'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER';
                    race_tag = 'pcf';
                    
            end



            
           
            raceIdx             = contains(upper(tbl.reth), race_val);  
            
            % Get raw variables
            tbl_single_race     = tbl(raceIdx,{'ep_date',...
                'adj_case_14day_rate',... 
                'adj_death_14day_rate',...
                'cases_14day',...
                'death_14day',...
                'population'}); 
            
            % Genearate new variables
            tbl_single_race.case_pctof_racepop = 100.*(tbl_single_race.cases_14day./tbl_single_race.population);            
            tbl_single_race.death_pctof_racepop = 100.*(tbl_single_race.death_14day./tbl_single_race.population);
            
            % convert to tt and rename vars
            tt_single_race      =  table2timetable(tbl_single_race, 'RowTimes', 'ep_date');
            tt_single_race.Properties.DimensionNames{1} = 'Time';
            tt_single_race = renamevars(tt_single_race, 'adj_case_14day_rate', 'case_rate_adj');
            tt_single_race = renamevars(tt_single_race, 'adj_death_14day_rate', 'death_rate_adj');
            tt_single_race = renamevars(tt_single_race, 'cases_14day', 'cases');
            tt_single_race = renamevars(tt_single_race, 'death_14day', 'deaths');
            tt_single_race = renamevars(tt_single_race, 'case_pctof_racepop', 'case_pctof_racepop');
            tt_single_race = renamevars(tt_single_race, 'death_pctof_racepop', 'death_pctof_racepop');
            
            % Add race tags to vars
            vars_names_tagged   = C.tagvarnames(tt_single_race, race_tag);
            tt_single_race.Properties.VariableNames = vars_names_tagged;

            % Append
            tt_single_race      = sortrows(tt_single_race);
            tt = synchronize(tt, tt_single_race);
         end
         
        
         if ~isregular(tt)
             error('luis')
         end
         
         tt_case = tt;
         tt_tier = C.impcsv_county_unique_tier('los angeles');
         tt_case_and_tier = synchronize(tt_case,tt_tier);

         % NOTE: joining table leaves dates where there are no tiers. these
         % dates are assumed to have 'no tiers', which are defined as tier 5, the
         % a tier above the highest tier (4)
         tt_case_and_tier.tier_status ( isnan(tt_case_and_tier.tier_status) ) = 5;
         tt_case_and_tier.tier_decrease = [0; diff( tt_case_and_tier.('tier_status') ) <0];
         tt_case_and_tier.tier_increase = [0; diff( tt_case_and_tier.('tier_status') ) >0];      

         tt_npi_statewide = C.impcsv_cal_npi_haug() ;   
         TT_case_tier_npi = synchronize(tt_case_and_tier,tt_npi_statewide);


         if ~isregular(TT_case_tier_npi)
             error('LUIS')
         end


         % NOTE: SAVE AS CSV, This tt table does not contain R vairbale. 
%          fname_tt_without_R   = sprintf(C.fname_tt_losangeles_format, C.fname_tag_epistem_notadded );            
%          writetimetable(TT_case_tier_npi, fname_tt_without_R);




    end

    %% - - - SAN FRANCISCO MASTER TABLE: covid cases, tiers, and cal npis for all races
    %% - - - - - - NOTE: table does not include epiestim variable
    function TT_death_and_tier = gentt_SANFRANCISCO_master() 
        % Get Santa Clara Data
        C = csvimporter;
        fname_tt_without_R  =  [C.data_file_path, 'dtaCSV_county_sanfrancisco_case.csv'];
        imp_opts = detectImportOptions(fname_tt_without_R);
        
        tbl     = readtable(fname_tt_without_R, imp_opts);
        tbl.DataAsOf
        
        race_val_list = upper(C.raceoptions_all);
        
        tt = timetable;
         for i = 1:numel(race_val_list)
            race_val = race_val_list{i};

            switch race_val
                case 'WHITE'
                    tbl.population = repmat(354423, height(tbl),1 );
                    race_tag = 'wht';

                case 'BLACK'
                    race_val = upper('Black or African American');
                    tbl.population = repmat(43782, height(tbl),1);
                    race_tag = 'blk';

                case 'LATINO'
                    race_val = upper('Hispanic or Latino/a, all races'); 
                    tbl.population = repmat(133314, height(tbl),1);
                    race_tag = 'ltn';
                        
                case 'ASIAN'
                    tbl.population = repmat(298108, height(tbl),1);
                    race_tag = 'asn';
                    
                    
                case 'AMERICAN INDIAN OR ALASKA NATIVE'
                    tbl.population = repmat(1634, height(tbl),1);
                    race_tag = 'ntv';
                    continue;
                    
                case 'MULTI-RACE'
                    race_val = upper('Multi-racial'); 
                    
                    tbl.population = repmat(11573, height(tbl),1);
                    race_tag = 'mlt';
                    continue;
                case upper('native hawaiian AND other pacific islander')
                    race_val = upper('Native Hawaiian or Other Pacific Islander');                      
                    tbl.population = repmat(2934, height(tbl),1);
                    race_tag = 'pcf';
                    continue; % skip, data is extremely sparse and messy
                    
            end

   
            % get raw variables
            raceIdx             = contains(upper(tbl.('CharacteristicGroup')), race_val) ;  
            tbl_single_race     = tbl(raceIdx,{'DateOfDeath', 'CumulativeDeaths', 'population'});    
            
            % Genearate new variables
            tbl_single_race.deaths = [nan; diff(tbl_single_race.CumulativeDeaths)];                       
            tbl_single_race.deaths = movmean(tbl_single_race.deaths, 7);           
            tbl_single_race.death_pctof_racepop = 100.*(tbl_single_race.deaths./tbl_single_race.population);            
            
            % convert to tt and rename vars
            tt_single_race      =  table2timetable(tbl_single_race, 'RowTimes', 'DateOfDeath');
            tt_single_race = renamevars(tt_single_race, 'deaths', 'deaths');
            tt_single_race = renamevars(tt_single_race, 'death_pctof_racepop', 'death_pctof_racepop');
            
            
            % Add race tags to vars
            vars_names_tagged   = C.tagvarnames(tt_single_race, race_tag);
            tt_single_race.Properties.VariableNames = vars_names_tagged;

            % Append
            tt_single_race      = sortrows(tt_single_race);
            tt = synchronize(tt, tt_single_race);            
            
         end

        
         
         % ORIGINAL
         TT_deaths = retime(tt, 'daily', 'previous');
         TT_tier = C.impcsv_county_unique_tier('san francisco');
         TT_death_and_tier = synchronize(TT_deaths,TT_tier);

         % NOTE: joining table leaves dates where there are no tiers. these
         % dates are assumed to have 'no tiers', which are defined as tier 5, the
         % a tier above the highest tier (4)
         TT_death_and_tier.tier_status ( isnan(TT_death_and_tier.tier_status) ) = 5;
         TT_death_and_tier.tier_decrease = [0; diff( TT_death_and_tier.('tier_status') ) <0];
         TT_death_and_tier.tier_increase = [0; diff( TT_death_and_tier.('tier_status') ) >0];      



         if ~isregular(TT_death_and_tier)
             error('LUIS')
         end


         % NOTE: SAVE AS CSV, This tt table does not contain R vairbale. 
         fname_tt_without_R   = sprintf(C.fname_tt_sanfrancisco_format, C.fname_tag_epistem_notadded );            
         writetimetable(TT_death_and_tier, fname_tt_without_R);




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



%% ANALYSIS 
    function ANZ_effect_of_npi_STA(tt_all_race, y_var_name, event_times_list, options)
    %% - - - EFFECT OF NPIs ON change in outcomes
    arguments
        tt_all_race
        y_var_name = 'case_daily'
        event_times_list = []
        options.event_description = {}
    end
    %% - - - - - - Initialize
    C = csvimporter;

    time_stamps             = tt_all_race.Time;
    time_stamps_numberof    = numel(time_stamps);
    var_names               = tt_all_race.Properties.VariableNames(contains(tt_all_race.Properties.VariableNames ,y_var_name));
    var_names_sorted        = sort(var_names);
    var_names_numof         = numel(var_names_sorted);
    
    tt_R = tt_all_race(:, var_names_sorted);

    
    npi_events_number_of = numel(event_times_list);
    
    figure(1)
    clf;    
    
    days_post_event_num  = 15;
    days_post_event     = days(days_post_event_num);
     
    %% - - - - - - ORIGINAL 
    dim_race = 2;
    dim_event = 3;

    %% - - - - - - NPI triggered average: true events    
    V   = [];
    dR  = [];
    
    
    for evt_idx = 1:npi_events_number_of
        npi_event_date  = event_times_list(evt_idx);
        
        tau_window  = npi_event_date:...
            days(1):...
            npi_event_date + days_post_event;
        
        V = tt_R(tau_window,:).Variables ;
        
         dR(:,:,evt_idx) = (V - V(1,:));
        
        
    end
    
    
    % COMBINE DATA
    dR_events_pancake_race = squeeze(nanmean(dR, dim_race));
    dR_races_pankake_events = squeeze(nanmean(dR, dim_event));
    
    dR_pancake_race_and_events = squeeze( nanmean(nanmean(dR,dim_race),dim_event) ) ;
    dR_pancake_race_and_events_std = nanstd(nanmean(dR,dim_race),0,dim_event);
    
    
    %% - - - - - - Plot the temporal response of Y to each event X. Ignore races.    
    figure(1)
    clf

    x = [0:days_post_event_num]';
    
    
    for i = 1:npi_events_number_of
        nexttile
        y_data_dR       = dR_events_pancake_race(:,i);
        
        plot(x, y_data_dR, 'LineWidth', 6)   
        set(gca, 'XLim', [min(x), max(x)]) 
        
        title_string = sprintf('%s\nt=[%s]', y_var_name, event_times_list(i));
        if ~isempty(options.event_description)
            event_string = options.event_description{i};
            title_string = sprintf('%s\n(%s)', title_string, event_string);
        end
        title(title_string, 'Interpreter', 'none', 'FontSize', 8)
        drawnow
    end
    
 
    %% - - - - - - Plot the temporal response of Y each race. Ignore Event.
    
    dR_races_pankake_events = log(dR_races_pankake_events + .001 - min(dR_races_pankake_events) );
    
    figure(2)
    clf
    
    subplot(2,1,1)
%     y_data      = dR_pancake_race_and_events;
%     plot(x, y_data, 'LineWidth', 15,'LineStyle', '-', 'Color', [0,0,0. .25])
%     hold on
    
     
     

    for i = 1:var_names_numof
        y_data      = dR_races_pankake_events(:,i);
        plot(x, y_data, 'LineStyle', ':', 'LineWidth', 5)
        
        hold on;
        xlabel('Days before/after npi')
        ylabel(sprintf('%s', y_var_name), 'Interpreter', 'none')
    end
    
    legend([var_names_sorted], 'Interpreter', 'none')
            
    subplot(4, 2, 5)
    cla
    
    bar(categorical(var_names_sorted), ...
        mean(dR_races_pankake_events),...
        'FaceColor', [0,0,0], 'FaceAlpha', .25, 'EdgeAlpha', .25); hold on
    
    
    sr = std(dR_races_pankake_events)/sqrt(size(dR_races_pankake_events,1));
    errorbar(categorical(var_names_sorted),...
        mean(dR_races_pankake_events),...
        sr,...
        'o', 'Color', [0,0,0. .25]);            
    
    
    
    set(gcf, 'WindowStyle', 'Docked');    
    
    
    anova1(dR_races_pankake_events)
    set(gca, 'XTickLabel',  categorical(var_names_sorted))
    
    set(gcf, 'WindowStyle', 'Docked');    
    
    
end

end
    
    
    
    
    
    
end
    
