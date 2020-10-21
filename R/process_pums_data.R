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
  # we want to limit our analysis to only chicago
  # This uses a crosswalk for PUMAS and various geographic areas to identify the 
  # PUMAS encompassing Chicago. There are 17 of them. 
  identify_chicago_pumas(pums_data = pums_df)

# creates a new race variable that is, unfortunately, more succinct but also inclusive
# of hispanic as a value for the race variable 
# The next two functions are located in functions/pums_indicators.R
pums_df <- 
  recategorize_race(pums_data = pums_df)

# adds various other indicators
#   age
#   income brackets
#   age brackets
#   presence of at least one child
#   converts total personal income to adjusted income (constant dollars)
#   identifies head of household

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

         