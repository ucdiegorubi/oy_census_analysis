test <- 
  analysis_data[str_detect(names(analysis_data), 'hh')]

test$hh_type %>% 
  View()


analysis_data$hh_food_stamps %>% 
  
  
  ggplot(aes(x = oy_hh_flag, y = percent)) + 
  geom_col(aes())

analysis_data[str_detect(names(analysis_data), 'hh')]


basic_plot_dodge <- function(data, fill_label = NULL){
  
  fill_col = names(data)[2] %>% rlang::sym()
  
  x_col =    names(data)[str_detect(names(data), "oy")] %>% rlang::sym()
  
    data %>% 
    filter(!str_detect(!!x_col, '(Everyone)|(Eveyrone)')) %>% 
    ggplot(aes(x = !!x_col, y = percent, fill = !!fill_col)) + 
    geom_col(color = 'black', 
             position = 'dodge') + 
    geom_text(aes(label = scales::percent(percent, accuracy = .1),
                  group = !!fill_col), 
              position = position_dodge(width = .87), 
              vjust = 1.3) +
    geom_errorbar(aes(ymin = percent, ymax = percent_upp, 
                      group = !!fill_col), 
                  width = .5, 
                  position = position_dodge(1))+
    theme_classic() + 
    scale_y_continuous(labels = scales::percent) + 
    
    erase_y_axis + 
    erase_x_legend + 
    theme(axis.text.x = element_text(face = 'bold')) + 
    labs(
      caption = "Cells representing less than 5% suppressed for clarity") 
    # scale_fill_manual(values = color_contrast_hh)
  
  
}


basic_plot_dodge(analysis_data$hh_food_stamps) 
basic_plot_dodge(analysis_data$hh_hh_type)
basic_plot_dodge(analysis_data$hh_married)
basic_plot_dodge(analysis_data$hh_workers_in_fam)
basic_plot_dodge(analysis_data$hh_migration)


hh_data <- 
  analysis_data[str_detect(names(analysis_data), '^hh')]

plots <- 
  map(hh_data, basic_plot_dodge)

basic_plot_dodge(analysis_data$partnered)
