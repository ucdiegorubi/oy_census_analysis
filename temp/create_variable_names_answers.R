names(pums_df)

c("SCH_label", 
  "NWAB_label", 
  "NWAV_label", 
  "NWLA_label", 
  "NWLK_label", 
  "NWRE") %>% 
  map(.f = ~ 
        pums_df %>% 
        select_at(vars(matches(.x))) %>% 
        distinct())

work_columns <- 
  c(
    school_enrollment = "SCH_label", 
    temporary_work_abscence = "NWAB_label", 
    available_for_work = "NWAV_label",
    on_layoff = "NWLA_label", 
    looking_for_work = "NWLK_label", 
    when_last_worked = "WKL_label", 
    worked_last_week = "WRK_label"
  ) %>% 
  map(
    .f = ~ 
      pums_df %>% 
      select_at(vars(matches(.x))) %>% 
      distinct())


pums_variables %>% 
  filter(var_code == "WKW") %>% 
  select(var_code, var_label, val_label) %>% 
  distinct()



work_columns %>% 
  map(.f = 
        ~ 
        .x %>% 
        knitr::kable() %>% 
        kableExtra::kable_styling(full_width = F))




work_columns %>% 
  walk(.f = ~
        write_csv(x = ., 
                  path = 
                    here::here(
                      'temp', 
                      'variable_names_answer_choices.csv'), 
                  append = TRUE))



