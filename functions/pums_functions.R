
# CLEAN RACE VAR ----------------------------------------------------------


recategorize_race <- function(pums_data){
  
  # goal is to separate out race from hispanic ethnicity
  # HISP == 01 == "Not Spanich / Hispanic / Latino (Non-Hispanic)
  # We ultimately use race_alternate as the variable we tabulate for race / ethnicity
  
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


# ADD OTHER INDICATORS ----------------------------------------------------
# CREATES 
#   AGE BRACKETS
#   IDENTIFIES PEOPLE WITH AT LEAST ONE CHILD (NO LONGER RELEVANT)
#   adjusts income to constant dollars
#   income brackets
#   commute brackets
#   identifies head of household
#   collapses educational attainment to be less granular



add_other_indicators <- function(pums_data){
  
  create_age_brackets <- function(age_variable){
    
    # 0 not captured for some reason
    # Creating age brackets that reflect the age brackets of interest for OY
    # we think of the whole bracket (16 - 24) but often break that up into two gruops
    #   16 - 19, and then 20 - 24
    
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
    
    # do not remember why we did this or whether or not we used this but 
    # I know an alternative age bracket was asked for
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
          right = FALSE,
          include.lowest = TRUE, 
          ordered_result = TRUE)
    
    return(commute_var)
    
    
  }
  
  identify_head_of_household <- function(RELP){
    
    # RELP = relationship variable  in PUMS
    # establishes a rows relationsihp with respect to the head of household
    # per IPUMS and consultation with ACS Data Users Group, 
    # RELP == 00 refers to reference person, which in this case is 
    # the head of household in the PUMS survey
    # ACS stopped referring to head of household as such in the 80's and now calls
    # the survey respondent the reference person
    
    head_of_household <- 
      if_else(RELP == 0, 
              TRUE,
              FALSE)
    
    return(head_of_household)
    
    
  }
  
  # identifying heads of household within the 3 opportunity youth groups
  # to parse out various population estimates conditional on head of household
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
  
# CLEAN EDUCATION VARIABLE ----   
  clean_education_variable = function(SCHL){
    
    # clean up SCHL variable (educational attainment) as it has 
    # way too many levels (grade 1, 2, etc)
    
    some_college = 
      c("Some college, but less than 1 year", 
        "1 or more years of college credit, no degree")
    
    no_hs_diploma = 
      c(paste0("Grade ", 1:11), 
        "12th grade - no diploma", 
        "Nursery school, preschool", 
        'Kindergarten')
    
    
    SCHL <- 
      case_when(
        SCHL %in% some_college   ~ "Some College", 
        SCHL %in% no_hs_diploma  ~ "Less than High School Diploma",
        TRUE                   ~ SCHL
      )
    
    
    return(SCHL)
    
  }
  
  # RUN FUNCTIONS
  pums_data <- 
    pums_data %>% 
    mutate(age_bracket        = create_age_brackets(AGEP), 
           alt_age_bracket    = alt_age_brackets(AGEP), 
           # does someone have at least one child - defunct, opted for IPUMS data source
           child_flag         = at_least_one_child(NOC), 
           # adjusted total personal income
           adjusted_income    = income_constant_dollars(income_variable = PINCP, 
                                                     adjustment_variable = ADJINC),
           # adjusted household income
           HINCP              = income_constant_dollars(HINCP, ADJINC),
           
           income_bracket     = create_income_brackets(adjusted_income), 
           commute_bracket    = create_commute_bracket(JWMNP), 
           # identifying heads of household from reference person
           head_hh_flag       = identify_head_of_household(RELP),
           # identifing heads of household within oy group
           oy_hh_flag         = identify_hh_oy(oy_flag, head_hh_flag), 
           # collapsing education attainment to more manageable number of education levels
           school_attainment  = clean_education_variable(SCHL_label))
  
  return(pums_data)
  
  
  
  
}

# categorize households into oy households and non-oy households and households
# with both

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
              !is.na(everyone_else)                     ~ "CY-EE Only Household", 
            
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
  
  oy_household_collapse <- function(oy_household){
    
    # Collapsing OY-Only
    # OY-CY ONLY
    # OY-EE Only
    
    out <- 
      forcats::fct_collapse(
        .f = oy_household,
        `OY Household` = c("OY Only Household", 
                           "OY-CY Only Household", 
                           "OY-EE Only Household", 
                           "Combined Household"))
    
    return(out)
    
    
  }
  
  # Run Functions
  message("Tabulating Person-type per household")
  wide_data <- spread_oy_flag()
  message("Categorizing households")
  
  short <- generate_household_categories(wide_data = wide_data)
  full <- generate_complete_household_categories(wide_data = wide_data)
  full <- 
    full %>% 
    mutate(oy_household_full = oy_household_collapse(oy_household_full))
  
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

create_puma_regions <- function(pums_data){
  
  southside_pumas <- 
    c("03532", 
      "03531", 
      "03530",
      "03529", 
      "03528", 
      "03527",
      "03526")
  
  westside_pumas <- 
    c("03521", 
      "03523", 
      "03524", 
      "03522", 
      "03520")
  
  # I know we could logically 
  # We can define northside regions as the regions that are not
  # southside or westside so we do not have to explicitely 
  # define those PUMAS
  
  pums_data <- 
    
    pums_data %>% 
    mutate(PUMA_region = 
             case_when(PUMA %in% southside_pumas                       ~ "Southside", 
                       PUMA %in% westside_pumas                        ~ "Westside", 
                       !(PUMA %in% c(westside_pumas, southside_pumas)) ~ "Northside"))
  
  
  
  return(pums_data)
  
  
  
}



