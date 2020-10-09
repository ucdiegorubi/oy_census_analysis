
process_map_data <- function(data, names, values){
  
  # data is wthe data to join
  # default is to plot for illinois and join by puma so 
  # there should be a column called PUMA
  download_map_data <- function(state_code = "17"){
    
    file = 
      tigris::pumas(state = state_code)
    
  }

  
  prep_data <- function(){
    
    data <- 
      data %>% 
      select(PUMA, names, values) %>% 
      pivot_wider(names_from = names, 
                  values_from = values)
    
    return(data)
  }
  
  join_files <- function(){
    
    joined <- 
      tigris::geo_join(spatial_data = map_data, 
                       data_frame = pivot_data, 
                       by_sp = 'PUMACE10',
                       by_df = 'PUMA')
    
  }
  
  # RUN FUNCTIONS
  map_data <- download_map_data()
  
  pivot_data <- prep_data()
  
  joined_data <- join_files()
  
  return(joined_data)
  
  
}


