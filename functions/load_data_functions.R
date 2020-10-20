
load_data <- 
  list(
    download_pums_data = function(state_config = 'IL', 
                                  year_config = '2018',  
                                  survey_config = 'acs1',
                                  recode_config = FALSE,
                                  rep_weight_config = 'person'){
      
      # api_key = 
      #   get_api_key()
      
      tidycensus::get_pums(
        # key = api_key,
        variables = get_pums_variables(), 
        state = state_config,  
        recode = recode_config, 
        year = year_config, 
        survey = survey_config,  
        rep_weights = rep_weight_config
      )
    }, 
    load_pums_data = function(){
      
      file_path = 
        here::here('raw_data', 
                   'il_pums_data.csv')
      
      file = 
        readr::read_csv(file_path)
      
    }, 
    load_ipums_data = function(){
      
      file_path = 
        here::here('raw_data', 
                   'il_ipums.csv')
      
      file = 
        readr::read_csv(file_path)
      
      
    }, 
    
    load_PUMA_crosswalk = function(){
      
      file_path = 
        here::here(
          'raw_data',
          'MSA2013_PUMA2010_crosswalk.csv')
      
      file = 
        readr::read_csv(file_path)
    }, 
    
    load_clean_pums = function(){
      
      file_path = 
        here::here(
          'clean_data', 
          'il_pums_data_clean.csv'
        )
      
      file = 
        readr::read_csv(file_path)
    }, 
    
    load_clean_IPUMS = function(){
      
      file_path = 
        here::here(
          'clean_data', 
          'il_IPUMS_data_clean.csv'
        )
      
      file = 
        readr::read_csv(file_path)
      
    }, 
    
    load_population_estimates = function(){
      
      file_path = 
        here::here(
          'analysis_data', 
          'oy_population_estimates.RDS'
        )
      
      file = 
        readr::read_rds(file_path)
      
    }, 
    
    load_IPUMS_population_estimates = function(){
      
      file_path = 
        here::here(
          'analysis_data', 
          'IPUMS_oy_population_estimates.RDS'
        )
      
      file = 
        readr::read_rds(file_path)
    }
    
  )

