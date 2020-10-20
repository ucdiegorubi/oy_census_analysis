# Diego Rubi
# Purpose:
#   Add various indicators for:
#     - Opportunity Youth
#     - Chicago PUMAs

# load libraries
# Loads all functions from the functions folder

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)

# LOAD DATA ---------------------------------------------------------------
pums_df <- 
  load_data$load_pums_data()


# RUN FUNCTIONS -----------------------------------------------------------
# functions found in R scripts of same name
# i.e., identify_opportunity_youth() is in identify_opportunity_youth.R
# recategorize_race and add_other_indicators found in pums_indicators.R
# 
pums_df <- 
  identify_opportunity_youth(pums_data = pums_df)

pums_df <- 
  identify_chicago_pumas(pums_data = pums_df)

pums_df <- 
  recategorize_race(pums_data = pums_df)

pums_df <- 
  add_other_indicators(pums_data = pums_df)


# WRITE DATA --------------------------------------------------------------

helper_functions$check_for_directory('clean_data')

readr::write_csv(
  x = pums_df, 
  path = 
    here::here(
      'clean_data', 
      'il_pums_data_clean.csv'
    )
)

         