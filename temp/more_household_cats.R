pums_df <- load_data$load_clean_pums()

categorize_oy_households <- function(pums_data){
  
  spread_oy_flag <- function(){
    
    out <- 
      pums_data %>% 
      group_by(SERIALNO) %>% 
      count(oy_flag) %>% 
      pivot_wider(names_from = oy_flag, values_from = n) %>% 
      ungroup()
    
    return(out)
    
  }
  
  generate_household_categories <- function(wide_data){
    
    wide_data <- 
      
      wide_data %>% 
      mutate(
        oy_household = 
          # there are potentially 8 kinds of households
          # depending on existence of at least one everyone_else, 
          # one opp_youth, one connected youth
          # 2 ^ 3 = 8, but all people are categorized so the house
          # with none does not exist
          case_when(
            # oy_only
            # !is.na(opp_youth) & 
            #   is.na(connected_youth) & 
            #   is.na(everyone_else)                      ~"OY Only Household", 
            #   
            # oy cy only - keep
            !is.na(opp_youth) & 
              !is.na(connected_youth) & 
              is.na(everyone_else)                      ~ "OY-CY Only Household", 
            
            # # oy ee only
            # !is.na(opp_youth) & 
            #   is.na(connected_youth) & 
            #   !is.na(everyone_else)                     ~ "OY-EE Only Household", 
            
            # Connected Youth Only - keep
            !is.na(connected_youth) & 
              is.na(opp_youth) & 
              is.na(everyone_else)                      ~ "CY Only Household",
            
            # Connected Youth w/ EE - keep
            is.na(opp_youth) & 
              !is.na(connected_youth) & 
              !is.na(everyone_else)                     ~ "CY EE Only Household", 

            # everyone_else only- keep
            !is.na(everyone_else) & 
              is.na(connected_youth) & 
              is.na(opp_youth)                          ~ "EE Only Household", 
            

            TRUE                                        ~ "OY Household")) %>% 
      select(SERIALNO, oy_household)
    
    return(wide_data)
    
  }
  
  generate_complete_household_categories <- function(wide_data){
    
    wide_data <- 
      
      wide_data %>% 
      mutate(
        oy_household_full = 
          # there are potentially 8 kinds of households
          # depending on existence of at least one everyone_else, 
          # one opp_youth, one connected youth
          # 2 ^ 3 = 8, but all people are categorized so the house
          # with none does not exist
          case_when(
            # oy_only
            !is.na(opp_youth) &
              is.na(connected_youth) &
              is.na(everyone_else)                      ~"OY Only Household",
            #   
            # oy cy only - keep
            !is.na(opp_youth) & 
              !is.na(connected_youth) & 
              is.na(everyone_else)                      ~ "OY-CY Only Household", 
            
            # oy ee only
            !is.na(opp_youth) &
              is.na(connected_youth) &
              !is.na(everyone_else)                     ~ "OY-EE Only Household",
            
            # Connected Youth Only - keep
            !is.na(connected_youth) & 
              is.na(opp_youth) & 
              is.na(everyone_else)                      ~ "CY Only Household",
            
            # Connected Youth w/ EE - keep
            is.na(opp_youth) & 
              !is.na(connected_youth) & 
              !is.na(everyone_else)                     ~ "CY EE Only Household", 
            
            # everyone_else only- keep
            !is.na(everyone_else) & 
              is.na(connected_youth) & 
              is.na(opp_youth)                          ~ "EE Only Household", 
            
            # Non-oy Household
            !is.na(opp_youth)                           ~ "Combined Household",
            
            
            TRUE                                        ~ "Other Household")) %>% 
      select(SERIALNO, oy_household_full)
    
    return(wide_data)
    
  }
  
  # Run Functions
  message("Tabulating Person-type per household")
  wide_data <- spread_oy_flag()
  message("Categorizing households")
  
  short <- generate_household_categories(wide_data = wide_data)
  full <- generate_complete_household_categories(wide_data = wide_data)
  
  # join the two together
  message("Joining Data")
  pums_data <-
    pums_data %>%
    left_join(.,
              y = short,
              by = 'SERIALNO') %>%
    left_join(.,
              y = full,
              by = 'SERIALNO')


  return(pums_data)
  
}

test <- categorize_oy_households(pums_df)

test <- test %>% ungroup()

test <- 
  test %>% 
  group_by(SERIALNO) %>% 
  mutate(
    household_size = sum(everyone_else, connected_youth, opp_youth, na.rm = TRUE)
  )



test %>% 
  group_by(oy_household) %>% 
  summarize(n = mean(household_size))



test %>% 
  group_by(oy_household) %>% 
  summarize(
    everyone_else = any(!is.na(everyone_else)), 
    connected_youth = any(!is.na(connected_youth)), 
    opp_youth = any(!is.na(opp_youth))
  )


pums_df %>% filter(oy_household == "oy_cy_household")



test %>% count(oy_household, sort = TRUE)

blah <- 
  test %>% 
  group_by(oy_household_full) %>% 
  count(oy_flag) %>% 
  spread(oy_flag, n)

num <- test %>% 
  distinct(SERIALNO, .keep_all = TRUE) %>% 
  count(oy_household_full)


blah %>% 
  left_join(num) %>% 
  arrange(-n)


blah %>%  
  ungroup() %>% 
  mutate(
    connected_youth = !is.na(connected_youth), 
    everyone_else   = !is.na(everyone_else), 
    opp_youth       = !is.na(opp_youth))



format_oy_household = function(oy_household){
  
  households <- 
    c("Non-OY Household", 
      "OY & CY Household", 
      "OY Household", 
      "CY Only Household")
  
  oy_household <- 
    case_when(
      oy_household == "non_oy_household" ~ households[1], 
      oy_household == "oy_cy_household"  ~ households[2], 
      oy_household == "oy_household"     ~ households[3], 
      oy_household == "cy_only_household"~ households[4]
    )
  
  oy_household <-  
    factor(
      oy_household, 
      levels = c(households[1], 
                 households[2],
                 households[4],
                 households[3]), 
      ordered = TRUE)
  
  return(oy_household)
}
