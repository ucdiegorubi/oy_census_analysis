CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT:=$realpath $(CURRENT_DIR)/../)
RAW_DATA = $(PROJECT_ROOT)/raw_Data
CLEAN_DATA = $(PROJECT_ROOT)/CLEAN_DATA
ANALYSIS_DATA = $(PROJECT_ROOT)/analysis_data
SCRIPTS = $(PROJECT_ROOT)/R
CONFIG = $(PROJECT_ROOT)/configuration_files

# outputs 
pums_data = $(RAW_DATA)/il_pums_data.csv
pums_processed = $(CLEAN_DATA)/il_pums_data_clean.csv
estimates = $(ANALYSIS_DATA)/oy_population_estimates.RDS


pums_data: $(SCRIPTS)/download_pums_data.R $(CONFIG)/pums_variables.yaml
		Rscript $(SCRIPTS)/download_pums_data.R

pums_processed: $(SCRIPTS)/process_pums_data.R $(pums_data)
		Rscript $(SCRIPTS)/process_pums_data.R

estimates: $(SCRIPTS)/create_population_estimates.R $(pums_processed)
		Rscript $(SCRIPTS)/create_population_estimates.R

clean: 
		rm -rf $(RAW_DATA)
		rm -rf $(CLEAN_DATA)
		rm -rf $(ANALYSIS_DATA)