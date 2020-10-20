# Diego Rubi
# October 20, 2020
# Processing IPUMS data
# https://usa.ipums.org/usa/
# Difference between IPUMS and PUMS is IPUMS uses PUMS data and processes it 
# to make it easier for analylsis

# SETUP -------------------------------------------------------------------
source(
  here::here(
    'R', 
    'script_setup.R'
  )
)


# LOAD DATA ---------------------------------------------------------------

ipums <- load_data$load_ipums_data()


# RUN FUNCTIONS -----------------------------------------------------------

ipums <- identify_oy_ipums(ipums_data = ipums)


# WRITE -------------------------------------------------------------------
write_csv(
  x = ipums, 
  path = here::here(
    'clean_data', 
    'il_IPUMS_data_clean.csv'
  )
)






