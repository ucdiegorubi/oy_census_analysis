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
