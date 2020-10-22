Author: Carrie McGillen
Date: 10/21/20
Project: Thrive OY Census
Description: All the scripts that have been QA'd are listed below, along with any comments about those scripts

#script setup
looks good!

#download pums data
I can't comment on the rep_weights and recode from the pums_paramaters b/c I dont know what this means, but besides that, it all looks good and appeared to do what it says! And wow this is really amazing work.

#process_pums_data
There's a parsing failure that you noted in the readme related to the SCH variable, but there's also parsing failures related to the variable MIG. I didn't make any changes to script.

line 30 where you identify Chicago PUMAs, I had to make changes to the function source script identify_chicago_PUMA --I added a dplyr:: before filter and pull on lines 12 and 14. Otherwise it was trying to read filter from the stats package, and I have no idea what package it was trying to use for pull (!)

line 36 where you add other indicators, I made one change to the function source script pums_indicators, line 144 changing to right=FALSE to align with the break labels.

#process_ipums_data

#create_population_estimates

#create_ipums_estimates

#presentation_setup

#household_structure_estimates

#demographic_estimates