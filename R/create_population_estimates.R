# Diego Rubi
# Take the PUMS dataset, now a survey object, and use it to generate
# population estimates and standard errors for visualization later on

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)



create_estimate <- function(pums_survey, ...){
  
  pums_survey %>% 
    group_by(...) %>% 
    summarize(
      n = survey_total(vartype = c('ci', 'se')), 
      percent = survey_mean(vartype = c('ci', 'se'))
    )
  
}

# RUN ---------------------------------------------------------------
pums_df <- 
  load_data$load_clean_pums()

# TEMP --------------------------------------------------------------------

pums_df <- 
  pums_df %>% 
  mutate(
    across(
      .cols = c(SEX_label, 
                DIS_label, 
                RAC1P_label, 
                oy_flag, 
                age_bracket,
                alt_age_bracket,
                race_ethnicity, 
                race_alternate), 
      factor))

pums_survey <- 
  convert_to_survey(pums_data = pums_df) %>% 
  # to limit to city of Chicago PUMAs
  filter(chicago_puma_flag == TRUE)




# CREATE DATA -------------------------------------------------------------

analysis_data <- 
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
      create_estimate(pums_survey = ., oy_flag, race_ethnicity, SEX_label)
    
  )

analysis_data$geo_puma_pop = 
  process_map_data(data = analysis_data$puma_oy_population, 
                   names = 'oy_flag', 
                   values = 'n') %>% 
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag])
  


# WRITE DATA --------------------------------------------------------------

helper_functions$check_for_directory('analysis_data')


readr::write_rds(x = analysis_data, 
                 path = 
                   here::here(
                     'analysis_data', 
                     'oy_population_estimates.RDS'
                   ))





