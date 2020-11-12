test <- 
  pums_df %>% 
  group_by(SERIALNO) %>% 
  count(oy_flag) %>% 
  pivot_wider(names_from = oy_flag, values_from = n) %>% 
  mutate(
    oy_household = 
      case_when(
        is.na(opp_youth)                            ~ "non_oy_household", 
        !is.na(opp_youth) & !is.na(connected_youth) ~ "oy_cy_household",
        !is.na(opp_youth) & is.na(connected_youth)  ~ "oy_household", 
        is.na(opp_youth)  & !is.na(connected_youth) ~ "cy_household",
        TRUE                                        ~ "else"))
)

test <- test %>% ungroup()

test %>% count(oy_household)

categorize_oy_households <- function(pums_data){
  
  spread_oy_flag <- function(){
    
    out <- 
      pums_data %>% 
      group_by(SERIALNO) %>% 
      count(oy_flag) %>% 
      pivot_wider(names_from = oy_flag, values_from = n)
    
    return(out)
    
  }
  
  generate_household_categories <- function(wide_data){
    
    wide_data <- 
      
      wide_data %>% 
      mutate(
        oy_household = 
          case_when(
            is.na(opp_youth)                            ~ "non_oy_household", 
            !is.na(opp_youth) & !is.na(connected_youth) ~ "oy_cy_household",
            !is.na(opp_youth) & is.na(connected_youth)  ~ "oy_household", 
            is.na(opp_youth)  & !is.na(connected_youth) ~ "cy_household",
            TRUE                                        ~ "else"))
    
    return(wide_data)
  
  }
  
  # Run Functions
  wide_data <- spread_oy_flag()
  wide_data <- generate_household_categories(wide_data = wide_data)
  
  # join the two together
  pums_data <- 
    pums_data %>% 
    left_join(., 
              y = wide_data,
              by = 'SERIALNO')
  
  
  return(pums_data)
  
  
}

pums_df %>% categorize_oy_households() %>% count(oy_household)


geo_test <- 
  
    MapChi::CAs %>% broom::tidy(id = id)

geo_test %>% 
  MapChi::convert(lat = 'lat', long = 'long' )
