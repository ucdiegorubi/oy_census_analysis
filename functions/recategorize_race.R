recategorize_race <- function(pums_data){
  
  pums_data <- 
    
    pums_data %>% 
    
    mutate(race_ethnicity = 
             case_when(
               RAC1P == "1" ~ "White alone",
               RAC1P == "2" ~ "Black or African American alone",
               RAC1P == "3" ~ "American Indian alone",
               RAC1P == "4" ~ "Alaska Native alone",
               RAC1P == "5" ~ "American Indian and Alaska Native tribes specified",
               RAC1P == "6" ~ "Asian alone",
               RAC1P == "7" ~ "Native Hawaiian and Other Pacific Islander alone",
               RAC1P == "8" ~ "Some Other Race alone",
               RAC1P == "9" ~ "Two or More Races"),
           race_ethnicity = if_else(HISP != "01","Hispanic",race_ethnicity))
  
  
  pums_data <- 
    pums_data %>% 
    mutate(
      race_alternate = 
        case_when(
          RAC1P == "1" & HISP == "01" ~ "White Non-Hispanic", 
          RAC1P == "2" & HISP == "01" ~ "Black Non-Hispanic", 
          RAC1P == "6" & HISP == "01" ~ "Asian Non-Hispanic", 
          HISP != "01"                ~ "Hispanic or Latino", 
          TRUE                        ~ "All Other Races"
          
          
        )
    )
  
  return(pums_data)
  
}


