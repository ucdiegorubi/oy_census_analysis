CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT:=$(realpath $(CURRENT_DIR)/../)
R_version= /opt/R/4.0.2/bin/Rscript

# basically establishes all the directories in the project folder that I can 
# use to create filepaths to dependencies
RAW_DATA = $(CURRENT_DIR)/raw_data
CLEAN_DATA = $(CURRENT_DIR)/clean_data
ANALYSIS_DATA = $(CURRENT_DIR)/analysis_data
SCRIPTS = $(CURRENT_DIR)/R
CONFIG = $(CURRENT_DIR)/configuration_files
VIZ = $(CURRENT_DIR)/create_powerpoint

# if any of the function sin the fucntions folder have changed then its likely that some 
# early process has changed so I'm creating this dependency
functions = $(CURRENT_DIR)/functions/*

# inputs:
# pums_data is public use microdata file from the American Community Survey
# ipums_data is the same file, but processed by the University of Minnesota to 
# make it easier for analysis 
pums_data = $(RAW_DATA)/il_pums_data.csv
ipums_data = $(RAW_DATA)/il_ipums.csv

# targets: clean / processed data
pums_processed = $(CLEAN_DATA)/il_pums_data_clean.csv
ipums_processed = $(CLEAN_DATA)/il_ipums_data_clean.csv

# targets: population estimates
estimates = $(ANALYSIS_DATA)/oy_population_estimates.RDS
ipums_estimates = $(ANALYSIS_DATA)/IPUMS_oy_population_estimates.RDS

# targest: visualizations (powerpoint decks for the partner)
demographics_viz = $(VIZ)/demographic_estimates.pptx
housing_viz = $(VIZ)/household_structure_estimates.pptx


# phony dependency
.DEFAULT_GOAL=all

# our goal is to make all of these, so we're defining a variable called 'all' that 
# is more or less a composition of all of the other variables
all : $(pums_data) $(ipums_data) $(pums_processed) $(ipums_processed) $(estimates) $(ipums_estimates) $(demographics_viz) $(housing_viz)

########
########
########
# Execution

# donwloading the PUMS data from the Census Bureau
$(pums_data): $(SCRIPTS)/download_pums_data.R $(CONFIG)/pums_variables.yaml
	$(R_version) $(SCRIPTS)/download_pums_data.R

# processing the PUMS data that's from the census bureau
$(pums_processed): $(SCRIPTS)/process_pums_data.R $(pums_data) $(functions)
	$(R_version) $(SCRIPTS)/process_pums_data.R
	
# processing the IPUMS data extract that I downloaded from IPUMS
$(ipums_processed): $(SCRIPTS)/process_ipums_data.R $(ipums_data) $(functions)
	$(R_version) $(SCRIPTS)/process_ipums_data.R

# generating population estimates with the PUMS data
$(estimates): $(SCRIPTS)/create_population_estimates.R $(pums_processed) 
	$(R_version) $(SCRIPTS)/create_population_estimates.R
	
# generating population estimates with the IPUMS ipums_data
# number of children per household only
$(ipums_estimates): $(SCRIPTS)/create_IPUMS_estimates.R $(ipums_processed) 
	$(R_version) $(SCRIPTS)/create_IPUMS_estimates.R

# creating visualizations for the demographic estimates (research question 1)
$(demographics_viz): $(VIZ)/demographic_estimates.Rmd $(estimates) $(ipums_estimates)
	$(R_version) -e "rmarkdown::render(here::here('create_powerpoint','demographic_estimates.Rmd'))"

# creating visualizations for the household structure questions (research question 2)
$(housing_viz): $(VIZ)/household_structure_estimates.Rmd $(estimates) $(ipums_estimates)
	$(R_version) -e "rmarkdown::render(here::here('create_powerpoint','household_structure_estimates.Rmd'))"


# shortcuts :)
# basically if in terminal you type make get_data, it'll only execute the portion that 
# downloads new data

# download configuration_files
get_data: 
	make $(pums_data)

# process both pums files
process:
	make $(pums_processed)
	make $(ipums_processed)

# generate population estimates
estimate:
	make $(estimates)
	make $(ipums_estimates)
	
# visualizations 
visuals:
	make $(housing_viz)
	make $(demographics_viz)

# DESTROY
# basically cleans up your folder and gets rid of the various outputs
# removes the downloaded PUMS file, the clean (processed PUMS and IPUMS data), and 
# the population estimates

clean_all: 
		rm -rf $(pums_data)
		rm -rf $(CLEAN_DATA)
		rm -rf $(ANALYSIS_DATA)
		rm -rf $(demographics_viz)
		rm -rf $(housing_viz)
		
clean_viz:
		rm -rf $(demographics_viz)
		rm -rf $(housing_viz)