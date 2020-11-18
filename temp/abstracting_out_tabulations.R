get_vars <- function(survey_level, data_type = c('num', 'chr')){
 
  tidycensus::pums_variables %>% 
    filter(year == 2018, 
           survey == 'acs1', 
           level == survey_level) %>% 
    distinct(var_code, var_label, data_type) %>% 
    filter(data_type == data_type)
    # pull(var_code) %>% 
    # unique()
   
}

setdiff(get_vars('housing'), get_vars('person'))
setdiff(get_vars('person'), get_vars('housing'))

intersect(get_vars('housing'), names(pums_df)) %>% 
  enframe(name = NULL, value = "Variable") %>% 
  filter(!str_detect(Variable, "WGTP")) %>% 
  View()


numeric_housing_vars <- 
  get_vars('housing', 'num') %>% 
  filter(data_type == 'num', 
         var_code %in% names(pums_df), 
         !str_detect(var_code, 'WGTP')) %>% 
  pull(var_code) 

chr_housing_vars <- 
  get_vars('housing', 'chr') %>% 
  filter(data_type == 'chr', 
         var_code %in% names(pums_df), 
         !str_detect(var_code, 'WGTP')) %>% 
  pull(var_code)



numeric_housing <- function(var){
  
  var = rlang::sym(var)
  
  pums_hh_survey %>% 
    group_by(oy_household) %>% 
    summarize(
      mean = survey_mean(x = !!var, vartype = 'ci')
      
    )
  
}

housing_test <- 
  map(numeric_housing_vars, 
      .f = ~ numeric_housing(var = .)) %>% 
  set_names(housing_vars)


pums_hh_survey %>% 
  group_by(oy_household) %>% 
  survey_count(FS_label, vartype = c('se','ci'))

