* Last editted: 08/10/2024
* This do flie is for cleaning the data.

* To-do list
* Step 2: 
* Step 3: 
* Step 4: Ensure consistency of field of study before and after 2010.

* Important notes 
* 1: Step 4 has not been checked yet in terms of changing work directory of 2_4_edu.
* 2: The final products will limit to those ever attended college. 

/******************************************************************************/
/*1: Set up & load data*/
/******************************************************************************/
	
	* for Macbook
	/*
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	*/
	
	
	* for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	
	use "97.dta", clear

/******************************************************************************/
/*2: Clean demographic variables: bdate, fmdate, #childs, degree_date         */
/******************************************************************************/

	* Load data
	
	
	* for Macbook
	/*
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	*/
	
	
	* for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	
	use "97.dta", clear

	* execute code for cleaning
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Code"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Code"
	
	run "2_2_dem.do"
	 
	* save output
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	
	save "save_orig.dta", replace
	save "step1_step2.dta", replace
	 
/******************************************************************************/
/*3: Clean demographic variables - time-varying controls                      */
/******************************************************************************/
	
	* Load data
	
	
	* for Macbook
	/*
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	*/
	
	
	* for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	use "97.dta", clear
	
	* execute code for cleaning
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Code"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Code"
	
	do "2_3_dem_timevary.do"
	 
	 * save output
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	
	save "step3.dta", replace
	 

/******************************************************************************/
/*4: Clean demographic variables - time-varying EDU                           */
/******************************************************************************/	 
	
	*********** Step 1 : Know id's major & 2nd major by month/year ***********
	* CAUTION : This takes about 60-90 minutes to execute.
	**************************************************************************
	
	// start by copy a data file in the working folder
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	use "save_orig.dta", clear
	
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\2_4_edu"
	save "save_orig_forstep4.dta", replace
	
	// Subsetting the data (The sample size is too big) --> Reshape and Merge

	forvalues i = 1(100)9101 {
		
		// Load the original data
		cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\2_4_edu"
		
		use "save_orig_forstep4.dta", clear
		
		// Subsetting the data
		local upper = `i' + 99
		keep if id >= `i' & id <= `upper'
		save "save.dta", replace
		use "save.dta", clear

		dis `i'
		
		// Run data extracting code
		cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Code"
		do "2_4_edu" // Run the cleaning script

		// Save the processed data
		save "major_`i'.dta", replace

		// Append the current chunk to the combined dataset
		if `i' > 1 {
			dis `i'
			local j = `i' - 100 
			dis `j'
			append using "major_`j'.dta"
			sort id
			save "major_`i'.dta", replace
		}
		
	}
	
	* Should encounter error after saving major_8901.dta
	* The final data is stored as "major_9001.dta" (id~9022)
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\2_4_edu"
	use "major_9001.dta", clear
	
	sum id
	*hist id
	
	// Finally, label college_enrollment_monthly_history
	
	/* 08/27
	
	Some of them did not match with college_c_t_y data.
	
	*/
	
	// Final check bf save.
	label define vlenroll_college 1 "Not enrolled" 2 "2y college" 3 "4y college" 4 "Grad" 
	label values enroll_college* vlenroll_college
	
	replace college_2major_field = 9 if college_2major_field == .
	replace college_2major_app = 9 if college_2major_app == .
	replace college_2major_stem = 9 if college_2major_stem == .

	// Load the combined dataset and save it with a final name
	save "2_4_edu.dta", replace

	*********** Step 2 : check R's multiple enrollment within the same month ***********
	
	* Check double enrollment
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\2_4_edu"
	use "2_4_edu.dta", clear
	
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Code"
	run "2_4_edu_check" 

	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"

	save "step4.dta", replace
	
	
/******************************************************************************/
/*5: Clean demographic variables - time-varying EMP                           */
/******************************************************************************/
	
	* remember to change work directory.
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	use "save_orig.dta", clear
	
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Code"
	run "2_5_emp.do"	
	
	* Save
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	save "step5.dta", replace
	
	// For reshaping to Yearly form in R
	export delimited step5_wide.csv, replace
	
