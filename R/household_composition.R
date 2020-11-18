
# TYPE OF PEOPLE IN A HOUSEHOLD -------------------------------------------
# on average, how many members of each type are in an OY household?
# percent oy, percent connected youth, percent everyone else
analysis_data$hh_composition <- 
  pums_survey %>% 
  group_by(oy_household_full, oy_flag) %>% 
  summarize(
    n = survey_total(vartype = c('se','ci')), 
    percent = survey_mean(vartype = c('se','ci'))
  )

# NUMBER OF PEOPLE IN A HOUSEHOLD -----------------------------------------
analysis_data$num_people_lived_with <- 
  pums_hh_survey %>% 
  group_by(oy_household_full) %>% 
  summarize(
    percent = survey_mean(NP, vartype = c('se','ci'))
  )
# num_people_lived_with %>% 
#   ggplot(aes(x = oy_household, y = percent)) + 
#   geom_col(fill = "#D65177") + 
#   geom_errorbar(aes(ymin = percent_low, ymax = percent_upp), 
#                 width = .2) + 
#   geom_text(aes(y = percent_upp + .15
#                 , label = format(percent, digits = 2)), 
#             vjust = 1.25) + 
#   theme_classic() + 
#   labs(y = "Average Household Size", 
#        x = "Type of Household")



# MULTIGENERATIONAL HOUSEHOLD ---------------------------------------------
analysis_data$multigenerational_household <- 
  pums_hh_survey %>% 
  group_by(oy_household_full, MULTG_label) %>% 
  summarize(
    percent = survey_mean(vartype = c('se','ci'))
  )
