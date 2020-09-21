# Diego Rubi
# Purpose:
#   Add various indicators for:
#     - Opportunity Youth
#     - Chicago PUMAs

# load libraries
source(
  here::here(
    'R', 
    'script_setup.R'
  )
)


# FUNCTIONS ---------------------------------------------------------------

add_other_indicators <- function(pums_data){
  
  create_age_brackets <- function(age_variable){
    
    # 0 not captured for some reason
    
    age_variable <- 
      cut(age_variable, 
          breaks = c(0, 16, 19, 22, 25, 100), 
          labels = c("0-16", 
                     "16-19", 
                     "20-22", 
                     "23-25", 
                     "25+"), 
          include.lowest = TRUE)
    
    return(age_variable)
    
  }
  
  
  pums_data <- 
    pums_data %>% 
    mutate(age_brackets = create_age_brackets(AGEP))
  
  return(pums_data)
  
  
}



# LOAD DATA ---------------------------------------------------------------
pums_df <- 
  load_data$load_pums_data()


# RUN FUNCTIONS -----------------------------------------------------------
pums_df <- 
  identify_opportunity_youth(pums_data = pums_df)

pums_df <- 
  identify_chicago_pumas(pums_data = pums_df)

pums_df <- 
  add_other_indicators(pums_data = pums_df)




  






