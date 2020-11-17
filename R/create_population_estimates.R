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
                school_attainment,
                oy_household,
                oy_household_full,
                PUMA_region,

                contains('label')),  
      factor))


# CREATING SURVEY OBJECTS -------------------------------------------------
# creating two survey objects - one is person level and uses the person level replicate
# weights while the other is household level. The household level survey needs to be
# one row per household (SERIALNO in pums_df) hence the distinct() call. 

## FOR PERSON-LEVEL ESTIMATES
pums_survey <- 
  convert_to_survey(pums_data = pums_df) %>% 
  # to limit to city of Chicago PUMAs
  filter(chicago_puma_flag == TRUE)

# FOR HOUSEHOLD-LEVEL ESTIMATES
pums_hh_survey <-
  pums_df %>%
  filter(chicago_puma_flag) %>% 
  distinct(SERIALNO,.keep_all = TRUE) %>% 
  to_survey(df = .,
            type = 'housing',
            class = 'srvyr',
            design = 'rep_weights')




# CREATE DATA -------------------------------------------------------------
message("Creating population estimates")
analysis_data <- 
  list()

# this will likely get huge at some point - 9/29/2020
# it got huge 10/14/2020
# All the variables in this section are person level estimates, so these tabulations
# are valid since they use the person level weights to create standard error estimates 
# and confidence intervals. For the set of housing questions below, not all variables 
# are at the person level so the standard errors are incorrectly specified using the person
# level weights. 
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
      filter(oy_flag != "everyone_else") %>% 
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
      create_estimate(pums_survey = ., oy_flag, school_attainment),
    
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

analysis_data$q1_demographics$geo_puma_pop_percent = 
  
  process_map_data(data = analysis_data$q1_demo$puma_oy_population,
                   names = 'oy_flag',
                   values = 'percent') %>%
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>%
  filter(chi_puma)

# HOUSEHOLD STRUCTURE QUESTION --------------------------------------------
# I've noted which variables are housing level / person level. Unfortunately, I did not
# specify the correct replicate weights (need housing) to generate standard erorrs 
# for some of these variables, so the ones that are housing level will be incorrect 
# estimates. We're not using that yet until I figure that out. 

tabulate_dict <- 
  Dict::dict(
    # housing level
    "PARTNER_label" = "partnered", 
    # person level
    "SCHL_label"    = "edu_attained", 
    # housing level
    "FS_label"      = "food_stamps", 
    # housing level
    "MAR_label"     = "married", 
    # housing level
    "HHL_label"     = "hh_language", 
    # housing level
    "HHT_label"     = "hh_type", 
    # person level
    "JWTR_label"    = "transportation_mode", 
    # person level
    "MIG_label"     = "migration",   
    # housing level
    "MULTG_label"   = 'multigen', 
    # person level
    "income_bracket"= "income_bracket",
    # housing level
    "SSMC_label"    = 'same_sex_married', 
    
    # type of living quarters/ housing
    "TYPE_label"    = 'hh_type', 
    # housing level
    "WIF_label"     = 'workers_in_fam',
    # housing level
    "ESP_label"     = 'parental_employment', 
    # housing level
    "child_flag"    = "children", 
    # person level
    'commute_bracket' = "commute_bracket"
  )


# original that is only concerned with the various OY groups
# basically what I'm doing here is using the dictionary keys (which are column names in
# pums_df) and passing them through to create_estimate. The columns are referenced 
# in !!.x, so basically each estimate says that for each group in oy_flag, generate 
# the total count / proportion of people in column PARTNER_label, SCHL_label, so on and
# so forth. 
analysis_data$q2_household = 
  
  rlang::syms(tabulate_dict$keys) %>% 
  
  map(.x = ., 
      .f = ~ create_estimate(pums_survey,oy_flag, !!.x)) %>% 
  set_names(nm = tabulate_dict$values)

# head of household overall
analysis_data$q2_household$head_of_household = 
  
  create_estimate(pums_survey = pums_survey, oy_hh_flag)

# for some reason it was not grouping by head of household to parse that out within
# oy_flag groups, so i had to be explicit here
analysis_data$q2_household$head_of_household_alt = 
  create_estimate(pums_survey = pums_survey, 
                  oy_flag, oy_hh_flag)
  

# calculating the heads of household per PUMA to later join to a map
analysis_data$q2_household$puma_head_of_household = 
  
  create_estimate(pums_survey = pums_survey, 
                  PUMA, 
                  oy_hh_flag)

# auto join to a map
analysis_data$q2_household$geo_head_of_household_n = 
  
  process_map_data(data = analysis_data$q2_household$puma_head_of_household,
                   names = 'oy_hh_flag',
                   values = 'n') %>%
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>%
  filter(chi_puma)

