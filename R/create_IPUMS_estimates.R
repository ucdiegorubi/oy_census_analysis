# Diego Rubi 
# creating population estimates using IPUMS data
# Going to use a survey object that will automatically calculate 
# standard errors using replicate weights (bless up)
# limiting ourselves to Number of Children per a given individual
source(
  here::here(
    'R',
    'script_setup.R'
  )
)


# LOAD DATA --------------------------------------------------------------------

ipums <- load_data$load_clean_IPUMS()


# PREP --------------------------------------------------------------------
# Not suuuuuuper familiar with srvyr package but things generally need to be
# factors
ipums <- 
  ipums %>% 
  mutate(oy_flag = factor(oy_flag), 
         NCHILD = factor(NCHILD, ordered = TRUE))

# per an issues page from the Minnesota Population Center
# https://github.com/mnpopcenter/ipumsr/issues/50
ipums_survey <- as_survey(ipums, 
                 weight = PERWT,
                 repweights = matches("REPWTP[0-9]+"), 
                 type = "Fay", 
                 rho = 0.5, 
                 mse = TRUE)



# CREATE DATA -------------------------------------------------------------
analysis_data <- 
  list(
    
    n_children = 
      ipums_survey %>% 
      group_by(oy_flag, NCHILD) %>% 
      survey_count(vartype = c("se", 'ci')), 
    
    percent_children = 
      ipums_survey %>% 
      group_by(oy_flag, NCHILD) %>% 
      summarize(
        percent = survey_mean(vartype = c('se', 'ci'))
      )
    
  )




# WRITE DATA --------------------------------------------------------------

readr::write_rds(x = analysis_data, 
          
  here::here(
    'analysis_data', 
    'IPUMS_oy_population_estimates.RDS'
  )
)