/******************************************************************************/
/*6: Keep used variables and merge all files.                                 */
/******************************************************************************/	 
	
	* Locate work directory
	
	
	* for Macbook
	/*
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	*/
	
	
	* for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	
	******************************************************************************
	* From Step 1 & 2: Time-invariant vars & Date of int, birth, mar, childbirth *
	******************************************************************************
	
	* Load file
	use "step1_step2.dta", clear
	
	* Keep use variables 
	#delimit ;
		 keep 
		 id gender race edu* citizen *_edu fam_inc asvab*
		 intdate* lstsurvy lstsurv_date bdate fm_date fm_status* child* degree_date_*
	     ; 
	 #delimit cr  
	 
	 
	 * save file
	 save "step1_step2_kept.dta", replace
	 
	*********************************************************************
	* From Step 3: Time-varying vars fam_inc, region, enrollment status *
	*********************************************************************
	
	* Load file
	use "step3.dta", clear
	
	* Keep use variables 
	#delimit ;
		 keep 
		 id census_region_* census_msa_* enroll_* weight_* 
	     ; 
	 #delimit cr  
	 
	 * save file
	 save "step3_kept.dta", replace
	 
	********************************************************************
	* From Step 4: Monthly history of type of college & field of study *   
	********************************************************************
	
	* Load file
	use "step4.dta", clear
	
	* Keep use variables
	#delimit ;
		 keep id college_major_orig college_major_field college_major_app college_major_stem
		 attend_cont_month c t y 
	     ; 
	 #delimit cr  

	 * save file
	 save "step4_kept.dta", replace
	 
	********************************************************************
	* From Step 5: WEEKLY Employment History *   
	********************************************************************
	
	* Load file
	use "step5.dta", clear
	
	* Keep use variables
	#delimit ;
		keep id week_job_id_* week_job_hour_* week_job_full_* week_job_sat_* week_job_status_*
		week_job_wage_* week_job_allwage_* week_job_8egp_* week_job_12egp_* week_job_occ_* week_job_ind_*
	     ; 
	 #delimit cr  

	 * save file
	 save "step5_kept.dta", replace
	 
	********************************************************************
	* Merge by ID & Reshape *   
	********************************************************************
	
	* 1) merge step4 w/step12, only child_* has form of var_`cont_month'
	use "step4_kept.dta", clear
	merge m:1 id using "step1_step2_kept.dta"
	sort id attend_cont_month
	*keep if attend_cont_month != .
	drop _merge
	
	list id gender race ///
	edu_degree degree_date_BA attend_cont_month college_major_field  in 1/50
	
	list id edu_degree degree_date_BA if edu_degree >= 3 & edu_degree < 5 & degree_date_BA == .
	
	********** START -- find R's last field of study bf attaining BA. **************
		
		// Simplify the categories across college_major*
		fre college_major_field 
		replace college_major_field = . if college_major_field == 8
		replace college_major_field = . if college_major_field == 9
		
		fre college_major_stem
		replace college_major_stem = . if college_major_stem == 8
		replace college_major_stem = . if college_major_stem == 9
		
		fre college_major_app
		replace college_major_app = . if college_major_app == 8
		replace college_major_app = . if college_major_app == 9
		
		// gen applied X STEM
		fre college_major*
		tab college_major_stem college_major_app, m
		recode college_major_app (0 8 = 0 "Nonoe or not yet declared") (1 = 1 "Applied STEM") (100 = 2 "Applied non-STEM") (2 = 3 "Academic STEM") (200 = 4 "Academic non-STEM") (. = .), gen(college_major_apst)
		replace college_major_apst = 1 if college_major_app_ == 1 & college_major_stem == 1
		replace college_major_apst = 2 if college_major_app_ == 1 & college_major_stem == 2
		replace college_major_apst = 3 if college_major_app_ == 2 & college_major_stem == 1
		replace college_major_apst = 4 if college_major_app_ == 2 & college_major_stem == 2
		fre college_major_apst
		lab var college_major_apst "R's college major, applied/STEM"
		
		// Drop those college credits after BA degree. They may be continued edu or grad degree.
		list id attend_cont_month degree_date_BA college_major_field if attend_cont_month > degree_date_BA & attend_cont_month != . & degree_date_BA != . in 1/50
		list  id attend_cont_month degree_date_BA college_major_field if id == 9
		drop if attend_cont_month > degree_date_BA & attend_cont_month != . & degree_date_BA != .
		
		save "test.dta", replace
		// Identify the last field of study as R's college major
		use "test.dta", clear
		sort id attend_cont_month
		bysort id: gen group_count = _N
		bysort id: gen id_count = _n
		
		gen flag_major = 1 if group_count == id_count
		
		// Check if there's any cases have "0 None or Undeclared Major" at the last round before BA attainment
		list id attend_cont_month degree_date_BA college_major_apst ///
		if flag_major == 1 & college_major_apst == 0 & !missing(degree_date_BA) /* Only 9 cases. */
		
		foreach n of numlist 380 2215 2979 3331 3615 4112 6229 6556 8993{
			
			list id attend_cont_month degree_date_BA college_major_apst group_count id_count if id == `n'
		}
		
		// Replace 4 cases that have valid majors before BA.
		foreach n of numlist 2215 2979 6229 6556 {
			
			drop if id == `n' & flag_major == 1
			
		}
		
		replace flag_major = 1 if id == 2215 & group_count == 10 & id_count == 9
		replace flag_major = 1 if id == 2979 & group_count == 9 & id_count == 8
		replace flag_major = 1 if id == 6229 & group_count == 26 & id_count == 25
		replace flag_major = 1 if id == 6556 & group_count == 4 & id_count == 2
		
		list id college_major_apst flag_major if id == 2215 | id == 2979 | id == 6229 | id == 6556
		
		// Replace those with no BA degree 
		replace college_major_stem = . if edu_degree < 3
		replace college_major_app = . if edu_degree < 3
		replace college_major_apst = . if edu_degree < 3
		
		// Keep those with flag_major == 1
		keep if flag_major == 1
		tab edu_degree college_major_apst, m 
		list edu_degree degree_date_BA degree_date_MA degree_date_PHD degree_date_PROF college_major_apst ///
		if edu_degree >=3 & edu_degree <5 & degree_date_BA == .
		sum id
		
		*save "test.dta", replace
		
	********** END -- find R's last field of study bf attaining BA. **************
	*use "test.dta", clear
	
	* 2) merge w/step3, where census_region_* & census_region_* have form of var_`cont_month'
	merge 1:1 id using "step3_kept.dta"
	drop _merge
	// Check if accidentally drop R that never gone to college.
	sum id /* Should = 8,984 */
	
	* 3) merge w/step5, emp_`cont_month' 
	*merge 1:1 id using "step5_kept.dta"
	*drop _merge
	
	* 5 ) save wide form data
	save "step12345_wide.dta",replace
	export delimited step12345_wide.csv, replace
	sum id /* Should = 8,984 */
	*********************************************************
	/*
	
	* 5) reshape from wide to long
	use "step12345_wide.dta", clear
	
	// The data size is too big. Try split it, reshape it seperately, then merge it back.
	forvalues i = 1(100)9101 { /* upper bound should be 9101 */
		
		// Load the original data
		cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
		*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
	
		use "step12345_wide.dta", clear
		
		// Subsetting the data
		local upper = `i' + 99
		keep if id >= `i' & id <= `upper'
		save "step12345_wide_subset.dta", replace
		use "step12345_wide_subset", clear

		dis `i'
		
		// Reshape the subset data
		#delimit ;
	
		reshape long child_res_ child_nonres_ child_all_ 
		census_region_ census_msa_ weight_ enroll_college_ 
		week_job_id_ week_job_hour_ week_job_full_ week_job_sat_
		week_job_wage_ week_job_allwage_ week_job_12egp_ week_job_occ_ week_job_ind_, i(id) j(cw)
			
		 ; 
	    #delimit cr  

		// Save the processed data
		save "long_`i'.dta", replace

		// Append the current chunk to the combined dataset
		if `i' > 1 {
			dis `i'
			local j = `i' - 100 
			dis `j'
			append using "long_`j'.dta"
			sort id
			save "long_`i'.dta", replace
		}
		
	}
	 
	 // Save the combined data
	 sum id
	 quietly compress
	 save "step12345_long.dta", replace
	 
	 * 6) Use time-invaraint vars to gen time-varying var
	 use "step12345_long.dta", clear
	 by id: gen count_group = _N
	 by id: gen count_id = _n
	 list id cw fm_date child* degree_date* if id <= 20 & count_group == count_id
	 format fm_date %12.0f /* Switch between cont.month and monthly date. */
	 
	 // fm_date
	 gen flag_fm = .
	 replace flag_fm = 0 if fm_date != .
	 replace flag_fm = 1 if cw >= fm_date & fm_date != .
	 lab var flag_fm "Indicator of First Marriage Status"
	 list cw fm_date flag_fm if id == 3 
	 
	 // degree_date_HS, AA, BA, MA, PHD, PROF
	 list id cw fm_date child* degree_date* if id <= 20 & count_group == count_id
	 local varlist AA BA MA PHD PROF 
	 foreach var in `varlist'{
	 	
		gen flag_`var' = .
		replace flag_`var' = 0 if degree_date_`var' != . /* Mark those valid "no degree". Diff. from missing. */
		replace flag_`var' = 1 if cw >= degree_date_`var' & degree_date_`var' != .
		lab var flag_`var' "Indicator of `var' Status"
		
	 }	
	 
	 sort id cw
	 list id cw flag_AA flag_BA if id == 3 
	
	/* 0830
	
	fm_date & degree_date should distinguish "unknown i.e. missing" and "not yet attained"
	
	*/
	
	// Drop vars storing date. We have transformed them to long-form format.
	drop fm_date intdate* degree_date_*
	
	// Drop other vars -- they will not be needed in the analysis.
	drop attend_cont_month c t y 
	
	***************************
	* Rename and Relabel vars *   
	***************************
	fre enroll_college
	gen enroll_orig_college = enroll_college
	drop enroll_college
	recode enroll_orig_college (-4/1 = 0 "Not enrolled") (2 =1 "2y college") (3 = 2 "4y college") ///
	(4 = 3 "Grad school") (. = 4 "Missing"), gen(enroll_college)
	fre enroll_college
	drop enroll_orig_college
	
	fre census_msa
	gen orig_census_msa = census_msa
	drop census_msa
	recode orig_census_msa (0 = 0 "Non-MSA") (1 = 1 "MSA") (5 = 5 "Missing") , gen(census_msa)
	fre census_msa
	drop orig_census_msa
	
	* Keep use variables
	#delimit ;
		 keep id 
		 
		 * Time-invariant demo.
		 gender race p_edu edu_degree citizen fam_inc asvab 
		 bdate 
		 * Time-varying demo.
		 census_msa census_region child_* enroll_college_ weight_ flag_*
		 * College
		 college_major_field college_major_app college_major_stem
		 *Employment
		 week_job_wage week_job_allwage_ week_job_hour week_job_full 
		 week_job_occ weeK_job_ind week_job_12egp
		 week_job_id week_job_sat 
		 
	     ; 
		 
	 #delimit cr  
	
	describe
	*********************
	* Save cleaned data *   
	*********************
	quietly compress
	save "97_cleaned.dta", replace
	 
	 */
/******************************************************************************/
/*99: Done                                                      */
/******************************************************************************/
*log close












































