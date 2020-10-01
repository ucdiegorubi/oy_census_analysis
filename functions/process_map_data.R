
process_map_data <- function(data, names, values){
  
  # data is wthe data to join
  # default is to plot for illinois and join by puma so 
  # there should be a column called PUMA
  download_map_data <- function(state_code = "17"){
    
    file = 
      tigris::pumas(state = state_code)
    
  }

  
  prep_data <- function(){
    
    data <- 
      data %>% 
      select(PUMA, names, values) %>% 
      pivot_wider(names_from = names, 
                  values_from = values)
    
    return(data)
  }
  
  join_files <- function(){
    
    joined <- 
      tigris::geo_join(spatial_data = map_data, 
                       data_frame = pivot_data, 
                       by_sp = 'PUMACE10',
                       by_df = 'PUMA')
    
  }
  
  # RUN FUNCTIONS
  map_data <- download_map_data()
  
  pivot_data <- prep_data()
  
  joined_data <- join_files()
  
  return(joined_data)
  
  
}


# 
# 
# 
# 
# test_df <- 
#   analysis_data$puma_oy_population %>% 
#   select(PUMA, oy_flag, n) %>% 
#   pivot_wider(names_from = 'oy_flag', 
#               values_from = 'n')
# 
# test_df <- 
#   test_df %>% 
#   mutate(CHI_PUMA = TRUE)
# 
# 
# 
# chi_pumas <- 
#   join_test %>% 
#   filter(CHI_PUMA)
# 
# test_centroid <- 
#   sf::st_centroid(chi_pumas$geometry)
# 
# test_centroid <- 
#   test_centroid %>% 
#   tigris::geo_join(spatial_data = il_pumas, 
#                    data_frame = test_df, 
#                    by_sp = "PUMACE10", 
#                    by_df = "PUMA")
# 
# 
analysis_data$geo_puma_pop %>%
  # filter(CHI_PUMA) %>%
  ggplot() +
  geom_sf(aes(fill = `Opportunity Youth`)) +
  theme_classic() +
  scale_fill_gradient(low = "#fff7bc",
                      high = "#D5802B",
                      na.value = "white") +
  geom_sf_text(label = join_test %>% filter(CHI_PUMA) %>% pull(`Opportunity Youth`),
               size = 2) +
  theme(
    axis.title = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank()
  )


analysis_data$geo_puma_pop %>% 
  
  ggplot() + 
  geom_sf(aes(fill = `opp_youth`)) + 
  theme_classic() + 
  scale_fill_gradient(low = "#fff7bc",
                      high = "#D5802B",
                      na.value = "white")
  

  

