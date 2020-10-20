
helper_functions <- 
  list(
    
    
    load_configuration_file = function(file_name){
      
      yaml::read_yaml(
        here::here(
          'configuration_files', 
          file_name
        )
      )
      
      
    }, 
    
    load_functions = function(file_name){
      
      source(
        here::here(
          'functions', 
          file_name
        )
      )
      
    }, 
    
    check_for_directory = function(dir_name){
      
      if(dir.exists(here::here(dir_name)) == FALSE){
        
        dir.create(here::here(dir_name))
        message(
          paste0("Creating directory: ", dir_name)
        )
        
      }else{
        message(
          paste0(dir_name, ' directory already exists.')
        )
      }
      
    }
    
  )


convert_to_survey <- function(pums_data){
  
  pums_data <- 
    pums_data %>% 
    tidycensus::to_survey(
      df = ., 
      type = 'person', 
      design = 'rep_weights'
    )
  
  
}