CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT:=$(realpath $(CURRENT_DIR)/../)
R_version= /opt/R/4.0.2/bin/Rscript


RAW_DATA = $(CURRENT_DIR)/raw_data
CLEAN_DATA = $(CURRENT_DIR)/clean_data
ANALYSIS_DATA = $(CURRENT_DIR)/analysis_data
SCRIPTS = $(CURRENT_DIR)/R
CONFIG = $(CURRENT_DIR)/configuration_files

# outputs 
pums_data = $(RAW_DATA)/il_pums_data.csv
pums_processed = $(CLEAN_DATA)/il_pums_data_clean.csv
estimates = $(ANALYSIS_DATA)/oy_population_estimates.RDS

.DEFAULT_GOAL=all

all : $(pums_data) $(pums_processed)

$(pums_data): $(SCRIPTS)/download_pums_data.R $(CONFIG)/pums_variables.yaml
	$(R_version) $(SCRIPTS)/download_pums_data.R


$(pums_processed): $(SCRIPTS)/process_pums_data.R $(pums_data)
	$(R_version) $(SCRIPTS)/process_pums_data.R

$(estimates): $(SCRIPTS)/create_population_estimates.R $(pums_processed)
	$(R_version) $(SCRIPTS)/process_pums_data.R

clean: 
		rm -rf $(pums_data)
		rm -rf $(CLEAN_DATA)
		rm -rf $(ANALYSIS_DATA)