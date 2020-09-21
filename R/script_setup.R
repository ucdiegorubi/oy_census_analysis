# Setup:


# LOAD LIBRARIES ----------------------------------------------------------

if(!require(pacman)) install.packages('pacman')

p_load(
  tidyverse, 
  tidycensus, 
  magrittr
)


# LOAD FUNCTIONS ----------------------------------------------------------
walk(
  .x = 
    list.files(
      path = here::here('functions'), 
      full.names = TRUE
    ), 
  .f = 
    ~ source(.)
)


