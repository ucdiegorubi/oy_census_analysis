# helper_functions.R

* literal helper functions that check for directories. 

# identify_chicago_PUMA.R

Function that takes the PUMA data as an input and uses a crosswalk between PUMAS and various other geograhpic units to tie certain PUMAS to the City of Chicago. There are 17 PUMAS associated with Chicago and they all have a name beginning with "Chicago City". I used string detection to identify these PUMAS and then created a vector that I can use to match the PUMAs in the PUMS file to this vector of PUMAS. 

# identify_opportunity_youth.R

Identifies opportunity youth in the PUMS file. The function is well documented, but keep the PUMS data documentation / codebook available to cross reference. 

# IPUMS_functions.R

Also identifies opportunity youth. This function is also well documented and contains links to the IPUMS website for the variables used to identify opportunity youth. 

# load data functions
Just functions for loading data stored in a list

# Presentation formatting
Various helper functions used to format the input data used in the visualization markdowns. 

# process_map_data.R
Function that takes in data that contains estimates for a given variable grouped by PUMA and automatically joins it to a geographic file of Chicago .

The idea here is that the geograhpic file of Chicago is an sf object provided by Tidycensus that always contains a PUMA variable to join on. Because of this, I can take any grouped data frame that contains a PUMA column and automatically select the 1). variable of interest and the 2). population estimates for that variable of interest. I can spread / pivot_wider() with that dataframe to automatically add that data to the geographic file for easy visualization later on down the line. 

# pums_indicators.R

Contains two functions, recategorize_race() and add_other_indicators() that basically do just that to the PUMS data. One collapses race values and separates them from hispanic ethnicity, and the other adds various other flags / indicators or creates brackets using numeric variables (i.e., income brackets). 
