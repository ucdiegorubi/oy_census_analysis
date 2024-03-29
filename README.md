# Project Overview

The overall goal of the project is to generate a demographic / descriptive analysis of Opportunity Youth in Chicago using U.S. Census data from the American Community Survey (ACS). 

Poverty Lab received a set of research questions of interest from Thrive Chicago that focused on two broad categories: demographics and household structure. 

Demographics:
- We focus largely on traditional demographics

Household structure:
- Poverty Lab's guidance was to focus on the following
        - Number of children
        - Income characteristics
        - Mobility
        
Questions for household structure were worded somewhat ambiguously which gave Poverty Lab the liberty to approach that question using the ample data available in the ACS. 

# File Structure (PUMS)

We use Public Use Microdata Files (PUMS) files. These are deidentified files that are a subsample of the actual survey that is administered each year. Each row in the file is an individual response but each file contains a weighting variable (**PWGTP**) used to convert those individual responses to population estimates.

Our file corresponds to the following:

- State of Illinois, subset to the City of Chicago.
- Year: 2018
- ACS 1-Year File (there are 1-year and 5-year files)

# File Structure (IPUMS)

File structure for IPUMS data is the same. THe main differences are the variables are named differently and additional variables are added which help in analysis. 

# Directory Structure:

* raw_data: 
    - contains a crosswalk between PUMA areas and various other geographic areas
    - contains the raw PUMA download from the ACS
    - contains the raw IPUMS download from IPUMS USA
    
* configuration_files:
    - contains a few configuration files that contain your census API key, the variables from the PUMS files that we might be interested in, and parameters passed to the function that downloads the data
    
* functions:
    - contains R scripts housing functions that used throughout the analysis. Many of these are functions for cleaning data or helper functions used for visualization.
    
* clean_data: 
    - contains the processed PUMS and IPUMS files used to create population estimates
    
* analysis_data:
    - contains population estimates made from the processed PUMS and IPUMS data

* create_powerpoint:
    - contains RMarkdowns and slide decks that visualize population estimates
    
* temp:
    - contains random scripts related to random requests or random tasks throughout the analysis 


# Relevant Documentation:

[IPUMS website](https://usa.ipums.org/usa/)

* Documentation for the IPUMS website
* Generally your best bet is to go to google and type (variable name IPUMS) and you'll find the relevant documentation


[PUMS documentation](https://www.census.gov/programs-surveys/acs/microdata/documentation.html)

* Documentation for PUMS data from the Census


[PUMS README](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/ACS2018_PUMS_README.pdf?)

* Short document (about 30 pages) that talks about PUMS files and some general things that data users should know 

[PUMS Subjects](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/subjects_in_pums/2018_1yr_PUMS_Subjects.pdf)

* Subject definitions for variables in PUMS files. For example, one variable called _Number of Children(NOC)_ defines the 'number of own children' in a household. The subject definitions more or less explain how the Census thinks about 'own' and how this variable is defined with respect to the head of household.

## Literal codebook
[PUMS Data Dictionary](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/PUMS_Data_Dictionary_2018.pdf)

* The literal codebook that lists all household and person level variables you can find in a PUMS file.

# Important! Instructions for recreating this analysis. 

As of right now, this project does not contain any tools like Packrat or **RENV** for managing package dependencies, so this is the best I can do right now. 

* I'm running the latest version of R (4.0.2)
* We're running on a Linux server

Follow these instructions to build the analysis: 

1. Run the setup.R script

It is located in the top level project directory to download libraries that I used to run this project. I used the 'pacman' library to conditionally download only those libraries that are not available. It should download the most recent versions of every package. 

2. **CENSUS API KEY**

You'll need to input your own U.S. Census API Key to download the data.You'll paste your own API key in the space for 'configuration_files/census_api_key.yaml' file. 

You can get a Census API Key [here](https://api.census.gov/data/key_signup.html)

3. **RUNNING THE ANALYSIS**

_Option 1_
If you have GNU Make installed and are on a Linux machine, 
you navigate within the terminal to the project folder and type **make**. That's it. 
The analysis should build on its own from there. 

_Option 2_

If you do not have GNU Make installed, run the scripts in the **R** folder in this order. 

* download_pums_data.R
* process_pums_data.R
* process_ipums_data.R
* create_population_estimates.R
* create_IPUMS_estimates.R

Then run the RMarkdown scripts in the **create_powerpoint** folder to create the visualizations. The order of these does not matter, but the previous five scripts must have been run ahead of time.

# Identifying opportunity youth in PUMS data:

We identify Opportunity  Youth as those individuals between the ages of about 16 through 24 that are *concurrently* unemployed and not enrolled in school. Using the PUMS files, we can identify these individuals through the followign variables: 

- **AGEP: Identifies age**
- **SCH: School enrollment**
    - 1 / No, has not attended in the last 3 months
- **ESR: Employment status recode** 
    - **Unemployed / Not in labor force**

Most of these variables are straight forward. _AGEP_ is numeric and we are able to set bounding values to identify youth (older than **16** and younger than **24** years old). _SCH_ is categorical and contains a value indicating whether or not someone has attended school within the last three months. We use the **ESR** variable bolded above to indicate employment status. 

# Identifying opportunity youth in IPUMS data:

- **EMPSTAT**: Employment status
- **AGE**: numeric, age of an individual
- **SCHOOL**: school enrollment

# Project Log

*9/16/2020*

*9/25/2020*: 
- First presentation of preliminary results

*10/8/2020:*
 - There are parsing failures when loading pums_df for the SCH variable, which identifies whether or not someone was enrolled in school. 
        - Occurs when I'm first loading the PUMS file directly after downloading in the process_pums_data script. 
        
*10/20/2020*:
- writing documentation for project. I really should have used this project log more often.
- As of this writing this analysis would not work for any other state. We subset for Chicago PUMAs, and this step would fail in any other state as they do not contain PUMAS named "Chicago City". This needs to be made a parameter option.

*11/20/2020*:

- Delivered final presentation to Thrive data team. Presentation consisted of household structure questions and demographic estimates. 

To-do:
- refactor how we calculate estimates. The code is kind of sloppy and includes a lot of unnecessary clutter.
- test workflow with 2019 PUMS file
    - would need 2019 IPUMS file (won't be out for a while as of this writing)
- maybe refactor to use the Drake package for automation? Currently relies on GNU Make which is a Linux program not available on all systems.
- median confidence interval estimates (srvyr package not working , may need survey directly) are inaccurate. 1.96*SE not accurate for median confidence intervals as they are not necessarily symmetric. 