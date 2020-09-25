convert_to_survey <- function(pums_data){
  
  pums_data <- 
    pums_data %>% 
    tidycensus::to_survey(
      df = ., 
      type = 'person', 
      design = 'rep_weights'
    )
  
  
}


