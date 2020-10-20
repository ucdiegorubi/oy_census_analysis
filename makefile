CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT:=$(realpath $(CURRENT_DIR)/../)
R_version= /opt/R/4.0.2/bin/Rscript


RAW_DATA = $(CURRENT_DIR)/raw_data
CLEAN_DATA = $(CURRENT_DIR)/clean_data
ANALYSIS_DATA = $(CURRENT_DIR)/analysis_data
SCRIPTS = $(CURRENT_DIR)/R
CONFIG = $(CURRENT_DIR)/configuration_files
VIZ = $(CURRENT_DIR)/create_powerpoint

# basically if any of these functions have changed then its likely that some 
# early process has changed so I'm creating this dependency
functions = $(CURRENT_DIR)/functions/*

# outputs 
# raw data
pums_data = $(RAW_DATA)/il_pums_data.csv
ipums_data = $(RAW_DATA)/il_ipums.csv

# cleaned / processed data
pums_processed = $(CLEAN_DATA)/il_pums_data_clean.csv
ipums_processed = $(CLEAN_DATA)/il_ipums_data_clean.csv

# estimates
estimates = $(ANALYSIS_DATA)/oy_population_estimates.RDS
ipums_estimates = $(ANALYSIS_DATA)/IPUMS_oy_population_estimates.RDS

# visuals
demographics_viz = $(VIZ)/demographic_estimates.pptx
housing_viz = $(VIZ)/household_structure_estimates.pptx

.DEFAULT_GOAL=all

all : $(pums_data) $(ipums_data) $(pums_processed) $(ipums_processed) $(estimates) $(ipums_estimates) $(housing) $(demographics)

$(pums_data): $(SCRIPTS)/download_pums_data.R $(CONFIG)/pums_variables.yaml
	$(R_version) $(SCRIPTS)/download_pums_data.R


$(pums_processed): $(SCRIPTS)/process_pums_data.R $(pums_data) $(functions)
	$(R_version) $(SCRIPTS)/process_pums_data.R
	

$(ipums_processed): $(SCRIPTS)/process_ipums_data.R $(ipums_data) $(functions)
	$(R_version) $(SCRIPTS)/process_ipums_data.R


$(estimates): $(SCRIPTS)/create_population_estimates.R $(pums_processed) 
	$(R_version) $(SCRIPTS)/create_population_estimates.R
	
$(ipums_estimates): $(SCRIPTS)/create_IPUMS_estimates.R $(ipums_processed) 
	$(R_version) $(SCRIPTS)/create_IPUMS_estimates.R

$(housing_viz): $(VIZ)/household_structure_estimates.Rmd $(estimates)
	$(R_version) -e "rmarkdown::render(here::here('create_powerpoint','household_structure_estimates.Rmd'))"
	
$(demographics_viz): $(VIZ)/demographic_estimates.Rmd $(estimates)
	$(R_version) -e "rmarkdown::render(here::here('create_powerpoint','demographic_estimates.Rmd'))"

# shortcuts :)

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

clean: 
		rm -rf $(pums_data)
		rm -rf $(CLEAN_DATA)
		rm -rf $(ANALYSIS_DATA)