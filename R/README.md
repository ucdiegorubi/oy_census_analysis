# download_pums_data.R

Script that uses the Tidycensus package to download data directly from the ACS. Limited to Illinois for 2018 and uses the ACS 1-Year file. 

# process_pums_data.R

Processes the PUMS data extracted in download_pums_data.R to primarily identify opportunity youth and then add various other indicators. Relies on various functions in the functions folder to process the PUMS data. 

# process_ipums_data.R

Identifies opportunity youth in the IPUMS data. Relies on function in the functions folder to identify those individuals. 

# create_population_estimates.R

Uses the processed PUMS data to create a survey object that is used in generating population estimates. 

* Relies on the **srvyr** package, which serves as a wrapper around the **survey** package but making it compatible with Tidyverse syntax. 

* Relies on two functions to create population estimates. I pass various groupings to create population counts / proportions with standard errors and confidence intervals. 

# create_IPUMS_estimates.R

Uses the IPUMS data to create a survey object that is used to count the number of children for a given individual. That's the only tabulation that occurs with IPUMS data. 

Note: The main reason for doing this tabulation with IPUMS data is that number of children (NCHILD) for IPUMS data is defined at the individual level while with PUMS dat it is defined at the household level. We're interested in this question but for a given individual.

# script_setup.R and presentation_setup.R

loading various libraries and functions related to general scripts in the R folder and presentations respectively
