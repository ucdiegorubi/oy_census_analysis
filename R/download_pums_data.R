# script to download PUMS data with variables of interest
# load libraries
# load config


# SETUP -------------------------------------------------------------------
message("Loading Scripts and Config")

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)

pums_config <- helper_functions$load_configuration_file('pums_parameters.yaml')



# FUNCTIONS ---------------------------------------------------------------

message("Defining Functions")

get_api_key <- function(){
  
  config <- helper_functions$load_configuration_file('census_api_key.yaml')
  
  api_key = config$census_api_key
  
  return(api_key)
}

load_api_key <- function(){
  
  api_key <- get_api_key()
  
  tidycensus::census_api_key(
    key = api_key
  )
  
}

get_pums_variables <- function(){
  
  config <- 
    helper_functions$load_configuration_file('pums_variables.yaml')
  
  config$PUMS_variables <- unique(stringr::str_to_upper(config$PUMS_variables))
  
  return(config$PUMS_variables)
  
}

check_pums_variables <- function(){
  
  # variables that we're interested in 
  pums_vars = get_pums_variables()
  
  # variables available in PUMS files through tidycensus for the file 
  # we're interested in
  vars_available = 
    tidycensus::pums_variables %>% 
    filter(
      year == pums_config$year, 
      survey == pums_config$survey) %>% 
    pull(var_code) %>% 
    unique()
  
  # which are in which?
  test <- pums_vars %in%  vars_available
  
  # return the variables that don't exist in the catalogue
  incorrect_variables <- pums_vars[which(test == FALSE)]
  
  if(any(test == FALSE)){
    
    message("One or more variables are incorrect")
    print(incorrect_variables)
    
  } else{
    message("All variables are correct")
  }
  
}


# RUN FUNCTIONS -----------------------------------------------------------

# helper_functions$load_functions('load_data_functions.R')

# making sure raw data directory exists
# kind of unnecessary now
helper_functions$check_for_directory('raw_data')

# making sure the variables in the variable config are actually part of the avaialble
# variables based on tidycensus::pums_variables (a dataframe)
check_pums_variables()

# this is really not the best way to do this
# but extracts API key from the configuration file and loads it prior to making the 
# api call to the Census
load_api_key()

message("Downloading PUMS data")
pums_df <- load_data$download_pums_data(state_config = pums_config$state, 
                                        year_config = pums_config$year, 
                                        survey_config = pums_config$survey,
                                        recode_config = pums_config$recode,
                                        rep_weight_config = pums_config$rep_weights)


# WRITE DATA --------------------------------------------------------------


write_csv(
  x = pums_df, 
  path = 
    here::here('raw_data', 
               'il_pums_data.csv')
)

  




