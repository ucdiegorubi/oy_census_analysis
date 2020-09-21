
load_data <- 
  list(
    download_pums_data = function(){
      
      # api_key = 
      #   get_api_key()
      
      tidycensus::get_pums(
        # key = api_key,
        variables = get_pums_variables(), 
        state = 'IL', 
        recode = TRUE, 
        year = 2018, 
        survey = 'acs1', 
        rep_weights = 'person'
      )
    }, 
    load_pums_data = function(){
      
      file_path = 
        here::here('raw_data', 
                   'il_pums_data.csv')
      
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
    }
    
  )

