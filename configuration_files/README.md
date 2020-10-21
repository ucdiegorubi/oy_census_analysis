The configuration files here contains the following:

census_api_key:

- the Census API key received from the U.S. Census bureau to download ACS data

pums_parameters:

- the various function parameters passed onto **tidycensus::get_pums()** that indicate what file year we want (**2018**), the survey of interest (**ACS 1-year**), what type of replicate weights we want (**person level, housing level, or both**), and whether or not we want to recode the original variables to translate value labels for a given variable. For example, variable_A will be called variable_A_label where each value in variable A is translated (think 0 == "Did not respond"). Basically, if I'd like to build this variable for a different state, I am able to do that.

- pums_variables:
    - Indicates the variables we want tidycensus to download from the Census bureau. 