# same thing, but with percentages / not sure if this is per capita for a PUMA though
# so I'm not doing anything with this data just yet
analysis_data$q2_household$geo_head_of_household_percent = 
  
  process_map_data(data = analysis_data$q2_household$puma_head_of_household, 
                   names = 'oy_hh_flag', 
                   values = 'percent') %>% 
  mutate(chi_puma = PUMACE10 %in% pums_df$PUMA[pums_df$chicago_puma_flag]) %>% 
  filter(chi_puma)



# NUMERIC ESTIMATES -------------------------------------------------------
# same thing, some of these are housing level, so ignore those estimaets. 

# can't use these within a survey_count() call, so I had to make a serparate function
# as defined above
numeric_cols <- 
  
  Dict::dict(
    # person level
    "adjusted_income" = "average_income", 
    # housing level
    'NOC' = "num_children", 
    # housing level
    'NP'= "number_of_people", 
    # person level
    "JWMNP" = "travel_time_to_work")

analysis_data$q2_household <- 
  append(analysis_data$q2_household, 
         
         rlang::syms(numeric_cols$keys) %>% 
           map(.x = ., 
               .f = ~ numeric_estimate(pums_survey = pums_survey, 
                                     count_col = !!.x, 
                                     oy_flag)) %>% 
           set_names(nm = numeric_cols$values))

analysis_data$oy_personal_median_income <- 
  pums_survey %>% 
  group_by(oy_flag) %>% 
  summarize(
    percent = survey_median(adjusted_income)
  ) %>% 
  mutate(percent_upp = percent + (1.96 * percent_se), 
         percent_low = percent - (1.96 * percent_se))

analysis_data$question_2$travel_time_to_work <- 
  # we want to omit students connected youth that are attending school
  pums_survey %>% 
  filter(!(oy_flag == "connected_youth" & school_label == "Not Attending School")) %>% 
  numeric_estimate(pums_survey = ., 
                   count_col = !!(rlang::sym("JWMNP")), 
                   oy_flag)

  
analysis_data$question_2$transportation_mode <- 
  pums_survey %>% 
  filter(!(oy_flag == "connected_youth" & school_label == "Not Attending School")) %>% 
  create_estimate(pums_survey = ., 
                  oy_flag, 
                  JWTR_label)
  
  
  


# HOUSEHOLD ESTIMATES -----------------------------------------------------

analysis_data$household_income_estimates <- 
  pums_hh_survey %>% 
  group_by(oy_household_full) %>% 
  summarize(
    percent = survey_mean(HINCP, vartype = c('se', 'ci'))
  )

analysis_data$household_type <- 
  pums_hh_survey %>% 
  group_by(oy_household_full) %>% 
  summarize(
    percent = survey_mean(vartype = c('se','ci')), 
    n = survey_total(vartype = c('se','ci'))
  ) 

##

analysis_data$chicago_household_income <- 
  pums_hh_survey %>% 
  summarize(
    percent = survey_mean(HINCP, vartype = c("se", "ci"))
  )

analysis_data$household_chart <- 
  pums_survey %>% 
  
  group_by(oy_household_full) %>% 
  survey_count(oy_flag) %>% 
  select(-n_se) %>% 
  spread(oy_flag, n)

analysis_data$household_chart_percent <- 
  pums_survey %>% 
  group_by(oy_household_full, oy_flag) %>% 
  summarize(
    percent = survey_mean()
  ) %>% 
  select(-percent_se) %>% 
  spread(oy_flag, percent)

# calling this percent but only because ive got plotting functions relying on 
# percent being a column
analysis_data$chicago_household_median_income <- 
  pums_hh_survey %>% 
  # group_by(oy_household) %>% 
  summarize(percent = survey_median(HINCP)) %>% 
  mutate(percent_upp = percent + (1.96 * percent_se), 
         percent_low = percent - (1.96 * percent_se))


analysis_data$household_type_median_income <- 
  pums_hh_survey %>% 
  group_by(oy_household_full) %>% 
  summarize(percent = survey_median(HINCP)) %>% 
  mutate(percent_upp = percent + (1.96 * percent_se), 
         percent_low = percent - (1.96 * percent_se))

analysis_data$household_type_full_median_income <- 
  pums_hh_survey %>% 
  group_by(oy_household_full) %>% 
  summarize(percent = survey_median(HINCP)) %>% 
  mutate(percent_upp = percent + (1.96 * percent_se), 
         percent_low = percent - (1.96 * percent_se))



# NEW ESTIMATES -----------------------------------------------------------
# 11/17/2020
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


analysis_data$HISPEED_internet <- 
  pums_hh_survey %>% 
  group_by(oy_household_full, HISPEED_label) %>% 
  summarize(percent = survey_mean(vartype = c('se', 'ci')), 
            n = survey_total(vartype = c('se','ci')))

analysis_data$LAPTOP <- 
  
  pums_hh_survey %>% 
  create_estimate(pums_survey = ., 
                  oy_household_full, HISPEED_label)


# HOUSEHOLD COMPOSITION 11/17/2020 ----------------------------------------

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


# GEOGRAPHIC ESTIMATES ----------------------------------------------------
# 11/17/2020
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







