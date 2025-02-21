



************ data extracting code from this line (line 5 ~ line 350)*****************	

	* Create time variables (mdy)
	* bdate, fm_date, #child, intdate_*, lstsurv_date

	
	************* 
	* Birthdate *
	*************
	
	* Look at birthday month and year variables
	tab KEY_BDATE_M_1997, miss
	tab KEY_BDATE_Y_1997, miss
	
	* Generate Stata date birthdates
	gen bdate = dofm(ym(KEY_BDATE_Y_1997, KEY_BDATE_M_1997))
	*format bdate %tw
	list bdate in 1/10
	
	************
	* fm_date *
	************
	
	* Look at first marraige date variables 
	fre CVC_FIRST_MARRY_DATE_M
	fre CVC_FIRST_MARRY_DATE_Y

	* Create Stata first marriage date variables (only for those with valid non-negative dates)
	gen fm_date = dofm(ym(CVC_FIRST_MARRY_DATE_Y, CVC_FIRST_MARRY_DATE_M)) ///
	if CVC_FIRST_MARRY_DATE_M > 0 & CVC_FIRST_MARRY_DATE_Y > 0
		
	* Check the creation of this variable
	*format fm_date %tw
	list fm_date in 1/10
	* Look at last interview round variable
	tab CVC_RND, miss

	* Look at interview date variables 
	tab CV_INTERVIEW_DATE_M_2019, miss
	tab CV_INTERVIEW_DATE_Y_2019, miss

	*************
	* fm_status *
	*************
	* Date covered: 1994/Jan ~ 2022/Oct
	* Date used: 1997/Jan ~ 2022/Oct
	* Goal: Gen a binary marital status indicator
	fre MAR_STATUS_2020_05
	
	* Step 1: Rename vars
	foreach y of numlist 1994/2022{
		foreach m of numlist 1/9{
			
			rename MAR_STATUS_`y'_0`m' MAR_STATUS_`y'_`m'
		}
	}
	
	fre MAR_STATUS_2020_5
	
	* Step 2: recode monthly data
	lab define vlfm_status 0 "Not married" 1 "Married" 2 "Missing"
	
	foreach y of numlist 1994/2021{
		foreach m of numlist 1/12{
			
			recode MAR_STATUS_`y'_`m' (0 1 3 4 5 = 0 "Not married") (-5/-1 = 1 "Missing") (2 = 2 "Married"), ///
			gen(fm_month_status_`y'_`m')
		}
		
		// Married: If R is married in any month in a year.
		egen fm_status_max_`y' = rowmax(fm_month_status_`y'_1-fm_month_status_`y'_12)
		egen fm_status_min_`y' = rowmin(fm_month_status_`y'_1-fm_month_status_`y'_12)
		
		gen fm_status_`y' = 1 if fm_status_max_`y' == 2 
		
		// Not married: If R is married in any month in a year.
		replace fm_status_`y' = 0 if fm_status_min_`y' == 0 
		
		// Missing
		replace fm_status_`y' = 2 if fm_status_`y' == . 
		
		lab var fm_status_`y' "R's yearly marital status, binary."
		lab values fm_status_`y' vlfm_status
		
		// Drop egen vars
		drop fm_status_max_`y' fm_status_min_`y'
	}
	
	// Replicate for 2022 Jan ~ Oct
	foreach y of numlist 2022{
		foreach m of numlist 1/10{
			
			recode MAR_STATUS_`y'_`m' (0 1 3 4 5 = 0 "Not married") (-5/-1 = 1 "Missing") (2 = 2 "Married"), ///
			gen(fm_month_status_`y'_`m')
		}
		
		// Married: If R is married in any month in a year.
		egen fm_status_max_`y' = rowmax(fm_month_status_`y'_1-fm_month_status_`y'_10)
		egen fm_status_min_`y' = rowmin(fm_month_status_`y'_1-fm_month_status_`y'_10)
		
		gen fm_status_`y' = 1 if fm_status_max_`y' == 2 
		
		// Not married: If R is married in any month in a year.
		replace fm_status_`y' = 0 if fm_status_min_`y' == 0 
		
		// Missing
		replace fm_status_`y' = 2 if fm_status_`y' == . 
		
		lab var fm_status_`y' "R's yearly marital status, binary."
		lab values fm_status_`y' vlfm_status
		
		// Drop egen vars
		drop fm_status_max_`y' fm_status_min_`y'
	}
	
	* Step 3: Check
	list fm_month_status_2010_* fm_status_2010 in 1/30
	fre fm_status_2010

	************
	* int_date *
	************ 
	
	* Create Stata date interview dates for each year
	 #delimit ;
	  foreach num of numlist 1997/2011 2013 2015 2017 2019 2021{ ;
	   gen intdate_`num' = dofm(ym(CV_INTERVIEW_DATE_Y_`num',CV_INTERVIEW_DATE_M_`num'))
						   if CV_INTERVIEW_DATE_M_`num' > 0 &					 
							  CV_INTERVIEW_DATE_Y_`num' > 0  ;
	  * format intdate_`num' %tw ; 
							 } ;

	 #delimit cr
	
	* Check a few cases to make sure my code worked. 
	list intdate_2017 intdate_2019 CVC_RND in 1/20 
	
	* Cover the unsurveyed years
	foreach num of numlist 2012 2014 2016 2018 2020 2022{
		
		local num1 = `num' - 1
		gen intdate_`num' = intdate_`num1'
	}
	
	list intdate_2011 intdate_2012 in 1/20

	**************
	* child_date *
	************** 
	
	* Use "# of res- and non-res- children" as measuring R's childcare responsibility.
	* Used vars: CV_BIO_CHILD_HH (1997-2015), CV_BIO_CHILD_HH_U18 (2015-2021), CV_BIO_CHILD_NR (1997-2015), CV_BIO_CHILD_NR_U18 (2015-2021)
	
	/* 0828 
	
	The used vars have lots of missing. Temporarily replace all missing with 0.
	
	*/
	
	list CV_BIO_CHILD_HH_2015 CV_BIO_CHILD_HH_U18_2015 ///
	CV_BIO_CHILD_NR_2015 CV_BIO_CHILD_NR_U18_2015 in 1/10
	
	
	foreach num of numlist 1997/2011 2013{
	
		gen child_res_`num' = CV_BIO_CHILD_HH_`num' if CV_BIO_CHILD_HH_`num' >= 0 & ///
		CV_BIO_CHILD_HH_`num' != .
		
		gen child_nonres_`num' = CV_BIO_CHILD_NR_`num' if CV_BIO_CHILD_NR_`num' >= 0 & ///
		CV_BIO_CHILD_NR_`num' != .
		
		gen child_all_`num'= child_res_`num' + child_nonres_`num'
	
	}
	
	list child_*_2000 in 1/50
	
	* There's overlap of vars in 2015.
	gen child_res_2015 = CV_BIO_CHILD_HH_2015 + CV_BIO_CHILD_HH_U18_2015 ///
	if CV_BIO_CHILD_HH_2015 >= 0 & CV_BIO_CHILD_HH_2015 != . & ///
	CV_BIO_CHILD_HH_U18_2015 >= 0 & CV_BIO_CHILD_HH_U18_2015 != .
	
	gen child_nonres_2015 = CV_BIO_CHILD_NR_2015 + CV_BIO_CHILD_NR_U18_2015 ///
	if CV_BIO_CHILD_NR_2015 >= 0 & CV_BIO_CHILD_NR_2015 != . & ///
	CV_BIO_CHILD_NR_U18_2015 >= 0 & CV_BIO_CHILD_NR_U18_2015 != .
	
	gen child_all_2015 = child_res_2015 + child_nonres_2015
	
	list child_*_2015 in 1/10
	
	* After 2017, only children under 18 is recorded.
	foreach num of numlist 2017 2019 2021{
	
		gen child_res_`num' = CV_BIO_CHILD_HH_U18_`num' if CV_BIO_CHILD_HH_U18_`num' >= 0 & ///
		CV_BIO_CHILD_HH_U18_`num' != .
		
		gen child_nonres_`num' = CV_BIO_CHILD_NR_U18_`num' if CV_BIO_CHILD_NR_U18_`num' >= 0 & ///
		CV_BIO_CHILD_NR_U18_`num' != .
		
		gen child_all_`num'= child_res_`num' + child_nonres_`num'
	
	}
	
	
	
	* Cover even years after 2011
	foreach y of numlist 2012 2014 2016 2018 2020 2022{
		local y1 = `y' - 1
		gen child_res_`y' = child_res_`y1'
		gen child_nonres_`y' = child_nonres_`y1'
		gen child_all_`y' = child_all_`y1'
	}
	
	list child_*_2017 child_*_2018 in 1/10
	
	save "temp.dta", replace
	
	
	********************
	* last_survey_date *
	********************
 	use "temp.dta", clear
	
	* Generate last survey year variable (revised to make simpler)
	* Recall, the survey was administered every year through 2011 then every other
	* year
	gen     lstsurvyr = CVC_RND + 1996 if CVC_RND < 16 /*Round 1=1997, etc*/
	replace lstsurvyr = (CVC_RND - 15) * 2 + 2011 if 16 <= CVC_RND

	* replace lstsurvyr = 2017 if CVC_RND == 19
	* Check variable creation 
	tab lstsurvyr CVC_RND, miss			    
	list intdate_2011 intdate_2013 intdate_2021 CVC_RND lstsurvyr in 1/10 

	* Generate date of last survey variable
	egen lstsurv_date = rowmax(intdate_1997-intdate_2021)
	*format lstsurv_date %tw
	list intdate_2009 intdate_2011 intdate_2013 intdate_2015 intdate_2017 intdate_2021 CVC_RND lstsurvyr lstsurv_date in 50/60
	
	save "temp.dta", replace
	
	******************************************
	* Monthly date of degree/diploma * 
	******************************************
	// Remain monthly for locating R's college major in 2_0_prepare_data
	use "temp.dta", clear
	
	fre CVC_HIGHEST_DEGREE_EVER
	fre CVC_HGC_EVER 

	* Date in orig_data should add 239 on it to represent the real cal. month.
	
	gen degree_date_HS = .
	replace degree_date_HS = yofd(dofm(239 + CVC_HS_DIPLOMA)) ///
	if !missing(CVC_HS_DIPLOMA) & CVC_HS_DIPLOMA > 0
	
	list degree_date_HS in 1/10
	
	gen degree_date_AA = .
	replace degree_date_AA = yofd(dofm(239 + CVC_AA_DEGREE)) ///
	if !missing(CVC_AA_DEGREE) & CVC_AA_DEGREE > 0
	
	list degree_date_AA in 1/100
	
	gen degree_date_BA = .
	replace degree_date_BA = yofd(dofm(239 + CVC_BA_DEGREE)) ///
	if !missing(CVC_BA_DEGREE) & CVC_BA_DEGREE > 0
	
	gen degree_date_PROF = .
	replace degree_date_PROF = yofd(dofm(239 + CVC_PROF_DEGREE)) ///
	if !missing(CVC_PROF_DEGREE) & CVC_PROF_DEGREE > 0
	
	gen degree_date_MA = .
	replace degree_date_MA = yofd(dofm(239 + CVC_MA_DEGREE)) ///
	if !missing(CVC_MA_DEGREE) & CVC_MA_DEGREE > 0
	
	gen degree_date_PHD = .
	replace degree_date_PHD = yofd(dofm(239 + CVC_PHD_DEGREE)) ///
	if !missing(CVC_PHD_DEGREE) & CVC_PHD_DEGREE > 0
	

	list degree_date* CVC_HS_DIPLOMA CVC_BA_DEGREE in 1/20
	
