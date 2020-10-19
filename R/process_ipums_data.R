library(tidyverse)

ipums <- load_data$load_ipums_data()

ipums %>% 
  count(NCHILD)


identify_oy_ipums <- function(ipums_data){
  
  
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
  
  
  
  ipums_data <- 
    
    ipums_data %>% 
    mutate(
      youth_flag = identify_youth(age = AGE), 
      school_flag = identify_school_enrollment(school = SCHOOL), 
      employment_flag = identify_employment_status(empstat = EMPSTAT), 
      disconnection_flag = school_flag & employment_flag, 
      oy_flag = 
        if_else(youth_flag & disconnection_flag, 
                "opp_youth", 
                
                if_else(
                  youth_flag & !disconnection_flag, 
                  "connected_youth", 
                  "everyone_else"
                )))
  
  
  
  
  return(ipums_data)
  
}

ipums <- 
  identify_oy_ipums(ipums_data = ipums)

ipums <- 
  ipums %>% 
  mutate(oy_flag = factor(oy_flag), 
         NCHILD = factor(NCHILD, ordered = TRUE))


ipums %>% count(oy_flag, wt = PERWT)

ipums %>% 
  group_by(oy_flag) %>% 
  summarize(
    max_age = max(AGE, na.rm = TRUE), 
    min_age = min(AGE, na.rm = TRUE)
  )

ipums %>% 
  filter(oy_flag == "everyone_else", 
         AGE >= 16 | AGE <= 24)


library(srvyr)
svy <- as_survey(ipums, 
                 weight = PERWT,
                 repweights = matches("REPWTP[0-9]+"), 
                 type = "Fay", 
                 rho = 0.5, 
                 mse = TRUE)


svy %>% 
  group_by(oy_flag, NCHILD) %>%
  summarize(
    mean = survey_mean(vartype = c("se", "ci")))

svy %>% 
  group_by(oy_flag) %>% 
  survey_count(NCHILD, vartype = c("se", "ci")) %>% 
  mutate(percent = n/sum(n))


