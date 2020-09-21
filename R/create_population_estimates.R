# Diego Rubi
# Take the PUMS dataset, now a survey object, and use it to generate
# population estimates and standard errors for visualization later on

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)



create_estimate <- function(...){
  
  pums_survey %>% 
    group_by(...) %>% 
    summarize(
      n = survey_total(vartype = c('se','ci'))
    )
  
}

# RUN ---------------------------------------------------------------
pums_df <- 
  load_data$load_pums_data()
  

# TEST --------------------------------------------------------------------

pums_df <- 
  pums_df %>% 
  mutate(oy_flag = factor(oy_flag))

pums_survey <- 
  convert_to_survey(pums_data = pums_df) %>% 
  # to limit to city of Chicago PUMAs
  filter(chicago_puma_flag == TRUE)



# Total Opportunity Youth Population by PUMA

analysis_data <- 
  list(
    puma_oy_population = 
      create_estimate(PUMA, oy_flag), 
    
    disab_population = 
      create_estimate(DIS_label, oy_flag), 
    
    race_population = 
      create_estimate(RAC1P_label, oy_flag)
      
  )








