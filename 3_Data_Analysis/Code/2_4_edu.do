



/* Note 08/22/2024 

To-do list
1) Ensure consistency of field of study bf and af 2010.
temporarily follow Quadlin (2010)'s 7 fields of study.
2) Replace unknown first mj w/2major


*/


************ data extracting code from this line (line 5 ~ line 350)*****************	
	/* for Macbook
	
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	
	
	
	* for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	
**# Bookmark #3
	* Testing with first 100 ids
	use "save_orig.dta", clear
	keep if id <= 100
	save "save.dta", replace
	
	*/
		***********************************************
		* Step 1: Reshape college_c_t_y to cont_month *
		***********************************************
		
	*** Hierarchical data structure: id --> survey_year --> school --> term
	*** 1) Renaming college C term T month and year history ***
		cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\2_4_edu"
		use "save.dta", clear
		
		* Max(c) = 8 (YSCH-20400.08.2008) ; Max(t) = 29 (YSCH-20400.01.2017)
		* Start from renaming the var: 0n --> n for 0 < n < 10 
		foreach y of numlist 1997/2011 2013 2015 2017 2019 2021{
			foreach c of numlist 1/8{
				
				foreach t of numlist 1/9{
					
					capture rename YSCH_20400_0`c'_0`t'_M_`y' college_`c'_`t'_M_`y' 
					capture rename YSCH_20400_0`c'_0`t'_Y_`y' college_`c'_`t'_Y_`y'
					
				} 
				
				foreach t of numlist 10/28{
					
					capture rename YSCH_20400_0`c'_`t'_M_`y' college_`c'_`t'_M_`y' 
					capture rename YSCH_20400_0`c'_`t'_Y_`y' college_`c'_`t'_Y_`y'
					
				}
			}
		}
		
		list id college_1_1_M_2000 college_1_1_Y_2000 college_2_1_M_2013 college_2_1_Y_2013 in 1/3
		list college_*_*_*_2001 in 1 
		
		keep id college_*
		
		/*
		
		* remove var that all have missing /* 0827 There is no all-missing vars. */
			// 1. Create a list to store variables with all missing values
			local drop_vars ""

			// 2. Loop over all variables in the dataset
			foreach var of varlist * {
				// 3. Count the number of non-missing observations for each variable
				qui count if !missing(`var')
				
				// 4. If the count is zero, add the variable to the drop list
				if r(N) == 0 {
					local drop_vars `drop_vars' `var'
				}
			}

			// 5. Drop variables with all missing values
			drop `drop_vars'

		*/
		
		describe
		
		save "save_step_1.dta", replace
		
		
		******* reshape college_*_*_M_* *******
		
		use "save_step_1.dta", clear
		
		* 1) keep used vars
		keep id college_*_*_M_*
		
		* 2) Reshape college_c_t_M_survy
		reshape long college_ , i(id) j(c_t_M_y) string
		save "long_cty_m.dta", replace
		drop if college_ == .
		
		* 3) Extract c, t, M/Y from c_t_Y_survy
		gen c = real(substr(c_t_M_y, 1, strpos(c_t_M_y, "_") - 1))
		gen t = real(substr(c_t_M_y, strpos(c_t_M_y, "_") + 1, strpos(substr(c_t_M_y, strpos(c_t_M_y, "_") + 1, .), "_") - 1))
		gen y = real(substr(c_t_M_y, -4, .))
		
		* 4) Check if there's id c t y is unique
		duplicates report id c t y
		duplicates list id c t y 
		drop c_t_M_y
		
		* 5) Rename month_attended and separate month and year
		rename college_ attend_month
		save "merge_month.dta", replace
		
		******* reshape college_*_*_Y_* *******
		
		use "save_step_1.dta", clear
		
		* 1) keep used vars
		keep id college_*_*_Y_*
		
		* 2) Reshape college_c_t_M_survy
		reshape long college_ , i(id) j(c_t_Y_y) string
		save "long_cty_y.dta", replace
		drop if college_ == .
		
		* 3) Extract c, t, M/Y from c_t_Y_survy
		gen c = real(substr(c_t_Y_y, 1, strpos(c_t_Y_y, "_") - 1))
		gen t = real(substr(c_t_Y_y, strpos(c_t_Y_y, "_") + 1, strpos(substr(c_t_Y_y, strpos(c_t_Y_y, "_") + 1, .), "_") - 1))
		gen y = real(substr(c_t_Y_y, -4, .))
		
		* 4 ) Check if there's id c t y is unique
		duplicates report id c t y
		duplicates list id c t y in 1/100 
		
		drop c_t_Y_y
		
		* 5) Rename month_attended and separate month and year
		rename college_ attend_year
		save "merge_year.dta", replace
		
		******* merge college_*_*_Y_* w/college_*_*_M_*  *******
		merge 1:1 id c t y using  "merge_month.dta"
	
		drop if attend_month < 0 & attend_year < 0 
		
		count if attend_year < 0  
		count if attend_month < 0 /* There is some ids with valid M but unknown Y. */
		drop if attend_year < 0 
		drop if attend_month < 0 
		
		count if attend_year == .  
		count if attend_month == . 
		
		* 5) duplicates check
		duplicates report id c t y
		duplicates report id attend_month attend_year
		duplicates list id attend_month attend_year, sepby(id)
		*list id c t y attend* if id == 1 & attend_month == 1 & attend_year == 2002
		*list id c t y attend* if id == 65 & attend_month == 8 & attend_year == 2006
		
		/* 
		   Some ids attend > 1 college/term at the same month_year.
		   Perhaps they enroll in > 1 diff. schools (id == 65) or 
		   there's two semester happening in the same month. e.g.. enroll in winter/summer term (id == 1).
		   
		   Be careful while merging.
		*/
		
		* 6) gen cont. month
		gen attend_cont_month = ym(attend_year, attend_month)
		format attend_cont_month %tm
		list in 1/30
		
		* 7) save data
		drop _merge
		save "merge_cty.dta", replace
	
		*************************************
		* Step 2: Reshape ID to cont_month *
		*************************************
	
	*** Hierarchical data structure: id --> cont.month
		
		use "save.dta", clear
		
		*********** For testing **********
		*keep if id <= 100
		**********************************
		
		* Obs Window: 1997/01-2022/10
		
		/* 
		
		1) Keep the used var. Here I temp. keep only edu monthly vars.
		
		foreach var of varlist CVC_GED CVC_HS_DIPLOMA CVC_AA_DEGREE ///
		CVC_BA_DEGREE CVC_PROF_DEGREE CVC_PHD_DEGREE CVC_MA_DEGREE{
			
			gen degree_`var' = .
			replace degree_`var' = `var' + 239 if `var' > 0 & `var' != .
			
		}
		
		* check: OK
		list CVC_BA_DEGREE degree_CVC_BA_DEGREE in 1/10
		
		*/
		
		* SCH_COLLEGE_STATUS : 1997/01-2022/09 (month 444 - month 752)
		dis ym(1997,01)
		dis ym(2022,09)
		
		fre SCH_COLLEGE_STATUS_2000_10
		
		foreach y of numlist 1997/2022{
			foreach m of numlist 1/9{
				
				rename SCH_COLLEGE_STATUS_`y'_0`m' SCH_COLLEGE_STATUS_`y'_`m'
				
			}
		}	
			
		list SCH_COLLEGE_STATUS_2022_9 in 1/10 
		
		foreach m of numlist 444/752{
			
			local Y = year(dofm(`m'))
			local M = month(dofm(`m'))
			
			gen enroll_college_`m' = .
			capture replace enroll_college_`m' = SCH_COLLEGE_STATUS_`Y'_`M'
			
		}
		
		list enroll_college_752 SCH_COLLEGE_STATUS_2022_9 in 1/10
		
**# Bookmark #4
		
		
		keep id enroll_college_*
	     
		
		
		* 2) reshape the data into cont. month
		
		
			reshape long enroll_college_ , ///
			i(id) j(cont_month) 
			
		
		
		* 3) formatting cont. month
		format cont_month %tm
		list in 1/10
		
		* 4) save data
		save "long_id_month.dta", replace
	
		*************************************
		* Step 3: Merge ID w/college_c_t_y *
		*************************************
		
		use "long_id_month.dta", clear
		rename cont_month attend_cont_month
		merge 1:m id attend_cont_month using "merge_cty.dta", keepusing(c t y)
		keep if _merge == 3 /* delete rows that cont_month doesn't map to col_enroll */
		drop _merge
		sort id attend_cont_month
		list id attend_cont_month enroll* c t y in 1
		
		save "long_id_month_cty.dta", replace
		
		**************************************************
		* Step 4: Merge ID_college_c_t_y w/college_mojor *
		**************************************************
		
		****** 1) Renaming college C term T major ******
		
			use "save.dta", clear
			
			*********** For testing **********
			*keep if id <= 100
			**********************************
			
			* Start from renaming the var: 0n --> n for 0 < n < 10 
			
			* From 1997 to 2009
			fre YSCH_21300_01_01_2000
			fre YSCH_21400_01_01_2000 /* 2nd major */
			
			foreach y of numlist 1997/2009{
				foreach c of numlist 1/8{
					
					foreach t of numlist 1/9{
							
						capture rename YSCH_21300_0`c'_0`t'_`y' college_major_orig_`c'_`t'_`y' 
						capture rename YSCH_21400_0`c'_0`t'_`y' college_2major_orig_`c'_`t'_`y' 
						
						}
						
					}
				}
			
			fre college_major_orig_1_1_2000 college_2major_orig_1_1_2000  
			
			* From 2010 to 2011/2012: var name & major's name changes COD
			fre YSCH_21300_COD_01_01_2010
			fre YSCH_21400_COD_01_01_2010
			
			foreach y of numlist 2010 2011 {
				foreach c of numlist 1/8{
					
					foreach t of numlist 1/9{
							
						* From 2010, 
						capture rename YSCH_21300_COD_0`c'_0`t'_`y' college_major_orig_`c'_`t'_`y'  
						capture rename YSCH_21400_COD_0`c'_0`t'_`y' college_2major_orig_`c'_`t'_`y' 
						
						}	
					}
				}
				
			fre college_major_orig_1_1_2010 college_2major_orig_1_1_2010  
			
			* From 2013 to 2021: From 2013, there is no "term" in var's name.
			fre YSCH_21300_COD_01_2021
			fre YSCH_21400_COD_01_2021
			
			foreach y of numlist 2013 2015 2017 2019 2021{
				foreach c of numlist 1/8{
				
					local t = 1
					
					* From 2013, there is no "term" in var's name.	
					capture rename YSCH_21300_COD_0`c'_`y' college_major_orig_`c'_`t'_`y' 
					capture rename YSCH_21400_COD_0`c'_`y' college_2major_orig_`c'_`t'_`y' 		
					}
				}
		
			fre college_major_orig_1_1_2021 college_2major_orig_1_1_2021 
			
		
		
		****** 2) Re-categorize college major ******
		
		* re-categorize them into 7 fields of study, applied_academic, STEM_non-STEM
		* Start from 1997-2009
		
		foreach y of numlist 1997/2009{
			
			foreach c of numlist 1/8{
				
				foreach t of numlist 1/9{
					
					* recode it to 7 fields
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") (22 23 27 29 30 36 = 1 "Health") (7 = 2 "Business") (1 4 6 9 13 21 25 39 42 45 48 = 3 "STEM") (5 8 10 11 19 26 28 31 32 43 44 47 = 4 "Social Science") (12 = 5 "Education") (2 3 14 15 16 17 18 20 24 33 38 = 6 "Liberal Arts & Humanities") (37 40 41 46 99 = 7 "Others") (61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen (college_major_field_`c'_`t'_`y') 
					
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") (22 23 27 29 30 36 = 1 "Health") (7 = 2 "Business") (1 4 6 9 13 21 25 39 42 45 48 = 3 "STEM") (5 8 10 11 19 26 28 31 32 43 44 47 = 4  "Social Science") (12 = 5 "Education") (2 3 14 15 16 17 18 20 24 33 38 = 6 "Liberal Arts & Humanities") (37 40 41 46 99 = 7 "Others") (61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen (college_2major_field_`c'_`t'_`y') 
					
					capture lab var college_major_field_`c'_`t'_`y' "college major_field of study"
					capture lab var college_2major_field_`c'_`t'_`y' "college 2major_field of study"
					
					* recode it to applied vs. academic
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(22 23 27 29 30 36 12 7 4 9 13 37 39 42 45 48 40 41 46 99 = 1 "Applied") ///
					(5 8 10 11 19 26 31 32 28 1 6 21 25 2 3 14 15 16 17 18 20 24 33 43 44 47 38 = 2 "Academic") ///
					(61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_major_app_`c'_`t'_`y') 
					
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(22 23 27 29 30 36 12 7 4 9 13 37 39 42 45 48 40 41 46 99 = 1 "Applied") ///
					(5 8 10 11 19 26 31 32 28 1 6 21 25 2 3 14 15 16 17 18 20 24 33 43 44 47 38 = 2 "Academic") ///
					(61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_2major_app_`c'_`t'_`y') 
					
					capture lab var college_major_app_`c'_`t'_`y' "college major_applied or academic"
					capture lab var college_2major_app_`c'_`t'_`y' "college 2major_applied or academic"
					
					* recode it to STEM vs. non-STEM
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(4 9 13 1 6 21 25 39 42 45 48 = 1 "STEM") ///
					(5 8 10 11 19 26 31 32 28 2 3 14 15 16 17 18 20 24 33 22 23 27 29 30 36 12 7 37 99 43 44 47 38 40 41 46 = 2 "Non-STEM") ///
					(61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_major_stem_`c'_`t'_`y') 
				
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(4 9 13 1 6 21 25 39 42 45 48 = 1 "STEM") ///
					(5 8 10 11 19 26 31 32 28 2 3 14 15 16 17 18 20 24 33 22 23 27 29 30 36 12 7 37 99 43 44 47 38 40 41 46 = 2 "Non-STEM") ///
					(61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_2major_stem_`c'_`t'_`y') 
					
					capture lab var college_major_stem_`c'_`t'_`y' "college major_stem"
					capture lab var college_2major_stem_`c'_`t'_`y' "college 2major_stem"
				}
			}
			
		}
		
			
		tab college_major_field_1_1_2000 college_major_orig_1_1_2000, m	
		tab college_2major_field_1_1_2000 college_2major_orig_1_1_2000, m	
		
		tab college_major_app_1_1_2000 college_major_orig_1_1_2000, m	
		tab college_2major_app_1_1_2000 college_2major_orig_1_1_2000, m	
	
	    tab college_major_stem_1_1_2000 college_major_orig_1_1_2000, m	
		tab college_2major_stem_1_1_2000 college_2major_orig_1_1_2000, m	
	
	
		* 2010 to 2021, the categorization of orig_major changes.
		foreach y of numlist 2010 2011 2013 2015 2017 2019 2021{
			
			foreach c of numlist 1/8{
				
				foreach t of numlist 1/9{
					
					* recode it to 7 fields
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") (34 51 = 1 "Health") (52 = 2 "Business") (1 3 4 10 11 14 15 26 27 29 40 41 46 47 48 49 30 = 3 "STEM") (9 19 22 25 42 45 = 4 "Social Science") (13 32 33 = 5 "Education") (5 16 23 24 38 39 50 54 = 6 "Liberal Arts & Humanities") (12 28 31 35 36 37 43 44 = 7 "Others") (53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen (college_major_field_`c'_`t'_`y') 
					
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") (34 51 = 1 "Health") (52 = 2 "Business") (1 3 4 10 11 14 15 26 27 29 40 41 46 47 48 49 30 = 3 "STEM") (9 19 22 25 42 45 = 4 "Social Science") (13 32 33 = 5 "Education") (5 16 23 24 38 39 50 54 = 6 "Liberal Arts & Humanities") (12 28 31 35 36 37 43 44 = 7 "Others") (53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen (college_2major_field_`c'_`t'_`y') 
					
					capture lab var college_major_field_`c'_`t'_`y' "college major_field of study"
					capture lab var college_2major_field_`c'_`t'_`y' "college 2major_field of study"
					
					* recode it to applied vs. academic
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(34 51 13 32 33 52 4 10 11 14 15 28 29 41 46 47 48 49 12 31 35 36 37 43 44 = 1 "Applied") ///
					(9 19 22 25 42 45 1 3 26 27 40 30 5 16 23 24 38 39 50 54 = 2 "Academic") ///
					(53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_major_app_`c'_`t'_`y') 
					
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(34 51 13 32 33 52 4 10 11 14 15 28 29 41 46 47 48 49 12 31 35 36 37 43 44 = 1 "Applied") ///
					(9 19 22 25 42 45 1 3 26 27 40 30 5 16 23 24 38 39 50 54 = 2 "Academic") ///
					(53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_2major_app_`c'_`t'_`y') 
					
					capture lab var college_major_app_`c'_`t'_`y' "college major_applied or academic"
					capture lab var college_2major_app_`c'_`t'_`y' "college 2major_applied or academic"
					
					* recode it to STEM vs. non-STEM
					capture recode college_major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(4 10 11 14 15 28 29 41 46 47 48 49 1 3 26 27 40 30 = 1 "STEM") ///
					(9 19 22 25 42 45 5 16 23 24 38 39 50 54 34 51 13 32 33 52 12 31 35 36 37 43 44 = 2 "Non-STEM") ///
					(53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_major_stem_`c'_`t'_`y') 
				
					capture recode college_2major_orig_`c'_`t'_`y' (0 98 = 0 "None or not yet declared") ///
					(4 10 11 14 15 28 29 41 46 47 48 49 1 3 26 27 40 30 = 1 "STEM") ///
					(9 19 22 25 42 45 5 16 23 24 38 39 50 54 34 51 13 32 33 52 12 31 35 36 37 43 44 = 2 "Non-STEM") ///
					(53 60 61 999 = 8 "Not eligible") (-99/-1 = 9 "Missing"), gen(college_2major_stem_`c'_`t'_`y') 
					
					capture lab var college_major_stem_`c'_`t'_`y' "college major_stem"
					capture lab var college_2major_stem_`c'_`t'_`y' "college 2major_stem"
				}
			}
			
		}
		
			
		tab college_major_field_1_1_2010 college_major_orig_1_1_2010, m	
		tab college_2major_field_1_1_2010 college_2major_orig_1_1_2010, m	
		
		tab college_major_app_1_1_2010 college_major_orig_1_1_2010, m	
		tab college_2major_app_1_1_2010 college_2major_orig_1_1_2010, m	
	
	    tab college_major_stem_1_1_2010 college_major_orig_1_1_2010, m	
		tab college_2major_stem_1_1_2010 college_2major_orig_1_1_2010, m	
		
		
		* 3) Reshape college_(2)major_c_t_y *** 
		* Replicate Step 1
		
			* 1) keep used vars
			keep id college_major_* college_2major_*
			
			* 2) Reshape college_(2)major_c_t_y
			reshape long college_major_orig_ college_2major_orig_ ///
			college_major_field_ college_2major_field_ ///
			college_major_app_ college_2major_app_ ///
			college_major_stem_ college_2major_stem_ , i(id) j(c_t_y) string
			save "long_major_cty.dta", replace
			
			fre college_major_orig_ college_2major_orig_
			fre college_major_field_ college_2major_field_
			fre college_major_app_ college_2major_app_
			fre college_major_stem_ college_2major_stem_
			
			* drop rows without useful information
			drop if college_major_orig_ == . & college_2major_orig_ == .
			
			count if college_major_orig < 0 & college_2major_orig == .
			drop if college_major_orig < 0 & college_2major_orig == .
			
			count if college_major_orig < 0 & college_2major_orig < 0
			drop if college_major_orig < 0 & college_2major_orig < 0
			
			* 3) Extract c, t, y from c_t_y
			gen c = real(substr(c_t_y, 1, strpos(c_t_y, "_") - 1))
			gen t = real(substr(c_t_y, strpos(c_t_y, "_") + 1, strpos(substr(c_t_y, strpos(c_t_y, "_") + 1, .), "_") - 1))
			gen y = real(substr(c_t_y, -4, .))
			
			* 4) check Duplicates
			duplicates report id c t y
			drop c_t_y
			
			* 5) Replace missing in 1st major w/2nd major. Only occurs on id == 2786. Temp. skip.
			list id if college_major_field == 9 & college_2major_field != 0 & college_2major_field != 9 &  college_2major_field != .
						
			* 6) save data
			save "long_college_major_cty.dta", replace
		
		* 3) Merge ID_college_c_t_y w/college_(2)_major_c_t_y
		use "long_id_month_cty.dta", clear
		merge 1:1 id c t y using "long_college_major_cty.dta", ///
		keepusing(college_major_* college_2major_*)
		
		sort id attend_cont_month
		list id c t y attend_cont_month college_major_field in 1/50, sepby(id)
		
		* 4 ) Keep those successfully matched
		keep if _merge == 3

			
			
		

