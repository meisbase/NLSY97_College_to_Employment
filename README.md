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
│   ├── 2_5_emp.do (Not used)
│   ├── 2_0_prepare_data.do
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
building employment history, and categorizing occupational status following 
[Steve Morgan's (2017) EGP 12-class classification](https://gss.norc.org/content/dam/gss/get-documentation/pdf/reports/methodological-reports/MR125.pdf).

## Data
* The data used in this project is from the public-use NLSY97 database (National Longitudinal Survey of Youth 1997). 
* Only selected variables (see var_list.xlsx) are included. If additional variables are needed, please refer to the [official NLSY website](https://www.nlsinfo.org/investigator/pages/home).
* (02212025 update) Data files are not included in this repository! Still figuring out how to store large data here.

## Code
Under construction...

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
For questions or collaborations, feel free to reach out kuo.355@buckeyemail.osu.edu

## Speical Thanks
I want to thank my advisor, Vinnie Roscigno, for supporting me along with this project, and David Melamed for giving me the idea of restructuring large-size data.










