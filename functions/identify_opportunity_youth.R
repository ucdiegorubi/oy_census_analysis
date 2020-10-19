# Diego Rubi
# Purpose:
#   Identifying opportunity youth in the data 


identify_opportunity_youth <- function(pums_data){
  
  
  # there are two conditions which define an opportunity youth
  #   1. They are youth (ages 16 - 25)
  #   2. They are unemployed and also not in school
  #   
  #   I'm going to create three separate flags for each condition
  #   (not in school, a youth, and not employed) and 
  #   where those are all TRUE, we've identified opportunity youth
  #   
  #   I'll also define the comparison group, youth, 
  
  youth_flag <- function(){
    
    # identifies individuals that are within 16 and 25 years old, 
    # which is the age range for opportunity youth
    
    pums_data <- 
      
      pums_data %>% 
      mutate(
        youth_flag = 
          if_else(
            # establishing the age range
            condition = AGEP <= 24 & AGEP >= 16, 
            true = TRUE,
            false = FALSE
            
            
          ), 
        youth_label = 
          if_else(
            condition = 
              youth_flag == TRUE, 
            true = 'Youth', 
            false = 'Non-Youth'
          )
      )
    
    return(pums_data)
    
    
  }
  
  employment_status_flag <- function(){
    
    # identifies individuals who are not currently working based on 
    # a number of different work-status variables
    
    pums_data <- 
      pums_data %>% 
      mutate(
        employment_flag =
          
          if_else(
            
            # employment status
            # 3 == unemployed, 6 == "not in labor force"
            ESR %in% c( "3", "6"),
              
            
            true = TRUE , 
            false = FALSE
            
          ), 
        employment_label = 
          if_else(
                employment_flag == TRUE, 
                'Unemployed', 
                'Not Unemployed'
              )
          )
        
        return(pums_data)
        
  }
  
  school_enrollment_flag <- function(){
    
    # creates a flag that identifies whether or not someone is enrolled in school
    # there is only one variable that does so, identified below
    
    
    pums_data <-
      
      pums_data %>%
      mutate(
        school_flag =
          if_else(
            condition = 
              # 1 == No, has not attended in the last 3 months
              # This is the only variable indicating some type of 
              # school enrollment 
              SCH == "1",
            true = TRUE,
            false = FALSE,
            
          ),
        school_label =
          if_else(
            condition = school_flag == TRUE,
            true = 'Not Attending School',
            false = 'Attending School'
          )
      )
    
    return(pums_data)
    
    
  }
  
  # adding the three flags
  
  pums_data <- youth_flag()
  pums_data <- employment_status_flag()
  pums_data <- school_enrollment_flag()
  
  # finding the point where those three flags are true
  pums_data <- 
    
    pums_data %>% 
    
    mutate(
      
      disconnection_flag =
        
        if_else(
          
          # Individual is both unemployed and not enrolled in school 
          employment_flag == TRUE & school_flag == TRUE, 
          true = TRUE, 
          false = FALSE
        ), 
      
      
      
      oy_flag = 
        if_else(
          
          youth_flag == TRUE & disconnection_flag == TRUE , 
          'opp_youth', 
          
          if_else(
            (youth_flag == TRUE & disconnection_flag == FALSE), 
            'connected_youth', 
            'everyone_else'
          )

          
        )
      
      
        
    )
  
  return(pums_data)
  
  
}






