


**********
* X to M *
**********
	clear all
	
	* For Office-PC
	*cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	use "used_M.dta", clear
	******************************
	* Discrete-time Hazard Model *
	******************************
	
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	*cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	
	global DV "shift_pos shift_neg"
	
	global control "ib5.race ib2.census_region i.census_msa" 
	global control_emp "i.job_ind i.job_never"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	
	foreach DV in $DV{
	
		local i = 1
	
		// M1: gender + controls
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.gender || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M2: gender + controls + college_major
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.major_apst i.gender || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M3: gender + controls + gender X college_major
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.gender##i.major_apst || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M4: gender + controls + gender X college_major + gender X fam
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp $control_fm_int ///
		i.gender##i.major_apst || id:age_BA, vce(cluster id) 
		
	}
	
	// Export tables
	esttab M_shift_pos_* M_shift_neg_* using M_final.csv, wide replace b(3) nolz se(3) star scalar(ll aic bic) nobase compress nogaps noomitted label ///
	drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
	interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
	mtitles ("pos" "" "" "" "" "neg" "" "" "" "" ) ///
	title("Table 3. Gender, College Major, and Employment Movements, Multilevel Event History Model") ///
	addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	esttab M_shift_pos_* M_shift_neg_* using M_final.tex, wide replace b(3) nolz se(3) star scalar(ll aic bic) nobase compress nogaps noomitted label ///
	drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
	interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
	mtitles ("pos" "" "" "" "" "neg" "" "" "" "" ) ///
	title("Table 3. Gender, College Major, and Employment Movements, Multilevel Event History Model") ///
	addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	**********// part-time, append to the original table //*************
	
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	
	global DV "shift_part_part"
	
	global control "ib5.race ib2.census_region i.census_msa" 
	global control_emp "i.job_ind i.job_never"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	
	foreach DV in $DV{
	
		local i = 1
	
		// M1: gender + controls
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.gender || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M2: gender + controls + college_major
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.major_apst i.gender || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M3: gender + controls + gender X college_major
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.gender##i.major_apst || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M4: gender + controls + gender X college_major + gender X fam
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp $control_fm_int ///
		i.gender##i.major_apst || id:age_BA, vce(cluster id) 
		
	}
	
	// Export tables
	esttab M_shift_part_part* using M_final.csv, wide append b(3) nolz se(3) star scalar(ll aic bic) nobase compress nogaps noomitted label ///
	drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
	interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
	mtitles ("part" "" "" "" "") ///
	title("Table 3. Gender, College Major, and Employment Movements, Multilevel Event History Model") ///
	addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	**************************************
	* Plotting *
	**************************************
	clear all
	
	* For Office-PC
	*cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	use "used_M.dta", clear
	
	rename shift_pos Positive_Emp_Transition
	rename shift_neg Negative_Emp_Transition
	rename shift_part_part Consistent_Part_Time
	global DV "Positive_Emp_Transition Negative_Emp_Transition  Consistent_Part_Time"
	
	global control "ib5.race ib2.census_region i.census_msa" 
	global control_emp "i.job_ind i.job_never"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	
	*cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Figures"
	cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Figures"
	
	// Graph 1-2. College Major (4) and Career Movements (2)
	local i = 1
	foreach DV in $DV{
		
		// M2: gender + controls + college_major
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp ///
		i.major_apst i.gender || id:age_BA, vce(cluster id) 
		
		quietly margins i.major_apst
		*estimates store `DV'
		*coefplot (`DV', label(`DV')) , vertical 
		marginsplot, title("`DV'") ytitle("") xtitle("") scheme(sj) ///
		xlabel(1 "Aca_non" 2 "Aca_STEM" 3 "App_non" 4 "App_STEM" ,labsize(small)) recast(bar) 
		
		graph save "F`i'", replace
		graph export F`i'.png, width(1850) height(1350) replace 
		
		local i = `i' + 1
	}
	
	// Graph 3-4. College Major (4), Gender (2),  and Career Movements (2)
	local i = 4
	foreach DV in $DV{
		
		// M4: gender + controls + gender X college_major + gender X fam
		eststo M_`DV'_`i': mixed `DV' c.age_BA##c.age_BA $control $control_emp $control_fm_int ///
		i.gender##i.major_apst || id:age_BA, vce(cluster id) 
	
		// Margins plot: gender X major
		margins, dydx(major_apst) at(major_apst=(3 4) gender=(1 2)) 
		estimate store margins_results
		
		coefplot margins_results, vertical ///
		keep(*.gender#*.major_apst) ///
		bylabel("Marginal Effects") ///
		yline(0, lcolor(red)) ///
		ylabel(, angle(horizontal)) ///
		xlabel(1 "Academic STEM" 2 "Applied non-STEM" 3 "Applied STEM") ///
		title("Gender Gap in Marginal Effects of College Major")
		
		graph save "F`i'", replace
		graph export F`i'.png, width(2500) height(1800) replace 
	
		local i = `i' + 1
	}
	


	
**********
* X to Y *
**********	
	
		
**********************************************
* Multilevel Linear Regression Model (Mixed) * 	
**********************************************

	// Change between lagged and unlagged data


	clear all
	
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	use "used_Y.dta", clear
	*use "used_Y_unlagged.dta", clear

	*****************************
	* Set up Growth-Curve Model *
	*****************************
	global DV "wage"
	
	global control "ib5.race ib2.census_region ib0.census_msa" 
	global control_emp "i.job_ind"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	
	************************************
	* Growth-Curve Model, descriptvie *
	************************************
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	foreach DV in $DV{
	
		local i = 1
	
		// M1: gender + controls
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp ///
		|| id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M2: gender + controls + fam + college_major
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst ///
		 || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
	
		// M3: gender##pos 
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst c.cum_shift_pos##i.gender ///
		 || id:age_BA, vce(cluster id) 
		 
		 local i = `i' + 1
	
		// M4: neg
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst c.cum_shift_neg ///
		 || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M5: gender##pos + neg
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst ///
		c.cum_shift_neg c.cum_shift_pos##i.gender ///
		 || id:age_BA, vce(cluster id) 
		 
	}
	
	// Export tables
	foreach DV in $DV{
		
		esttab M_`DV'* using Y_`DV'_final.csv, replace b(3) nolz se(2) wide star ///
		drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
		scalar(ll aic bic) nobase compress nogaps noomitted label ///
		interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
		nomtitles ///
		title("Table X. Gender, College Major, and `DV', Multilevel Linear Regression Model") ///
		addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	}
	
	
	// part-time
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	global DV "wage"
	
	global control "ib5.race ib2.census_region ib0.census_msa" 
	global control_emp "i.job_ind"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	
	foreach DV in $DV{
	
		local i = 1
	
		// M4: part
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst c.cum_shift_part ///
		 || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M5: gender##part
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst ///
		c.cum_shift_part##i.gender ///
		 || id:age_BA, vce(cluster id) 
		 
	}
	
	// Export tables, append to the original one.
	foreach DV in $DV{
		
		esttab M_`DV'* using Y_`DV'_final.csv, append b(3) nolz se(2) wide star ///
		drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
		scalar(ll aic bic) nobase compress nogaps noomitted label ///
		interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
		nomtitles ///
		title("Table X. Gender, College Major, and `DV', Multilevel Linear Regression Model") ///
		addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	}
	
	
	*********************************
	* Grad Degree Status, Appendix *
	*********************************
	clear all
	
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	use "used_Y.dta", clear
	*use "used_Y_unlagged.dta", clear
	
	************************************************************************
	global DV "wage"
	
	global control "ib5.race ib2.census_region ib0.census_msa ib0.flag_grad" 
	global control_emp "i.job_ind"
	global control_fm "ib3.fm_status i.child_all_bi"
	global control_fm_int "i.gender##ib3.fm_status i.gender##i.child_all_bi"
	************************************************************************
	
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	
	foreach DV in $DV{
	
		local i = 1
	
		 // M3: gender##pos 
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst c.cum_shift_pos##i.gender ///
		 || id:age_BA, vce(cluster id) 
		 
		 local i = `i' + 1
	
		// M4: neg
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst c.cum_shift_neg ///
		 || id:age_BA, vce(cluster id) 
		
		local i = `i' + 1
		
		// M5: gender##pos + neg
		eststo M_`DV'_`i': mixed `DV' c.`DV'_first i.gender c.age_BA##c.age_BA ///
		$control $control_emp $control_fm i.major_apst ///
		c.cum_shift_neg c.cum_shift_pos##i.gender ///
		 || id:age_BA, vce(cluster id) 
		 
	}
	

		
	// Export tables
	foreach DV in $DV{
		
		esttab M_`DV'* using Y_`DV'_final.csv, append b(3) nolz se(2) wide star ///
		drop(1.census_region 2.census_msa 99.job_ind 2.fm_status ) ///
		scalar(ll aic bic) nobase compress nogaps noomitted label ///
		interaction(" X ") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  ///
		nomtitles ///
		title("Appendix X. Gender, College Major, and `DV', Grad Degree Status, Multilevel Linear Regression Model") ///
		addnotes("Note: Standard errors are shown in parentheses. +p < .01; *p < .05; **p < .01; ***p < .001.") nonotes 
	
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
