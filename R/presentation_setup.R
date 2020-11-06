# Setup:


# LOAD LIBRARIES ----------------------------------------------------------

if(!require(pacman)) install.packages('pacman')

p_load(
  tidyverse, 
  magrittr, 
  kableExtra, 
  viridis, 
  flextable,
  ggsci
)


# LOAD FUNCTIONS ----------------------------------------------------------

walk(
  .x = c('load_data_functions.R', 
         'helper_functions.R', 
         'presentation_formatting.R'), 
  .f = ~ 
    source(
      here::here(
        'functions', .)
    )
)

