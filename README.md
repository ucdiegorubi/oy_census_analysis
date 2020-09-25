# Project Overview






# Important! Instructions for recreating this analysis. 

As of right now, this project does not contain any tools like Packrat for managing packages, so it's shaky at best.

Follow these instructions to build the analysis: 

1. Run the setup.R script located in the top level project directory to download libraries that I used to run this project. I used the 'pacman' library to conditionally download only those libraries that are not available. 

2. You'll need to input your own U.S. Census API Key to download the data.You'll paste your own API key in the 'configuration_files/census_api_key.yaml' file. 

3. Run 'R/download_pums_data.R' in order to get the Census Data 

4. Run 'R/process_pums_data.R in order to process the downloaded 2018 PUMS file and clean it / prepare it before creating our population estimates.

5. Run 'R/create_population_estimates.R' in order to create the point estimates we've been presenting.

6. Run 'create_powerpoint/viz_population_estimates.Rmd' in order to create the slide deck. 



# Identifying opportunity youth in PUMS data:

We identify Opportunity  Youth as those individuals between the ages of about 16 through 24 that are *concurrently* unemployed and not enrolled in school. Using the PUMS files, we can identify these individuals through the followign variables: 

- AGEP: Identifies age 
- SCH: School enrollment
    - 1 / No, has not attended in the last 3 months

- WKW: Weeks worked during the past 12 months
    - The lowest value indicates working less than 14 weeks
- WRK: Worked last week
    - 
- WKL: When last worked
    - Over 5 years ago
    - 1 to 5 years ago 
- WKHP: Usual hours worked per week during the past 12 months
    - One numeric value indicates 0
    - **Note**: Consider creating a range of values
- NWAB: Temporary absence from work
    - Yes, No, Did not report, N/A (less than 16 years old/at work/on layoff)
- NWAV: Available for work
    - No
    - No, other reasons
    - No, temporarily ill
    - No, unspecified
    - Did not report
- NWLA: On layoff from work
    - Yes
    - No
    - Did not report
- NWLK: Looking for work
    - No
    - Did not report
    - N/A (less than 16 years old/at work/temporarily absent/informed of recall)
- NWRE: Informed of recall
- **ESR: Employment status recode** 
    - **Unemployed / Not in labor force**

Most of these variables are straight forward. _AGEP_ is numeric and we are able to set bounding values to identify youth (older than 16 and younger than 25 years old). _SCH_ is categorical and contains a value indicating whether or not someone has attended school within the last three months. 

The values in work related variables are less straight forward and contain a variety of ways through which we might identify opportunity youth. We use the **ESR** variable bolded above to indicate employment status. 


# Project Log

*9/16/2020*

*9/25/2020*: 
- First presentation of preliminary results
- 