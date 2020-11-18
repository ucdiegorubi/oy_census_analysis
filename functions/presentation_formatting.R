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
      
      # households <- 
      #   c("Non-OY Household", 
      #     "OY & CY Household", 
      #     "OY Household", 
      #     "CY Only Household")
      # 
      # oy_household <- 
      #   case_when(
      #     oy_household == "non_oy_household" ~ households[1], 
      #     oy_household == "oy_cy_household"  ~ households[2], 
      #     oy_household == "oy_household"     ~ households[3], 
      #     oy_household == "cy_only_household"~ households[4]
      #   )
      
      oy_household <-  
        factor(
          oy_household)
      
      return(oy_household)
    }, 
      
      
      
    
    fig_help = 
      list(
        N = "N = ", 
        newline = "\n", 
        tab = '\t'
      ), 
    
    x_axis = "Opportunity Youth Grouping", 
    y_percent = "Percent", 
    y_count   = "Population Estimate", 
    
    citations = 
      c(IPUMS = "Source: IPUMS USA, University of Minnesota, www.ipums.org.", 
        PUMS  = "Source: U.S. Census Bureau, 2018 American Community Survey 1-Year Estimates"), 
    suppress = "Percentages less than 5% suppressed for clarity", 
    CI = "Error bars reflect a 95% confidence interval"
    
      
  )

pretty_flex <- function(x){
  
  require(flextable)
  require(officer)
  
  num_col = ncol(x)
  
  row_indices <- function(x, type = c("odd", "even")){
    
    num_rows = nrow(x)
    
    get_row_indices <- function(){
      
      row_indices <- 1:num_rows
      
      if(type == "odd"){
        test <- which((row_indices %% 2) == 1)
      } else{
        test <- which((row_indices %% 2)== 0)
      }
      
      return(test)
      
    }  
    
    indices <- get_row_indices()
    
    return(indices)
  }
  
  x %>% 
    flextable() %>% 
    autofit() %>% 
    font(fontname = 'Arial',part = 'body') %>% 
    font(fontname = 'Arial', part = 'header') %>%
    fontsize(part = 'all', size = 10) %>% 
    bold(part = 'header') %>% 
    color(part = 'header',color = 'white') %>% 
    align(align = 'left',
          j = 1,
          part = 'all') %>%
    align(align = 'center', 
          j = 2:num_col, 
          part = 'all') %>% 
    bg(part = 'header', 
       bg = "#c16622") %>% 
    bg(i = row_indices(x, 'even'), 
       bg = "#d6d6ce") %>% 
    border_remove()
  
}
