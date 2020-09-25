
identify_chicago_pumas <- function(pums_data){
  
  
  puma_crosswalk <- load_data$load_PUMA_crosswalk()
  
  subset_chicago_pumas <- function(){
    
    puma_crosswalk <- 
      
      puma_crosswalk %>% 
      filter(`State Name` == "Illinois", 
             str_detect(`PUMA Name`, "Chicago City")) %>% 
      pull(`PUMA Code`)
    
    return(puma_crosswalk)
  
  }
  
  puma_crosswalk <- subset_chicago_pumas()
  
  pums_data <- 
    pums_data %>% 
    mutate(
      chicago_puma_flag = 
        PUMA %in% puma_crosswalk
    )
    
  return(pums_data)
}
