# script to download PUMS data with variables of interest

load_configuration_file <- function(file_name){
  
  yaml::read_yaml(
    here::here(
      'configuration_files', 
      file_name
    )
  )
  
  
}

load_functions <- function(file_name){
  
  source(
    here::here(
      'functions', 
      file_name
    )
  )
  
}

get_api_key <- function(){
  
  config <- load_configuration_file('census_api_key.yaml')
  
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
    load_configuration_file('pums_variables.yaml')
  
  return(config$PUMS_variables)
  
}

check_for_directory <- function(dir_name){
  
  if(dir.exists(here::here(dir_name)) == FALSE){
    
    dir.create(here::here(dir_name))
    
  }else{
    message(
      paste0(dir_name, ' directory already exists.')
    )
  }
  
}


# RUN FUNCTIONS -----------------------------------------------------------

# load_api_key()

load_functions('load_data_functions.R')

check_for_directory('raw_data')

if(
  file.exists(here::here('raw_data', 
               'il_pums_data.csv')) == TRUE){
  
  message("Illinois PUMS dataset already exists.")
  
  pums_df <- load_data$load_pums_data()

}else{
  
  load_api_key()
  
  message("Illinois PUMS dataset does not exist. Downloading.")
  
  pums_df <- load_data$download_pums_data()
  
  write_csv(
    x = pums_df, 
    path = 
      here::here('raw_data', 
                 'il_pums_data.csv')
  )
}
  




