# foodstamp receipt per household
analysis_data$foodstamps_per_household <- 
  pums_hh_survey %>% 
  group_by(oy_household_full, FS_label) %>% 
  summarize(
    n = survey_total(vartype = c('se', 'ci')), 
    percent = survey_mean(vartype = c('se','ci'))
  )

# Household structure per type of oy-household
analysis_data$hht = 
  pums_hh_survey %>% 
  group_by(oy_household_full, HHT_label) %>% 
  summarize(
    percent = survey_mean(vartype = c('se', 'ci')), 
    n = survey_total(vartype  = c('se','ci'))
  ) 





