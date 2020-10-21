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

add_other_indicators <- function(pums_data){
  
  create_age_brackets <- function(age_variable){
    
    # 0 not captured for some reason
    
    age_variable <- 
      cut(age_variable, 
          breaks = c(0, 15, 19, 24, 50, 100), 
          labels = c("0-15",
                     "16-19",
                     "20-24",
                     "25-50",
                     "50+"),
          include.lowest = TRUE, 
          # dig.lab = TRUE, 
          ordered = TRUE, 
          right = TRUE)
    
    return(age_variable)
    
  }
  
  alt_age_brackets <- function(age_variable){
    
    age_variable <- 
      cut(age_variable, 
          breaks = c(0, 15, 24, 50, 100), 
          labels = c("0-15",
                     "16-24",
                     "25-50",
                     "50+"),
          include.lowest = TRUE, 
          # right = TRUE,
          ordered_result = TRUE, 
          right = TRUE)
    
    return(age_variable)
  }
  
  at_least_one_child <- function(num_child){
    
    num_child <- 
      
      if_else(num_child >= 1, 
              'At least one child', 
              'No children')
    
    return(num_child)
    
  }
  
  # there are a couple money variables of interest that we can adjust
  # to constant dollars using [money related variable] and the ADJINC factor
  income_constant_dollars <- function(income_variable, adjustment_variable){
    
    adjusted_money = income_variable * adjustment_variable 
    
  }
  
  create_income_brackets <- function(income_variable){
    
      income_variable <- 
      
      cut(x = income_variable, 
          breaks = c(0,10000,20000,30000,40000,50000,60000,70000,80000,90000,10000000), 
          labels = c(
            "0 - 9,999", 
            "10,001 - 19,999", 
            "20,000 - 29,999", 
            "30,000 - 39,999", 
            "40,000 - 49,999", 
            "50,000 - 59,999", 
            "60,000 - 69,999", 
            "70,000 - 79,999", 
            "80,000 - 89,999", 
            '90,000+'),
          right = FALSE, 
          include.lowest = TRUE)
    
    return(income_variable)
    
  }
  
  create_commute_bracket <- function(commute_var){
    # breaking down the commute variable into brackets 
    # arbitrarily defined
    # identifies commute to work
    
    commute_var <- 
      cut(commute_var, 
          breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 1000),
          labels = c("0-9", 
                     "10-19", 
                     "20-29",
                     "30-39", 
                     "40-49", 
                     "50-59", 
                     "60-69", 
                     "70-79", 
                     "80-89",
                     "90-99", 
                     "100 +"), 
          right = TRUE,
          include.lowest = TRUE, 
          ordered_result = TRUE)
    
    return(commute_var)
    
    
  }
  
  identify_head_of_household <- function(RELP){
    
    # RELP = relationship variable 
    # establishes a rows relationsihp with respect to the head of household
    # per IPUMS and consultation with ACS Data Users Group, 
    # RELP == 00 referes to reference person, which in this case is 
    # the head of household in the PUMS survey
    # ACS stopped refering to head of household as such in the 80's and now calls
    # the survey respondent the reference person
    
    head_of_household <- 
      if_else(RELP == 0, 
              TRUE,
              FALSE)
    
    return(head_of_household)
    
    
  }
  
  identify_hh_oy <- function(oy_flag, head_hh_flag){
    
    head_hh_oy <-
      case_when(
        oy_flag == "opp_youth" & head_hh_flag == TRUE        ~ "Opportunity Youth - HH", 
        oy_flag == "opp_youth" & head_hh_flag == FALSE       ~ "Opportunity Youth - Non-HH", 
        oy_flag == "connected_youth" & head_hh_flag == TRUE  ~ "Connected Youth - HH", 
        oy_flag == "connected_youth" & head_hh_flag == FALSE ~ "Connected Youth - Non-HH", 
        oy_flag == "everyone_else"   & head_hh_flag == TRUE  ~ "Everyone Else - HH", 
        oy_flag == "everyone_else"   & head_hh_flag == FALSE ~ "Everyone Else - Non-HH", 
        TRUE ~ oy_flag
      )
    
    
    
    return(head_hh_oy)
    
    
  }
  
  # RUN FUNCTIONS
  pums_data <- 
    pums_data %>% 
    mutate(age_bracket     = create_age_brackets(AGEP), 
           alt_age_bracket = alt_age_brackets(AGEP), 
           child_flag      = at_least_one_child(NOC), 
           adjusted_income = income_constant_dollars(income_variable = PINCP, 
                                                     adjustment_variable = ADJINC), 
           income_bracket = create_income_brackets(adjusted_income), 
           commute_bracket = create_commute_bracket(JWMNP), 
           head_hh_flag = identify_head_of_household(RELP),
           oy_hh_flag = identify_hh_oy(oy_flag, head_hh_flag))
  
  return(pums_data)
  
  
  
  
}

