# Project Overview










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
    - 


Most of these variables are straight forward. _AGEP_ is numeric and we are able to set bounding values to identify youth (older than 16 and younger than 25 years old). _SCH_ is categorical and contains a value indicating whether or not someone has attended school within the last three months. 

The values in work related variables are less straight forward and contain a variety of ways through which we might identify opportunity youth. 

For example, being laid off from work might be an involuntary condition. We migth exclude this if individuals want to work, but are subject to layoff. However, if someone answers that they are not laid off, but also not working, we might include them in our sample. 




# Project Log

*9/16/2020*
- 