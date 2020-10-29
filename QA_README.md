Author: Carrie McGillen
Date: 10/21/20
Project: Thrive OY Census
Description: All the scripts that have been QA'd are listed below, along with any comments about those scripts

#script setup
looks good!


#download pums data
I can't comment on the rep_weights and recode from the pums_paramaters b/c I'm not familiar, but besides that, it all looks good and code does what it says! And wow this is really amazing work.


#process_pums_data
There's a parsing failure that you noted in the readme related to the SCH variable, but there's also parsing failures related to the variable MIG. 

RESOLVED:
line 30 where you identify Chicago PUMAs, I had to make changes to the function source script identify_chicago_PUMA --I added a dplyr:: before filter and pull on lines 12 and 14. Otherwise it was trying to read filter from the stats package, and I have no idea what package it was trying to use for pull (!)

RESOLVED:
line 36 where you add other indicators, I made one change to the function source script pums_indicators, line 144 changing to right=FALSE to align with the break labels.


#process_ipums_data
all good!


#create_population_estimates
Line 36 Would love a walk-thru of how the numeric_estimate function works.

Line 41 Mabye change "Percent" to "Mean" since this function is used to calculate grouped mean. 

Line 96 There's a filter that doesn't appear in any of the other create estimates lines--it seems important if you aim to exclude the non-youth in "Everyone Else" and still have the grouped percentages add up to 100%. 
filter(oy_flag != "everyone_else")

I could use a walk-thru of how the srvyr package works. In particular how the weights are applied and how to use the commands to get estimates. I did compare the values resulting from the srvyr package to crosstabs in the raw pums_df (filtered for chicago) for the variables of interest, and they looked similar to what srvyr produced (albeit a bit different due to the weights I imagine), so it does appear the code is doing what it says.

In 'process map data' function, I'm assuming PUMACE10 in the geopolygon object is the same thing as PUMA.

Line 200 did you mean to create estimate grouping by oy_flag & oy_hh_flag? Isn't this redundant?

Line 233 NOC (Number of Children) has some -1 values, which needs some investigating if it is to be used. Maybe lots of people giving children away lately? 


#create_ipums_estimates
all good! same thing as above regarding the srvyr package above (I could use a walk-thru and dont totally get it), but it does look like you set it up exactly as the example in git, so that seems right.


#presentation_setup
short and sweet and all good!


#household_structure_estimates.rmd--410 lines
Lines 42-44 are commented out, but FYI they give an error if they aren't. I'm being inconsistent about reviewing commented out code FYI.

Lines 58-59 results in warnings (Input must be a vector, not a 'sfc_MULTIPOLYGON/sfc' obect; and another that says argument is not an atomic vector; coercing). I did have some worries that filtering out the "everything else" rows at this point in the process will screw up the grouped percentages, but I'd like to talk this thru--I think it may actually be fine? And it looks like you do the filtering out in the plots themselves, but let's chat...

Line 95 I had to add ggsci to the p_load in presentation_setup.

Line 149 Shouldn't the ymin for the "error_bar_setting" be percent_low? Normally I see error bars on both sides.

Line 151 Add if_else statement in case any percentages are <.05:
    geom_text(aes(label = if_else(percent > .05, 
                                  scales::percent(percent, digits = 3),
                                  "")), 
              position = position_stack(vjust = .5)) +
              
Line 178 Does what it says, but might be interesting to try a stacked bar instead with Connected and Opportunity on the x-axis, and HH/Non HH in the stack.

Line 193 I'm missing the "basic_plot_dodge" function, so this chunk didn't run.

Line 238 Same comments as above re: ymin for the error bar setting. Also, should be household total income, not person's total income (I think), and the caption doesnt make sense here--'caption = "Cells representing less than 5% suppressed for clarity"'.

Line 283, 296, 311 no basic_plot_dodge

Line 340 onwards the N/A in some of the legends looks a little weird--says "NA (GQ/vacant)"

Migration Status I don't totally get the levels (puerto rico, nonmovers?), but you can speak to this in the text.


#demographic_estimates.rmd

Line 40 code will do what it says, but same worry as above about taking out the "Everyone else" and how that will affect percentages. I think it's fine, but want to talk it thru. 

Line 57 the code seems right to recode the oy_flag's levels, but there is no analysis_data$q2_household that I can tell.

Line 72 Same comment as above about "error bar low"--consider using the actual bar? 

Line 199 I'd add the caption at the bottom for suppression of low percentages. Might change the colors too if you have time so it's easier to distinguish between categories.

Line 414 Combine categories? Also add the caption for suppression of low percentages.

Line 534 Title should probably say something about showing Percentage Male.

Line 554 Formatting needed for percentages, title indicating percentage male is shown, remove gridlines, etc.

Line 573 I think this will be awesome once the formatting is added. Might consider doing opp youth as a % of all youth, or a % of total population in order for fair comparison between PUMAs, being clear about the measure in the title.


Wow, such great work! Overall, really not much editing to do. I'm really impressed with the efficiency of the code. It's a large amount of work done in a short number of scripts. Well done!