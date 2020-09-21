convert_to_survey <- function(pums_data){
  
  pums_data <- 
    pums_data %>% 
    tidycensus::to_survey(
      df = ., 
      type = 'person', 
      design = 'rep_weights'
    )
  
  
}

# pums_survey <- 
#   convert_to_survey(pums_data = pums_df)
# 
# 
# 
# library(srvyr)
# 
# 
# pums_survey %>% 
#   survey_count(PUMA, oy_flag)
