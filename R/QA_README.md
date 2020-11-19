#Author: Carrie McGillen
#11/18/20

#QA For create_population_estimates 

The "Percent" and "Mean" stuff is still there, but as long as you're keeping track to change labels at the end or whatever, then all good.

Lines 89-96 Here's my understanding: you're trying to get a df that only includes one record per SERIALNO (assume this is like household), and it doesn't matter if the record ends up having the head_hh_flag=TRUE. Note that some records do and some don't. Generally speaking, when multiple records were present for the same SERIALNO, distinct() keeps the one at the top, which looks to generally have the head_hh_flag=TRUE, but I didn't look at all of them. 

Line 294 Re-stating the flag about NOC (Number of Children) having some -1 values. 

Line 322 and 330 to remove "Not" so the code does what it says and removes connected youth who are attending school.--Fixed this and pushed.

Lines 316-17, 387-88, 395-96; 529-30, 535-36, 555-56: I'm think the CI calculation that works for "mean" isn't meant to be applied to other parameters (Parameter +/- 1.96 * se).  Looks like the srvyr package offers confidence intervals for median, but I couldn't get it to work. I imagine you tried the same thing with equally frustrating results. Looks like an bug? https://github.com/gergness/srvyr/issues/101 An alternative could be DescTools::MedianCI, but I'm not sure how to incorporate the survey weights in it, so could take some doing. 
https://rcompanion.org/handbook/E_04.html

Line 348: What is this calculating? There doesn't appear to be a variable fed to the function like the chunk above it fed HINCP into the function. I think I'm prolly missing something here. 

Lines 398-403 are a repeat of the previous chunk--option to delete.

Line 434 Calling this "LAPTOP" doesn't really match what it is, but you do you. 

Line 527 & 554 The comment before both these lines says you're calculating median, but the code says survey_mean. I changed it.