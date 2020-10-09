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
    
    # based on US federal income tax brackets <- 
    # 
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
  
  # RUN FUNCTIONS
  pums_data <- 
    pums_data %>% 
    mutate(age_bracket     = create_age_brackets(AGEP), 
           alt_age_bracket = alt_age_brackets(AGEP), 
           child_flag      = at_least_one_child(NOC), 
           adjusted_income = income_constant_dollars(income_variable = PINCP, 
                                            adjustment_variable = ADJINC), 
           income_bracket = create_income_brackets(adjusted_income), 
           commute_bracket = create_commute_bracket(JWMNP))
  
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
  recategorize_race(pums_data = pums_df)

pums_df <- 
  add_other_indicators(pums_data = pums_df)


# WRITE DATA --------------------------------------------------------------

helper_functions$check_for_directory('clean_data')

readr::write_csv(
  x = pums_df, 
  path = 
    here::here(
      'clean_data', 
      'il_pums_data_clean.csv'
    )
)

         