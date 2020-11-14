
# EMPLOYMENT BY PUMA ------------------------------------------------------
analysis_data$employed_by_puma <- 
  pums_survey %>% 
  filter(employment_label %in% c("Employed", "Unemployed")) %>% 
  group_by(PUMA_region, PUMA, oy_flag, employment_label) %>% 
  summarize(
    n = survey_total(vartype = c('se', 'ci')), 
    percent = survey_mean(vartype = c("se", 'ci'))
  ) 

test = analysis_data$employed_by_puma

# SCHOOL ATTENDANCE BY PUMA -----------------------------------------------
analysis_data$school_youth_attendance_by_puma <- 
  pums_survey %>% 
  # filter(oy_flag != "opp_youth") %>% 
  group_by(PUMA_region, PUMA, oy_flag, school_label) %>% 
  summarize(
    n = survey_total(vartype = c("se", "ci")),
    percent = survey_mean(vartype = c("se", "ci"))
  )

analysis_data$school_youth_attendance_labels <- 
  analysis_data$school_youth_attendance_by_puma %>% 
  filter(oy_flag == "connected_youth") %>% 
  group_by(PUMA) %>% 
  summarize(
    n = sum(n)
  ) %>% 
  mutate(label = paste(PUMA, "\n","N =", format(n, big.mark = ','))) %>% 
  select(PUMA, label) %>% 
  spread(PUMA, label) %>% 
  unlist()


# MEDIAN INCOME BY PUMA ---------------------------------------------------

analysis_data$median_income_hh_by_puma <- 
  pums_survey %>% 
  group_by(PUMA_region, PUMA, oy_hh_flag) %>% 
  summarize(
    n = survey_mean(adjusted_income, vartype = c('se'))
  ) %>% 
  mutate(n_upp = n + (1.96*n_se), 
         n_low = n - (1.96*n_se))

# by puma region
analysis_data$median_income_hh_by_puma %>% 
  mutate(
    ci_upp = n + 1.96*n_se, 
    ci_low = n - (1.96*n_se)
  ) 
  # filter(!str_detect(oy_hh_flag, "Everyone")) %>% 
  # ggplot(aes(x = PUMA, y = n, fill = oy_hh_flag, group = oy_hh_flag)) + 
  # geom_col(position = 'dodge') + 
  # geom_errorbar(aes(ymin = ci_low, ymax = ci_upp), 
  #               position = position_dodge(width = 1), 
  #               width = .2) +
  # theme_classic()

# MEDIAN INCOME PUMA REGION -----------------------------------------------
# does not seem like pursuing head of household median income, disaggregated by 
# PUMA is worth it; no / few data points available and some negative values for the 
# low confidence interval boundary
analysis_data$median_income_hh_by_puma_region <- 
  pums_survey %>% 
  group_by(PUMA_region, oy_hh_flag) %>% 
  summarize(
    n = survey_mean(adjusted_income)) %>% 
  mutate(n_upp = n + (1.96*n_se), 
         n_low = n - (1.96*n_se))




