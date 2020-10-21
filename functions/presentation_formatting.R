figure_helpers <- 
  list(
    format_oy_variable = function(oy_flag){
      
      oy_flag = as.character(oy_flag)
      
      oy_flag = 
        case_when(
          oy_flag == "everyone_else" ~ "Everyone Else", 
          oy_flag == "connected_youth"  ~ "Connected Youth", 
          oy_flag == "opp_youth"     ~ "Opportunity Youth", 
          TRUE                       ~ oy_flag)
      
      oy_flag = factor(oy_flag, levels = c("Everyone Else", 
                                           "Connected Youth", 
                                           "Opportunity Youth"))
      
      return(oy_flag)
      
    }, 
    
    format_oy_hh_variable = function(oy_hh_flag){
      
      oy_hh_flag = 
        factor(x = oy_hh_flag, levels = unique(oy_hh_flag)[c(3,4,1,2,5,6)])
      
      
      return(oy_hh_flag)
      
      
    }, 
    
    format_education_variable = function(edu_attainment){
      
      
      edu_attainment = 
        
        factor(
          edu_attainment, 
          levels = c("N/A (less than 3 years old)",
                     "No schooling completed", 
                     "Less than High School Diploma", 
                     "Regular high school diploma",
                     "GED or alternative credential", 
                     "Some College", 
                     "Associate's degree", 
                     "Bachelor's degree",
                     "Master's degree", 
                     "Professional degree beyond a bachelor's degree", 
                     "Doctorate degree"), 
          ordered = TRUE)
      
      return(edu_attainment)
      
      
    }, 
    
    format_oy_household = function(oy_household){
      
      oy_household <- 
        case_when(
          oy_household == 
        )
      
      factor(
        oy_household, 
        levels = c("")
      )
      )
      
    }
      
      
      
    
    fig_help = 
      list(
        N = "N = ", 
        newline = "\n", 
        tab = '\t'
      ), 
    
    x_axis = "Opportunity Youth Grouping", 
    y_percent = "Percent", 
    y_count   = "Population Estimate"
    
      
  )
