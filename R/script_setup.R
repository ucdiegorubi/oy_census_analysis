# Setup:


# LOAD LIBRARIES ----------------------------------------------------------

if(!require(pacman)) install.packages('pacman')

# library(pacman)

p_load(tidyverse, 
       tidycensus, 
       magrittr, 
       srvyr, 
       tigris)


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


