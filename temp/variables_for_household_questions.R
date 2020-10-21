tidycensus::pums_variables %>% 
  filter(survey == 'acs1', year == 2018) %>% 
  distinct(var_code, var_label) %>% 
  View()

#
# ADJINC : incoem adjusting
# NP : number of people in household
# TYPE : type of unit
# BDS: number of bedrooms
# FS: yearly food stamp
# LAPTOP: Laptop or desktop - important for applying to jobs
# HISPEED: broadband accesss
# MRGP: first mortgage payment
# RNTP: monthly rent
# TABLET: tablet or other portable wireless computer
# VALP: Property value
# WATP: water cost yearly - should not be relevant in chicago
# GRNTP: gross rent
# GRNPIP: Gross rent as percentage of household income
# HHL: household language
# HHT: household family type
# HINC: househol dincome past 12 months
# HUPAOC: hh presence and age of own children
# LNGI: limited english speaking household
# MULT: multigenerational household
# NOC: Number of own children in household
# NPF: number of persons in family
# OCPIP: selected monthly owner costs
# PARTNER: unmarried partner in household
# PSF: presense of subfamilies in household
# SSMC: same-sex married couple household
# TAXAMT: property taxes
# WIF: workers in family during past 12 months
# ESP: employment status of parents
# MAR: marital status
# MIG: mobility status (lived here one year ago)
# SCHL: educational attainment
# JWAP: time of arrival at work
# JWPD: time of departure for work
# PAOC: presense and age of own children (is this differnt from the above?)
# PINC: total persons income
# POVPIP: income to pvoerty ratio recode
# FJWNP: travel time to work allocation flag?
# 