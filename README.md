# NLSY97_College_to_Employment
* Last editted: 02/21/2025
* This project is based on my master's thesis in OSU sociology: "Field of Study in College, Employment Divergences, and Gender Wage Gap."

## File Structure
```
├── Code 
│   ├── 1_csv_to_dta.do
│   ├── 2_0_prepare_data.do
│   │   ├── 2_2_dem.do
│   │   ├── 2_3_dem_timevary.do
│   │   ├── 2_4_edu.do
│   │   ├── 2_4_edu_check.do
│   │   ├── 2_5_emp.do
│   ├── 3_.do
│   ├── Backup
│   │   ├── 2_5_emp_week.do
│   │   ├── 4_1_figure.rmd
├── Data
│   ├── Original_Data
│   ├── Cleaned_Data
│   ├── Weight
├── Documents_and_Construction_of_Key_Vars
├── varlist.xlsx
├── Readme_when_download_new_NLSY97.txt
```

## Overview
This repository provides a guide for constructing college history, classifying fields of study based on US Census program codes, 
building employment and wage history, and categorizing occupational status following 
[Steve Morgan's (2017) EGP 12-class classification](https://gss.norc.org/content/dam/gss/get-documentation/pdf/reports/methodological-reports/MR125.pdf).

## Data
* The data used in this project is from the public-use NLSY97 database (National Longitudinal Survey of Youth 1997). 
* Only selected variables (see var_list.xlsx) are included. If additional variables are needed, please refer to the [official NLSY website](https://www.nlsinfo.org/investigator/pages/home).
* (02212025 update) Data files are not included in this repository! Still figuring out how to store large data here.

## Code
This folder includes STATA and Rmd code on 1) importing NLSY97 raw data, 2) cleaning and reshaping data, 3) analyzing data, step by step.

### Cleaning data
* 1_csv_to_dta.do : Transform raw NLSY97 data (csv) to STATA data format (csv) & label variables.
* 2_0_prepare_data.do : This is the "run_all_the_code" do file for cleaning data. Executing this including running all the do.file in its next level.
  * 2_2_dem.do : construct time-constant demographic variables. Wide-form.
  * 2_3_dem_timevary.do : construct time-varying demographic variables. Variable's naming format: var_`month'. Wide-form.
  * 2_4_edu.do : Construct the respondent's college enrollment history, monthly. Then, link it to college unique id (which is constructed using college_term_year, c_t_y variblae) to identify field of study.
  * 2_4_edu_check.do : Check if there is double enrollment i.e., the respondent enrolled in 2+ college in the same month. These cases are not significant (4%) so I simply kept the first identified value and drop others.
  * 2_5_emp.do : Constructing the respondent's weekly employment history.  <br>
    I classified R's occupational status by classifiying their job by Morgan's (2017) classification.

* Reshape data: So now the full wide form data, containing the respondents' college major and weekly employment history (weekly), is prepared. 
* ###### Re-check what's the output of 2_5_emp.do? Weekly or monthly? Does it match with reshape Rmd?
* ###### Reflection: next project should doc "used data" "output" and their location.
 

### Analzing data 
To accelarate the process, I selected on those have attained a bachelor's degree by the last available survey. Approximately 25% individuals remain the the analyzed sample.
* 3_1_cleaned.do (02222025 note: Check this on office-PC. This file is blank on personal's.)
* 3_1_desc_stats.Rmd : 
* 3_1_desc_stats_emp.Rmd : Classifying the respondent's employment dynacmics from month to month. Specifically their change in occupational status, change in employment status, and change in employers. Every trunk after "# Export data" is for reference; they are codes for risk model and GLM in R. I did not use them in my analysis as I did all my analysis in STATA to ensure consistency.
* 3_2_desc.do : 
* 3_3_model.do
* Backup
  * 2_5_emp_week.do : If one planned to analyze weekly instead of monthly data, check out this file. Remember you may like to construct other time-varying variables in weekly manner as well.
  * 4_1_figure.rmd : Alternatively, one can use R for visualizing results. Samples for visualizing descriptive stats and linear regression are included.


## Documents_and_Construction_of_Key_Vars
This folder includes:
* NLSY official guide on constructing college and employment history
* NLSY97 official guide on occupational codes
* US Census classification of college fields of study
* Morgan (2017)'s occupational class classification
* A crosswalk document mapping coding changes across waves

## Merging New Data
* The repository includes varlist.xlsx, which contains a list of variables currently available in this dataset. Before using new variables, check this file to see if your target variable is already included.
* If your required variable is missing, retrieve the data from the NLSY97 official website and merge it into this dataset.
* Follow the instructions in Readme_when_download_new_NLSY97.txt when merging new data to maintain consistency.

## Research Context
This analysis is a core component of my master's thesis, which is currently being revised for submission to an academic journal. Please respect the originality and do not use these ideas without permission.

## Final Thoughts
Dealing with NLSY97 data (especially the college history) can be challenging. I hope this helps you go through the process. I am not sure whether sharing open-source knowledge is common in the social science discipline, especially in sociology, but I think it can help us conquer technical constraints and invest our time in building up new ideas.

## Contact
For questions or collaborations, feel free to reach out kuo.355@buckeyemail.osu.edu.

## Speical Thanks
I want to thank my advisor, Vincent Roscigno, for supporting me along with this project, and David Melamed for giving me the idea of restructuring large-size data.










