if(!require(pacman)) install.packages('pacman')

pacman::p_load(
  tidyverse, 
  srvyr, 
  yaml, 
  survey, 
  tigris
)

remotes::install_github('walkerke/tidycensus')


