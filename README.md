# NLSY97_College_to_Employment
* Last editted: 02/22/2025
* This project is based on my master's thesis in OSU sociology: "Field of Study in College, Employment Divergences, and Gender Wage Gap."
* Check out "Thesis_Defense_Presentation.pdf" for an overview of my project!
* Language used : STATA (50%), R (30%), and LaTeX (20%).

## To-do list
* Reflection: next project should doc "used data" "output" and their location.
* upload data folder
* upload MA-thesis folder
  * upload final tables and figures to STATA_Outputs folder.

## File Structure
```
│── Thesis_Defense_Presentation.pdf
├── Code 
│   ├── 1_csv_to_dta.do
│   ├── 2_0_prepare_data.do
│   │   ├── 2_2_dem.do
│   │   ├── 2_3_dem_timevary.do
│   │   ├── 2_4_edu.do
│   │   ├── 2_4_edu_check.do
│   │   ├── 2_5_emp.do
│   ├── 2_reshape_emp.rmd 
│   ├── 3_1_desc_stats_emp.Rmd
│   ├── 3_1_cleaned.do
│   ├── 3_2_desc.do
│   ├── 3_3_model.do
│   ├── Backup
│   │   ├── 4_1_figure.rmd
├── Data
│   ├── Original_Data
│   ├── Cleaned_Data
│   ├── Weight
│── MA-thesis (Under Construction)
│   ├── STATA_Outputs
│   ├── 0_index.rmd
│   ├── 1_abstract.rmd
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
* (02222025 update) Can upload the key data only, i.e., key input and output data.

## Code
This folder includes STATA and Rmd code on 1) importing NLSY97 raw data, 2) cleaning and reshaping data, 3) analyzing data, step by step.

### Cleaning data
* 1_csv_to_dta.do : Transform raw NLSY97 data (csv) to STATA data format (dta) & label variables.
  * Input : Original_Data/97.csv
  * Output : Cleaned_Data/97.dta
    <br>
* 2_0_prepare_data.do : This is the "run_all_the_code" do file for cleaning data. Executing this will run all the 2_x do.files.
  * Input : Cleaned_Data/97.dta
  * Key output : Cleaned_Data/step12345_wide.csv (yearly, exp employment),  Cleaned_Data/step5_wide.csv (weekly, employment only).
  * 2_2_dem.do : construct time-constant demographic variables. Wide-form.
  * 2_3_dem_timevary.do : construct time-varying demographic variables. Wide-form.
  * 2_4_edu.do : Construct the respondent's college enrollment history, monthly.
    Then, link it to college unique id (which is constructed using college_term_year, c_t_y variable) to identify which college they studied in a given month.
  * 2_4_edu_check.do : Check if there is double enrollment i.e., the respondent enrolled in 2+ college in the same month. These cases are not significant (4%) so I simply kept the first identified value and drop others.
  * 2_5_emp.do : Constructing the respondent's weekly employment history.  <br>
    I classified R's occupational status by classifiying their job by Morgan's (2017) classification.

### Reshaping data (wide --> long)

* 2_reshape_emp.rmd 
  * Input : Cleaned_Data/step1245_wide.csv, ****Cleaned_Data/R/df_control_year.rds (2)****
  * Output : Cleaned_Data/R/long_year.rds, ****Cleaned_Data/R/df_control_year.rds (1)****
  * Purpose : Reshaping the wide form data (weekly), including demographic and employment variables.
  * How to use : You have to manually update the parameter in part 0 and re-run each chunk with label **Re-run**. It should take about an hour to go through every slice of data.

### Analzing data 
#### 3_1_x : Construct key variables: employment movement and educational degree attainment status. Observation starts when the respodent attained their BA degree.
As this study focus on the impact of college major, I selected on those have attained a bachelor's degree by the last available survey. Approximately 25% individuals remain the the analyzed sample.
  
* 3_1_desc_stats_emp.Rmd : 
  * Input : Cleaned_Data/R/long_year.rds, Cleaned_Data/R/df_control_year.rds
  * Output : Cleaned_Data/R/df_sum_cross.dta, Cleaned_Data/R/df_sum_long.dta
  * Purpose : Constructing variables to identify the respondent's change in employment status from year to year, e.g., from full-time employed to part-time employed, or from not employed to full-time employed.
    
* 3_1_cleaned.do
  * Input : Cleaned/R/df_sum_long.dta
  * Output : Cleaned_Data/R/used_M.dta (employment as outcome variable); Cleaned_Data/R/used_Y.dta (wage as outcome variable, and lag employment variable (which is independent variable) for one year);
    Cleaned_Data/R/used_Y_unlagged.dta (wage as outcome variable).
  * Purpose : Drop years where the respondent had no valid employment or wages. Construct three subsets of data for analysis.

#### 3_2, 3_3 : This is where we obtained descriptive statistics, statistical models, and most importantly, tables and figures!
* 3_2_desc.do
  * Input : Cleaned_Data/R/used_M.dta, Cleaned_Data/R/used_Y.dta, Cleaned_Data/R/used_Y_unlagged.dta
  * Output : descriptive statistic tables.
  * Purpose : Obtain descriptive stats of time-constant and time-varying variables. Export tables.
* 3_3_model.do
  * Input : Cleaned_Data/R/used_M.dta, Cleaned_Data/R/used_Y.dta, Cleaned_Data/R/used_Y_unlagged.dta
  * Output : Event history analysis results table, growth curve model results tables, figures.
  * Purpose : Conduct multilevel regression analysis, making margin plots.
* Backup
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

## MA-thesis
* This folder contain 1) a folder "STATA_Outpus", chosen tables and figures from 3_2_desc.do and 3_3_model.do, and 2) Rmarkdown documents written in LaTeX for reporting and visualization.

## Visualization and Outputs
Please find them in MA-thesis/STATA_outputs.

## Research Context
This analysis is a core component of my master's thesis, which is currently being revised for submission to an academic journal. Please respect the originality and do not use these ideas without permission.

## Final Thoughts
Dealing with NLSY97 data (especially the college history) can be challenging. I hope this helps you go through the process. I am not sure whether sharing open-source knowledge is common in the social science discipline, especially in sociology, but I think it can help us conquer technical constraints and invest our time in building up new ideas.

## Contact
For questions or collaborations, feel free to reach out kuo.355@buckeyemail.osu.edu.

## Speical Thanks
I want to thank my advisor, Vincent Roscigno, for supporting me along with this project, and David Melamed for giving me the idea of restructuring large-size data.










