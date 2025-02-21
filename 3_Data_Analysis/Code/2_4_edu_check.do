* Last editted: 08/28/2024
* Purpose: Solve the multiple enrollment problem in "2_4_edu_.dta".
* There are duplicates in id attend_cont_month, which can cause problems when merging.


	*********** Problem Diagnosis ***********
	sort id attend_cont_month
	duplicates report id attend_cont_month 
	duplicates list id attend_cont_month in 1/100, sepby(id)
	
	// Look into cases. Some if them provide exact same info.
	fre college_major_*
	list id attend_cont_month college_major_* if id == 1
	list id attend_cont_month college_major_* if id == 6
	list id attend_cont_month college_major_* if id == 16
	
	fre college_2major_*
	
	// Check how many duplicates contain same info. Consider keeping one.
	duplicates report id attend_cont_month 
	duplicates report id attend_cont_month college_major_orig 
	duplicates report id attend_cont_month college_major_orig college_2major_orig
	dis 42341-40514
	dis 43089-42341
	
	// Conclusion
	// 1. We should eliminate the complete same cases, as duplicates cannot provide more infos.
	
	// 2. There 1827 cases (42341-40514) having 2+ unique month & major. 
	// Perhaps they enroll in diff. college or diff. term within the same month.
	// Try to add more columns (vars) to capture their multiple majors.
	
	// 3. There are 748 cases having 2+ unique month and 2nd major.
	// Temporarily ignore this and focus on 1st major only.

	*********** Step 1 ***********
	// Eliminate duplicates
	duplicates report id attend_cont_month college_major_orig college_2major_orig 
	duplicates drop id attend_cont_month college_major_orig college_2major_orig, force
	
	// Check
	duplicates report id attend_cont_month 
	duplicates report id attend_cont_month college_major_orig 
	duplicates report id attend_cont_month college_major_orig college_2major_orig
	
	// As stated in 3., temp ignore 2nd major so keep only unique id attend_cont_month college_major_orig_
	duplicates drop id attend_cont_month college_major_orig, force
	duplicates report id attend_cont_month 
	dis 1846 + 21 /* These are what we'll deal with in the next step (n = 1,867). */
	
	*********** Step 2 ***********
	// Add columns to include the multiple majors reported within the same month.
	// At most 3 unique majors are reported in the same month (n = 21). Check what they are.
	duplicates tag id attend_cont_month, gen(dup_tag)
	bysort id attend_cont_month: gen dup_count = _N
	list id attend_cont_month college_major_orig college_2major_orig if dup_count == 3, sepby(id)
	bysort id attend_cont_month: gen id_count = _n
	// They may a) report their 2major or 2) undeclared or missing in the duplicate rows.
	save "temp.dta", replace
	
	use "temp.dta", clear
	
	// Gen cols to store duplicate values. We focus on 1st major only.
	local varlist orig_ field_ app_ stem_
	foreach var in `varlist' {
		
		gen college_major_dup2_`var'= .
		gen college_major_dup3_`var'= .
		
		replace college_major_dup2_`var' = college_major_`var'[_n+1] if dup_count == 2 & id_count == 1
		replace college_major_dup2_`var' = college_major_`var'[_n+1] if dup_count == 3 & id_count == 1
		replace college_major_dup3_`var' = college_major_`var'[_n+2] if dup_count == 3  & id_count == 1
		
	}
	

	list id college_major* in 1/60 if dup_count == 2
	list id college_major* if dup_count == 3
	
	// Drop the duplicates.
	duplicates drop id attend_cont_month, force
	
	// Store the most important value in the main variable.
	// replace the main containing 0 (undeclared), 9, . (missing) with valid ones.
	local varlist field_ app_ stem_
	foreach var in `varlist' {
		
		fre college_major_`var'
		
		// replace missing
		replace college_major_`var' = college_major_dup2_`var' if ///
		dup_count >= 2 & college_major_`var' == 9 & ///
		college_major_dup2_`var' > 0 & college_major_dup2_`var' != 9
		
		// replace missing
		replace college_major_`var' = college_major_dup2_`var' if ///
		dup_count >= 2 & college_major_`var' == . & ///
		college_major_dup2_`var' > 0 & college_major_dup2_`var' != 9
		
		// replace undeclared
		replace college_major_`var' = college_major_dup2_`var' if ///
		dup_count >= 2 & college_major_`var' == 0 & ///
		college_major_dup2_`var' > 0 & college_major_dup2_`var' != 9
		
		// Do replacement with the 3rd duplicates if the 2nd doesn't work.
		// replace missing
		replace college_major_`var' = college_major_dup3_`var' if ///
		dup_count == 3 & college_major_`var' == 9  & ///
		college_major_dup3_`var' > 0 & college_major_dup3_`var' != 9
		
		// replace missing
		replace college_major_`var' = college_major_dup3_`var' if ///
		dup_count == 3 & college_major_`var' == . & ///
		college_major_dup3_`var' > 0 & college_major_dup3_`var' != 9
		
		// replace undeclared
		replace college_major_`var' = college_major_dup3_`var' if ///
		dup_count == 3 & college_major_`var' == 0 & ///
		college_major_dup3_`var' > 0 & college_major_dup3_`var' != 9
		
		// compare this w/the original one
		fre college_major_`var'
		
	}
	
	// No longer need duplicates. They have completed the substitutes tasks.
	drop college_major_dup*_*
	
	describe
	

	
	
	
	
	
	
	