/******************************************************************************/
/*2: Clean demographic variables - time-invariant                             */
/******************************************************************************/
	 * R's unique id
	 gen id = PUBID_1997
	 lab var id "R's id"
	 
	 * Sex
	 recode KEY_SEX (1 = 0) (2 = 1), gen(gender)
	 lab var gender "R's gender"
	 label define vlm_sex 0 "Men" 1 "Women"
	 label values gender vlm_sex
	 fre gender
	 
	 * Race/ethnicity
	 drop KEY_RACE_ETHNICITY 
	 tab KEY_ETHNICITY KEY_RACE ,m
	 fre KEY_RACE
	 replace KEY_RACE = 6 if KEY_ETHNICITY == 1
	 replace KEY_RACE = 7 if KEY_ETHNICITY == 5
	 recode KEY_RACE (1=0 "White") (2=1 "African American") ///
	(6=2 "Hispanic")  (4=3 "Asian or Pacific Islander") (3 7 -2 -1=5 "Other"), gen(race)
	 lab var race "R's race/ethnicity"
	 fre race
	 
	 * Education
	 fre CVC_HIGHEST_DEGREE_EVER
	 recode CVC_HIGHEST_DEGREE_EVER (0=0 "< HS") (1/2=1 "HS/GED") (3=2 "AA") ///
	 (4=3 "BA") (5/7=4 "BA+") (-99/-1=5 "Missing"), gen(edu_degree) 
	 lab var edu_degree "R's highest degree"
	 fre edu_degree
	 
	 fre CVC_HGC_EVER
	 recode CVC_HGC_EVER (0/11=0 "< HS") (12=1 "HS/GED") (13/15=2 "Some college") ///
	 (16=3 "BA") (17/20=4 "BA+") (-99/-1=5 "Missing") (90/99=5 "Missing"), gen(edu_grade) 
	 lab var edu_grade "R's highest grade"
	 fre edu_grade

	 * Citizenship at birth
     fre CV_CITIZENSHIP
	 recode CV_CITIZENSHIP (1=0 "Citizen, born in the U.S.") (2=1 "Unknown, not born in U.S.") (3=2 "Unknown, can't determine birthplace") (-4=3 "Missing"), gen(citizen)
	 lab var citizen "Citizenship at birth"
	 fre citizen 
	 
	 * Gen highest parent's edu
	 label define vlp_edu 0 "<HS" 1 "HS" 2 "Some College" 3 "BA or more" 4 "Missing"
	 recode CV_HGC_BIO_MOM (-4/-1=.)(1/11=0)(95=0)(12=1)(13/15=2)(16/20=3), ///
	 gen (m_edu)
	 recode CV_HGC_BIO_DAD (-4/-1=.)(1/11=0)(95=0)(12=1)(13/15=2)(16/20=3), ///
	 gen (d_edu)
	 tab m_edu d_edu,m
	 gen p_edu = .
	 replace p_edu = m_edu if m_edu >= d_edu
	 replace p_edu = m_edu if d_edu == . & p_edu == .
	 replace p_edu = d_edu if d_edu >= m_edu & p_edu == .
	 replace p_edu = d_edu if m_edu == . & p_edu == .
	 fre p_edu
	 replace p_edu = 4 if p_edu == . 
	 label values p_edu vlp_edu 
	 lab var p_edu "Edu of the highest educated parent"
	 fre p_edu
	 
	 * Fam inc at R's youth. Replace if missing.
	 fre CV_INCOME_GROSS*
	 gen fam_inc = CV_INCOME_GROSS_YR_1997 * 72.6/156.9 if CV_INCOME_GROSS_YR_1997 > 0
	 replace fam_inc = CV_INCOME_GROSS_YR_1998 * 72.6/160.5 ///
	 if CV_INCOME_GROSS_YR_1998 > 0 & fam_inc == .
	 replace fam_inc = CV_INCOME_GROSS_YR_1999 * 72.6/163.5 ///
	 if CV_INCOME_GROSS_YR_1999 > 0 & fam_inc == .
	 replace fam_inc = CV_INCOME_GROSS_YR_2000 * 72.6/166.6 ///
	 if CV_INCOME_GROSS_YR_2000 > 0 & fam_inc == .
	 replace fam_inc = CV_INCOME_GROSS_YR_2001 * 72.6/172.2 ///
	 if CV_INCOME_GROSS_YR_2001 > 0 & fam_inc == .
	 replace fam_inc = CV_INCOME_GROSS_YR_2002 * 72.6/177.1 ///
	 if CV_INCOME_GROSS_YR_2002 > 0 & fam_inc == .
	 replace fam_inc = CV_INCOME_GROSS_YR_2003 * 72.6/179.9 ///
	 if CV_INCOME_GROSS_YR_2003 > 0 & fam_inc == . 
	 replace fam_inc = ln(fam_inc)
	 lab var fam_inc   "Ln(Fam inc at 1997-2003)"
	 fre fam_inc
	 
	 * ASVAB score
	 fre ASVAB_MATH_VERBAL_SCORE_PCT_1999 
	 gen asvab = ASVAB_MATH_VERBAL_SCORE_PCT_1999/1000 if ASVAB_MATH_VERBAL_SCORE_PCT_1999 > 0
	 gen asvab_orig = asvab
	 egen asvabmean = mean(asvab)
	 gen asvab_m = 1 if (asvab==.)
	 replace asvab_m = 0 if (asvab!=.)
	 fre asvab_m
	 replace asvab = asvabmean if asvab == . 
	 lab var asvab "ASVAB percentile"
	 lab var asvab_m "ASVAB missing"
		

