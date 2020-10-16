# script to download PUMS data with variables of interest
# library(here)

source(
  here::here(
    'R', 
    'script_setup.R'
  )
)

# SETUP -------------------------------------------------------------------



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
  
  # variables available in PUMS files through tidycensus
  vars_available = tidycensus::pums_variables$var_code %>% unique()
  
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

helper_functions$load_functions('load_data_functions.R')

helper_functions$check_for_directory('raw_data')

check_pums_variables()

# if(
#   file.exists(here::here('raw_data', 
#                'il_pums_data.csv')) == TRUE){
#   
#   message("Illinois PUMS dataset already exists.")
#   
#   pums_df <- load_data$load_pums_data()
# 
# }else{

load_api_key()

message("Illinois PUMS dataset does not exist. Downloading.")

pums_df <- load_data$download_pums_data()

write_csv(
  x = pums_df, 
  path = 
    here::here('raw_data', 
               'il_pums_data.csv')
)

  




