

***************************************************************************************************	
				**************
				* used_M.dta *
				**************

	
	***********************
	* Import data, yearly *
	***********************
	
	// for Office-PC
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data\R"

	// for Macbook
	/*
	pwd
	clear all
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	*/
	
	use "df_sum_long.dta", clear
	summarize
	
	********************
	* Sample Selection *
	********************
	drop if prev_job_full == . /* This is the first wave of each person. There will be no valid shifts to be observed. */
	
		
************
* WARNING
************	

	// Exclude job_ind == Armed Forces
	fre job_ind
	rename job_ind job_ind_save
	recode job_ind_save (-3 . = 99 "Missing") (-4 = 98 "Not employed") ///
	(21 3/7 = 0 "Core") (22 = 1 "Extractive and Other") ///
	(23 15/18 = 2 "High-Wage Service") (24 9/14 19 = 3 "Low-Wage Service") ///
	(25 = 4 "Public Sector") (20 = 5 "Armed Forces"), gen(job_ind)
	fre job_ind
	
	drop if job_ind == 5
	
	*******************
	* Check variables *
	*******************
	// Outcome: Emp transitions
	sum shift_pos shift_neg, d
	lab var shift_pos "Positive Emp. Transitions"
	lab var shift_neg "Negative Emp. Transitions"
	
	// Outcome: Wage
	// Take natural log of wage
	gen wage = ln(job_wage)
	sum wage, d
	count if wage == . /* including wage == 0 & wage == . */
	
	// Gen binary EGP
	fre job_8egp
	gen egp = 8 - job_8egp if job_8egp != .
	tab egp job_8egp, m
	rename egp egp_orig
	recode egp_orig (1/6 = 0 "Class 2~7") (7 = 1 "First-Class"), gen(egp)
	lab var egp "Whether First-Class or not (EGP), binary"
	fre egp
	
	// Generate control for the 1st observed, valid outcome
	global DV "wage egp"
	gen rev_age_BA = -age_BA

	foreach DV in $DV {
		// Generate a variable marking non-missing observations
		bysort id (age_BA): gen valid_`DV' = missing(`DV')

		// Identify the first valid observation for each individual
		bysort id (valid_`DV' age_BA): gen `DV'_first = `DV' if valid_`DV' == 0 & _n == 1

		// Carry backward the first valid observation across all waves
		bysort id (age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
		// Carry forward the first valid observation across all waves
		bysort id (rev_age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
	}
	
	sort id age_BA
	list id year wage if wage_first == . in 1/20
	list id year wage wage_first egp egp_first if id == 1 | id == 3
	
	
	// Replace missing values
	replace child_all = 0 if child_all == .
	rename census_msa census_orig_msa
	recode census_orig_msa (2 = 0 "Non-MSA") (1 = 1 "MSA") (. = 2 "Missing"), gen(census_msa)
	rename job_never job_orig_never
	recode job_orig_never (0 = 0 "Have been Employed for at least once") (1 = 1 "Never been Employed"), gen(job_never)
	
	// Gen binary indicator
	fre child_all
	recode child_all (1/99 = 1 ">=1 child in residence") (0 = 0 "No children in residence"), gen(child_all_bi)
	lab var child_all_bi "R has at least 1 child in residence"
	tab child_all child_all_bi, m
	
	// Gen indicator of grad degree 
	describe flag* /* Used vars: MA, PHD, PROF */
	global grad "flag_date_MA flag_date_PHD flag_date_PROF"
	
	* Replace . year with 0.
	foreach var in $grad{
		replace `var' = 0 if `var' == .
	}
	
	* Replace grad indicator with the earliest attained grad degree
	sort id age_BA
	egen flag_grad = rowmax($grad)
	list id age_BA $grad flag_grad if id == 8
	lab var flag_grad "Indicator of R's Grad Degree Status."
	lab define vlflag_grad 0 "No Grad Degree" 1 "Grad Degree Attained"
	lab values flag_grad vlflag_grad
	fre flag_grad
	
	// Final check vars
	fre gender
	fre age_BA
	fre race
	
	fre census_msa
	fre census_region
	
	fre job_ind
	fre job_never
	
	fre major_apst
	
	fre fm_status
	fre child_all
	
	save "used_M.dta", replace
	
************************************************************************************************
				**************
				* used_Y.dta *
				**************

clear all
	*********************
	* Set up Workplace *
	*********************
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	use "df_sum_long.dta", clear
	summarize

	
	
	
****************************************
* Sample Selection & Var Construction * 	
****************************************
	
************
* WARNING
************	

	// Exclude job_ind == Armed Forces
	fre job_ind
	rename job_ind job_ind_save
	recode job_ind_save (-3 . = 99 "Missing") (-4 = 98 "Not employed") ///
	(21 3/7 = 0 "Core") (22 = 1 "Extractive and Other") ///
	(23 15/18 = 2 "High-Wage Service") (24 9/14 19 = 3 "Low-Wage Service") ///
	(25 = 4 "Public Sector") (20 = 5 "Armed Forces"), gen(job_ind)
	fre job_ind
	
	drop if job_ind == 5
	
	***************************************************************************
	* Wage: 1) exclude not employed 2) missing imputation 3) take natural log *
	***************************************************************************
	// count if id is employed with 0 wages
	fre job_full
	sum job_wage, d
	sum job_allwage, d
	
	gen wage_m = missing(job_wage)
	gen allwage_m = missing(job_allwage)
	
	tab job_full wage_m, m row
	tab job_full allwage_m, m row /* Proportion missing for employed ppl is litte (< 10%). */
	

	
	// Missing imputation
	
	/*  10/29/2024 
		Given that there're too many missing in employed periods,
		I adopt Linear Interpolation to impute missing values by averaging surrounded observed values.
	
	    10/31/2024 
		Perhaps I should simply exclude missing in Dependant variables.
		Since there are fewer missing in job_wage, I will use job_wage instead of job_allwage.
		
	*/
	
	
	// Take natural log of wage
	gen wage = ln(job_wage)
	sum wage, d
	count if wage == . /* including wage == 0 & wage == . */
	
	// Gen binary EGP
	fre job_8egp
	gen egp = 8 - job_8egp if job_8egp != .
	tab egp job_8egp, m
	rename egp egp_orig
	recode egp_orig (1/6 = 0 "Class 2~7") (7 = 1 "First-Class"), gen(egp)
	lab var egp "Whether First-Class or not (EGP), binary"
	fre egp
	
	// Generate control for the 1st observed, valid outcome
	global DV "wage egp"
	gen rev_age_BA = -age_BA

	foreach DV in $DV {
		// Generate a variable marking non-missing observations
		bysort id (age_BA): gen valid_`DV' = missing(`DV')

		// Identify the first valid observation for each individual
		bysort id (valid_`DV' age_BA): gen `DV'_first = `DV' if valid_`DV' == 0 & _n == 1

		// Carry backward the first valid observation across all waves
		bysort id (age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
		// Carry forward the first valid observation across all waves
		bysort id (rev_age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
	}
	
	sort id age_BA
	list id year wage if wage_first == . in 1/20
	list id year wage wage_first egp egp_first if id == 1 | id == 3
	
	****************************
	* Lag cumulative_variables *
	****************************
	global DV "wage egp"

	// Lag the variables without overwriting the originals
	foreach DV in $DV {
		bysort id: replace `DV' = `DV'[_n+1]
	}

	
************
* WARNING
************	
	gen keep_sample = 1 if wage != . 
	replace keep_sample = 0 if keep_sample == .
	
	// person-year
	*table keep_sample gender major_apst, statistic(freq) statistic(percent)
	
	// Drop first person-year of each Individual. There is no valid "treatment" in this wave.
	keep if wage != .		
	
	****************************
	* Gen 1st and Last outcome *
	****************************
	
	// Generate  last observations
	foreach DV in $DV {

		// Generate the last observed value
		bysort id (age_BA): gen `DV'_last = `DV'[_N] if _n == _N /* Last observed wage or EGP */
	}

************
* WARNING
************	
	// Exclude those with only one valid waves. They won't be in part 2 analysis anyway.
	bysort id (age_BA): gen first_age_BA = age_BA[1]
	bysort id (age_BA): gen last_age_BA = age_BA[_N]
	count if first_age_BA == last_age_BA 
	
	// Drop those have only one valid waves left.
	drop if first_age_BA == last_age_BA /* 60 obs deleted. These person-year are part of prev_job_full == . */
	
	lab define vl_egp 0 "Others, class 2~7" 1 "Class 1"
	lab values egp_first vl_egp
	lab values egp_last vl_egp
	
	*******************************
	* tabout 1st and Last outcome *
	*******************************
	preserve
	bysort id (age_BA): keep if _n == _N	
	mean wage_first, over(major_apst gender)
	mean wage_last, over(major_apst gender)
	*table egp_first gender major_apst, statistic(freq) statistic(percent, across(gender)) 
	*table egp_last gender major_apst, statistic(freq) statistic(percent, across(gender)) 
	restore
	
************
* WARNING
************
	// Drop the first observation of each id (No valid IV: emp trans)
	drop if prev_job_full == .
	
	
	*******************
	* Check variables *
	*******************
	// Check IVs
	global IV "cum_shift_pos cum_shift_neg cum_shift_all cum_shift_part"
	foreach var in $IV{
		fre `var'
	}
	
	lab var cum_shift_pos "Positive Emp. Transitions"
	lab var cum_shift_neg "Negative Emp. Transitions"
	
	
	// Replace missing values
	replace child_all = 0 if child_all == .
	rename census_msa census_orig_msa
	recode census_orig_msa (2 = 0 "Non-MSA") (1 = 1 "MSA") (. = 2 "Missing"), gen(census_msa)
	rename job_never job_orig_never
	recode job_orig_never (0 = 0 "Have been Employed for at least once") (1 = 1 "Never been Employed"), gen(job_never)
	
	// Gen binary indicator
	fre child_all
	recode child_all (1/99 = 1 ">=1 child in residence") (0 = 0 "No children in residence"), gen(child_all_bi)
	lab var child_all_bi "R has at least 1 child in residence"
	tab child_all child_all_bi, m
	
	// Gen indicator of grad degree 
	describe flag* /* Used vars: MA, PHD, PROF */
	global grad "flag_date_MA flag_date_PHD flag_date_PROF"
	
	* Replace . year with 0.
	foreach var in $grad{
		replace `var' = 0 if `var' == .
	}
	
	* Replace grad indicator with the earliest attained grad degree
	sort id age_BA
	egen flag_grad = rowmax($grad)
	list id age_BA $grad flag_grad if id == 8
	lab var flag_grad "Indicator of R's Grad Degree Status."
	lab define vlflag_grad 0 "No Grad Degree" 1 "Grad Degree Attained"
	lab values flag_grad vlflag_grad
	fre flag_grad
	
	// Final check vars
	fre gender
	fre age_BA
	fre race
	
	fre census_msa
	fre census_region
	
	fre job_ind
	fre job_never
	
	fre major_apst
	
	fre fm_status
	fre child_all
	
	save "used_Y.dta", replace

************************************************************************************************

		
				***********************
				* used_Y_unlagged.dta *
				***********************
	
clear all
	*********************
	* Set up Workplace *
	*********************
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	use "df_sum_long.dta", clear
	summarize
	
	
****************************************
* Sample Selection & Var Construction * 	
****************************************

************
* WARNING
************	

	// Exclude job_ind == Armed Forces
	fre job_ind
	rename job_ind job_ind_save
	recode job_ind_save (-3 . = 99 "Missing") (-4 = 98 "Not employed") ///
	(21 3/7 = 0 "Core") (22 = 1 "Extractive and Other") ///
	(23 15/18 = 2 "High-Wage Service") (24 9/14 19 = 3 "Low-Wage Service") ///
	(25 = 4 "Public Sector") (20 = 5 "Armed Forces"), gen(job_ind)
	fre job_ind
	
	drop if job_ind == 5
	
	
	***************************************************************************
	* Wage: 1) exclude not employed 2) missing imputation 3) take natural log *
	***************************************************************************
	// count if id is employed with 0 wages
	fre job_full
	sum job_wage, d
	sum job_allwage, d
	
	gen wage_m = missing(job_wage)
	gen allwage_m = missing(job_allwage)
	
	tab job_full wage_m, m row
	tab job_full allwage_m, m row /* Proportion missing for employed ppl is litte (< 10%). */
	

	
	// Missing imputation
	
	/*  10/29/2024 
		Given that there're too many missing in employed periods,
		I adopt Linear Interpolation to impute missing values by averaging surrounded observed values.
	
	    10/31/2024 
		Perhaps I should simply exclude missing in Dependant variables.
		Since there are fewer missing in job_wage, I will use job_wage instead of job_allwage.
		
	*/
	
	
	// Take natural log of wage
	gen wage = ln(job_wage)
	sum wage, d
	count if wage == . /* including wage == 0 & wage == . */
	
	// Gen binary EGP
	fre job_8egp
	gen egp = 8 - job_8egp if job_8egp != .
	tab egp job_8egp, m
	rename egp egp_orig
	recode egp_orig (1/6 = 0 "Class 2~7") (7 = 1 "First-Class"), gen(egp)
	lab var egp "Whether First-Class or not (EGP), binary"
	fre egp
	
	// Generate control for the 1st observed, valid outcome
	global DV "wage egp"
	gen rev_age_BA = -age_BA

	foreach DV in $DV {
		// Generate a variable marking non-missing observations
		bysort id (age_BA): gen valid_`DV' = missing(`DV')

		// Identify the first valid observation for each individual
		bysort id (valid_`DV' age_BA): gen `DV'_first = `DV' if valid_`DV' == 0 & _n == 1

		// Carry backward the first valid observation across all waves
		bysort id (age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
		// Carry forward the first valid observation across all waves
		bysort id (rev_age_BA): replace `DV'_first = `DV'_first[_n-1] if missing(`DV'_first)
		
	}
	
	sort id age_BA
	list id year wage if wage_first == . in 1/20
	list id year wage wage_first egp egp_first if id == 1 | id == 3
	
	****************************
	* Lag cumulative_variables *
	****************************
	/*
	global DV "wage egp"

	// Lag the variables without overwriting the originals
	foreach DV in $DV {
		bysort id: replace `DV' = `DV'[_n+1]
	}

	*/
************
* WARNING
************	
	gen keep_sample = 1 if wage != . 
	replace keep_sample = 0 if keep_sample == .
	
	// person-year
	*table keep_sample gender major_apst, statistic(freq) statistic(percent)
	
	// Drop first person-year of each Individual. There is no valid "treatment" in this wave.
	keep if wage != .		
	
	****************************
	* Gen 1st and Last outcome *
	****************************
	
	// Generate  last observations
	foreach DV in $DV {

		// Generate the last observed value
		bysort id (age_BA): gen `DV'_last = `DV'[_N] if _n == _N /* Last observed wage or EGP */
	}

************
* WARNING
************	
	// Exclude those with only one valid waves. They won't be in part 2 analysis anyway.
	bysort id (age_BA): gen first_age_BA = age_BA[1]
	bysort id (age_BA): gen last_age_BA = age_BA[_N]
	count if first_age_BA == last_age_BA 
	
	// Drop those have only one valid waves left.
	drop if first_age_BA == last_age_BA /* 60 obs deleted. These person-year are part of prev_job_full == . */
	
	lab define vl_egp 0 "Others, class 2~7" 1 "Class 1"
	lab values egp_first vl_egp
	lab values egp_last vl_egp
	
	*******************************
	* tabout 1st and Last outcome *
	*******************************
	preserve
	bysort id (age_BA): keep if _n == _N	
	mean wage_first, over(major_apst gender)
	mean wage_last, over(major_apst gender)
	*table egp_first gender major_apst, statistic(freq) statistic(percent, across(gender)) 
	*table egp_last gender major_apst, statistic(freq) statistic(percent, across(gender)) 
	restore
	
************
* WARNING
************
	// Drop the first observation of each id (No valid IV: emp trans)
	drop if prev_job_full == .
	
	
	*******************
	* Check variables *
	*******************
	// Check IVs
	global IV "cum_shift_pos cum_shift_neg cum_shift_all cum_shift_part"
	foreach var in $IV{
		fre `var'
	}
	
	lab var cum_shift_pos "Positive Emp. Transitions"
	lab var cum_shift_neg "Negative Emp. Transitions"

	// Replace missing values
	replace child_all = 0 if child_all == .
	rename census_msa census_orig_msa
	recode census_orig_msa (2 = 0 "Non-MSA") (1 = 1 "MSA") (. = 2 "Missing"), gen(census_msa)
	rename job_never job_orig_never
	recode job_orig_never (0 = 0 "Have been Employed for at least once") (1 = 1 "Never been Employed"), gen(job_never)
	
	// Gen binary indicator
	fre child_all
	recode child_all (1/99 = 1 ">=1 child in residence") (0 = 0 "No children in residence"), gen(child_all_bi)
	lab var child_all_bi "R has at least 1 child in residence"
	tab child_all child_all_bi, m
	
	// Gen indicator of grad degree 
	describe flag* /* Used vars: MA, PHD, PROF */
	global grad "flag_date_MA flag_date_PHD flag_date_PROF"
	
	* Replace . year with 0.
	foreach var in $grad{
		replace `var' = 0 if `var' == .
	}
	
	* Replace grad indicator with the earliest attained grad degree
	sort id age_BA
	egen flag_grad = rowmax($grad)
	list id age_BA $grad flag_grad if id == 8
	lab var flag_grad "Indicator of R's Grad Degree Status."
	lab define vlflag_grad 0 "No Grad Degree" 1 "Grad Degree Attained"
	lab values flag_grad vlflag_grad
	fre flag_grad
	
	// Final check vars
	fre gender
	fre age_BA
	fre race
	
	fre census_msa
	fre census_region
	
	fre job_ind
	fre job_never
	
	fre major_apst
	
	fre fm_status
	fre child_all
	
	save "used_Y_unlagged.dta", replace
	
	
	
	
	
	
	
	
	
	





