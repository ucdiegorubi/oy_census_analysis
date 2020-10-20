# Diego Rubi
# Purpose:
# - generate population estimates, standard errors, and confidence intervals for 
#   visualization later on
# 

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)



# FUNCTIONS ---------------------------------------------------------------

# for a lot of these variables, we're interested in much of the same thing
# counts 
# and proportions
# 
# this is a wrapper around srvyr functions to generate those estimates
create_estimate <- function(pums_survey, ...){
  
  pums_survey %>% 
    group_by(...) %>% 
    summarize(
      n = survey_total(vartype = c('ci', 'se')), 
      percent = survey_mean(vartype = c('ci', 'se'))
    )
  
}

# for whatever reason, if I was trying to generate a point estimate on a numeric
# variable, I couldn't use survey_total so I had to have this separate
numeric_estimate <- function(pums_survey, count_col, ...){
  
  pums_survey %>% 
    group_by(...) %>% 
    summarize(
      percent = survey_mean(x = {{count_col}}, vartype = c('se', 'ci'))
    )
  
}

# RUN ---------------------------------------------------------------
message("Loading PUMS data")
pums_df <- 
  load_data$load_clean_pums()

# PREPPING PUMS DATA -----------------------------------------------------------
message("Prepping PUMS and creating survey object")

pums_df <- 
  pums_df %>% 
  mutate(
    across(
      .cols = c(oy_flag, 
                child_flag,
                age_bracket,
                alt_age_bracket,
                race_ethnicity, 
                race_alternate,
                income_bracket,
                commute_bracket,
                oy_hh_flag,
                head_hh_flag, 

                contains('label')),  
      factor))

pums_survey <- 
  convert_to_survey(pums_data = pums_df) %>% 
  # to limit to city of Chicago PUMAs
  filter(chicago_puma_flag == TRUE)




# CREATE DATA -------------------------------------------------------------
message("Creating population estimates")
analysis_data <- 
  list()

# this will likely get huge at some point - 9/29/2020
# it got huge 10/14/2020
analysis_data$q1_demographics <- 
  list(
    
    total_population_age_bracket = 
      pums_survey %>% 
      create_estimate(pums_survey = ., age_bracket),
    
    total_oy_population = 
      pums_survey %>% 
      filter(oy_flag != "everyone_else") %>% 
      create_estimate(pums_survey = ., oy_flag),
    
    puma_oy_population = 
      pums_survey %>% 
      create_estimate(pums_survey = ., PUMA, oy_flag),
    
    oy_disability = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, DIS_label), 
    
    oy_sex = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, SEX_label), 
  
    
    oy_race = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, race_ethnicity), 
    
    oy_race_alternate = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, race_alternate),
    
    oy_age_brackets = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, age_bracket), 
    
    oy_alt_age_bracket = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, alt_age_bracket),
    
    oy_race_gender = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, race_ethnicity, SEX_label), 
    
    oy_edu_attainment = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, SCHL_label),
    
    oy_race_gender_alternate = 
      pums_survey %>% 
      create_estimate(pums_survey = ., oy_flag, race_alternate, SEX_label) 
    
  )

analysis_data$q1_demographics$geo_puma_pop =
  
  process_map_data(data = analysis_data$q1_demo$puma_oy_population,
                   names = 'oy_flag',
                   values = 'n') %>%
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>%
  filter(chi_puma)

# HOUSEHOLD STRUCTURE QUESTION --------------------------------------------

tabulate_dict <- 
  Dict::dict(
    "PARTNER_label" = "partnered", 
    "SCHL_label"    = "edu_attained", 
    "FS_label"      = "food_stamps",  
    "MAR_label"     = "married", 
    "HHL_label"     = "hh_language", 
    "HHT_label"     = "hh_type", 
    "JWTR_label"    = "transportation_mode", 
    "MIG_label"     = "migration",   
    "MULTG_label"   = 'multigen', 
    "income_bracket"= "income_bracket",
    # "NOC"           = "num_children",
    # "NP"            = "num_people",
    "SSMC_label"    = 'same_sex_married', 
    "TYPE_label"    = 'hh_type', 
    "WIF_label"     = 'workers_in_fam', 
    "ESP_label"     = 'parental_employment', 
    "child_flag"    = "children", 
    'commute_bracket' = "commute_bracket"
  )


# original that is only concerned with the various OY groups 
analysis_data$q2_household = 
  
  rlang::syms(tabulate_dict$keys) %>% 
  map(.x = ., 
      .f = ~ create_estimate(pums_survey,oy_flag, !!.x)) %>% 
  set_names(nm = tabulate_dict$values)

# variant that parses out the above by head of household
# oy_hh_flag is the head of household for the various OY-groups
analysis_data$q2_household = 
  append(analysis_data$q2_household, 
         
         rlang::syms(tabulate_dict$keys) %>% 
           map(.x = ., 
               .f = ~ create_estimate(pums_survey, oy_hh_flag, !!.x)) %>% 
           set_names(nm = paste0('hh_',tabulate_dict$values)))

# head of household overall
analysis_data$q2_household$head_of_household = 
  
  create_estimate(pums_survey = pums_survey, oy_hh_flag)

analysis_data$q2_household$head_of_household_alt = 
  create_estimate(pums_survey = pums_survey, 
                  oy_flag, oy_hh_flag)
  

analysis_data$q2_household$puma_head_of_household = 
  
  create_estimate(pums_survey = pums_survey, 
                  PUMA, 
                  oy_hh_flag)

analysis_data$q2_household$geo_head_of_household_n = 
  
  process_map_data(data = analysis_data$q2_household$puma_head_of_household,
                   names = 'oy_hh_flag',
                   values = 'n') %>%
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>%
  filter(chi_puma)

analysis_data$q2_household$geo_head_of_household_percent = 
  
  process_map_data(data = analysis_data$q2_household$puma_head_of_household, 
                   names = 'oy_hh_flag', 
                   values = 'percent') %>% 
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>% 
  filter(chi_puma)


# NUMERIC ESTIMATES -------------------------------------------------------


# can't use these within a survey_count() call, so I had to make a serparate function
# as defined above
numeric_cols <- 
  Dict::dict("adjusted_income" = "average_income", 
             'NOC' = "num_children", 
             'NP'= "number_of_people", 
             "JWMNP" = "travel_time_to_work")

analysis_data$q2_household <- 
  append(analysis_data$q2_household, 
         
         rlang::syms(numeric_cols$keys) %>% 
           map(.x = ., 
               .f = ~ numeric_estimate(pums_survey = pums_survey, 
                                     count_col = !!.x, 
                                     oy_flag)) %>% 
           set_names(nm = numeric_cols$values))

analysis_data$q2_household = 
  append(analysis_data$q2_household, 
         rlang::syms(numeric_cols$keys) %>% 
           map(.x = ., 
               .f = ~ numeric_estimate(pums_survey = pums_survey, 
                                       count_col = !!.x, 
                                       oy_hh_flag)) %>% 
           set_names(nm = paste0('hh_',numeric_cols$values)))




# SAVING DICTIONARIES -----------------------------------------------------
message("Saving dictionaries")
analysis_data$q2_dictionary_qual = tabulate_dict
analysis_data$q2_dictionary_numeric = numeric_cols



# WRITE DATA --------------------------------------------------------------
message("Writing analysis data")
helper_functions$check_for_directory('analysis_data')


readr::write_rds(x = analysis_data, 
                 path = 
                   here::here(
                     'analysis_data', 
                     'oy_population_estimates.RDS'
                   ))







