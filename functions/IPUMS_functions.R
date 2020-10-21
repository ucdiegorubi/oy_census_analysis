# Two functions that do the following:
# Identify opportunity youth in IPUMS data
# Identify individuals with at least one child

ipums_processing <- 
  list(
    
    identify_oy_ipums =  function(ipums_data){
      
      # Opportunity youth are the intersection of 
      #   Age 16 - 24
      #   not in school
      #   not employed
      #     - the intersection of the latter two = 'disconnection'
      
      
      identify_employment_status <- function(empstat){
        
        # EMPSTAT on IPUMS
        # 2 = unemployed
        # 3 = not in labor force
        # https://usa.ipums.org/usa-action/variables/EMPSTAT#description_section
        
        out <- 
          if_else(empstat %in% c(2,3), 
                  TRUE, 
                  FALSE)
        
        return(out)
        
      }
      
      identify_school_enrollment <- function(school){
        
        # SCHOOL on ipums
        # 1 = no, not in school
        # https://usa.ipums.org/usa-action/variables/SCHOOL#codes_section
        
        out <- 
          if_else(school == 1, 
                  TRUE, 
                  FALSE)
        
        return(out)
      }
      
      identify_youth <- function(age){
        
        # AGE
        # interested in age range between 16 and 24
        # https://usa.ipums.org/usa-action/variables/AGE#description_section
        
        out <- age >= 16 & age <= 24
        
        return(out)
        
        
      }
      
      # werk it
      # my approach is to create various flags capturing the information above
      # and using the intersection of those three flags to identify opportunity youth
      # 
      
      ipums_data <- 
        
        ipums_data %>% 
        
        mutate(
          
          # creating our flags that we use to identify our comparison groups
          # oy are defined as above
          # connected youth are those youth that are not disconnected
          # and then we're dumping everyone else into their own category
          # but we're not particularly interested in them for this analysis 
          youth_flag            = identify_youth(age = AGE), 
          school_flag           = identify_school_enrollment(school = SCHOOL), 
          employment_flag       = identify_employment_status(empstat = EMPSTAT), 
          disconnection_flag    = school_flag & employment_flag, 
          
          # creating our three comparison groups
          oy_flag = 
            
            case_when(
              youth_flag & disconnection_flag  ~ "opp_youth", 
              youth_flag & !disconnection_flag ~ "connected_youth",
              TRUE                             ~ "everyone_else"))
      
      
      
      
      return(ipums_data)
      
    }, 
    
    ipums_one_child = function(ipums_data){
      
      # Create a binary variable identifying who has at least one child
      ipums_data <- 
        
        ipums_data %>% 
        mutate(
          at_least_one_child = 
            if_else(NCHILD >= 1, 
                    "At least one child", 
                    "No Children")
        )
      
      
      return(ipums_data)
      
    }
    
  )