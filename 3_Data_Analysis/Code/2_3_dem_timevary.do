



************ data extracting code from this line (line 5 ~ line 350)*****************	

	 * R's unique id
	 gen id = PUBID_1997
	 lab var id "R's id"

	********************************************************
	* Create time-varying variables (survey-year --> yearly)
	* region, MSA, weight
	********************************************************
	fre CV_CENSUS_REGION_1997
	fre CV_CENSUS_REGION_2021 
	
	foreach num of numlist 1997/2011 2013 2015 2017 2019 2021{
		
		rename CV_CENSUS_REGION_`num' CV_orig_CENSUS_REGION_`num'
		gen CV_CENSUS_REGION_`num' = .
		replace CV_CENSUS_REGION_`num' = CV_orig_CENSUS_REGION_`num'
		replace CV_CENSUS_REGION_`num' = 5 if CV_orig_CENSUS_REGION_`num' < 0
		replace CV_CENSUS_REGION_`num' = 5 if CV_orig_CENSUS_REGION_`num' == .
		lab var CV_CENSUS_REGION_`num' "R's living region in year*"
	}

	lab define vlCV_REGION 1 "Northeast" 2 "North Central" 3 "South" 4 "West" 5 "Missing"
	label values CV_CENSUS_REGION* vlCV_REGION
	tab CV_CENSUS_REGION_2015 CV_orig_CENSUS_REGION_2015, m

	fre CV_MSA_1997 
	fre CV_MSA_2021 

	foreach num of numlist 1997/2011 2013 2015 2017 2019 2021{
		
		rename CV_MSA_`num' CV_orig_MSA_`num'
		recode CV_orig_MSA_`num' (1 = 0 "Non-MSA") (2/4 = 1 "MSA") ///
		(-5/-1 5 = 5 "Missing"), gen(CV_MSA_`num')
		lab var CV_MSA_`num' "R living in MSA or not in year*"
		
	}

	tab CV_MSA_2015 CV_orig_MSA_2015, m
	label define vlCV_MSA 0 "Non-MSA" 1 "MSA" 5 "Missing" 
	
	save "temp.dta", replace
	* Transform the time-varying var to yearly format
	* Date covered: 1997/01 (month 444) - 2022/10 (month 743)
	
	use "temp.dta", clear
	
	* for year 1997-2011
	
	foreach y of numlist 1997/2011 2013 2015 2017 2019 2021{
	
		gen census_msa_`y' = CV_MSA_`y' 
		lab var census_msa_`y' "R living in MSA or not"
		lab values census_msa_`y' vlCV_MSA
		
		gen census_region_`y' = CV_CENSUS_REGION_`y'
		lab var census_region_`y' "R's living region"
		lab values census_region_`y' vlCV_REGION
	
		gen weight_`y' = SAMPLING_WEIGHT_CC_`y' 
		lab var weight_`y' "R sampling weight"
		
	}
	
	list census_*_2011 CV_MSA_2011 CV_CENSUS_REGION_2011 weight_2011 in 1/10
	
	* for year 2012/2013-2020/2021
	
	foreach y of numlist 2012 2014 2016 2018 2020 2022{
	
		local y1 = `y' - 1
		gen census_msa_`y' = CV_MSA_`y1' 
		gen census_region_`y' = CV_CENSUS_REGION_`y1'
		gen weight_`y' = SAMPLING_WEIGHT_CC_`y1' 
		
		lab var census_msa_`y' "R living in MSA or not"
		lab values census_msa_`y' vlCV_MSA
		lab var census_region_`y' "R's living region"
		lab values census_region_`y' vlCV_REGION
		lab var weight_`y' "R sampling weight"
	}
	
	* check
	list census_msa_2020 census_region_2022 CV_MSA_2021 CV_CENSUS_REGION_2021 weight_2021 in 1/10
	
	
	**********************************************************
	* Create time-varying enrollment status:monthy --> yearly
	* enroll_college_`y'
	* If enroll in school >=80% --> enrolled
	**********************************************************
	* Obs Window: 1997/01-2022/10
		
		* SCH_COLLEGE_STATUS : 1997/01-2022/09 (month 444 - month 752)	
		fre SCH_COLLEGE_STATUS_2000_10
		
		foreach y of numlist 1997/2022{
			foreach m of numlist 1/9{
				
				rename SCH_COLLEGE_STATUS_`y'_0`m' SCH_COLLEGE_STATUS_`y'_`m'
				
			}
		}	
			
		list SCH_COLLEGE_STATUS_2022_9 in 1/10 
		
		* If enroll >= 6 months --> enrolled in school
		
		// gen enroll binary indicator
		foreach y of numlist 1997/2022{
			foreach m of numlist 1/12{
				capture recode  SCH_COLLEGE_STATUS_`y'_`m' ///
				(-4 1 = 0 "Not enrolled") (2 3 4 = 1 "Enrolled"), gen(college_enroll_bi_`y'_`m')
			}
		}
		
		list college_enroll_bi_2022_9 SCH_COLLEGE_STATUS_2022_9 in 1/10
		list college_enroll_bi_2010_9 SCH_COLLEGE_STATUS_2010_9 in 1/10
		
		// Sum up # enrolled month in a year 
		foreach y of numlist 1997/2021{
			
			egen college_enroll_month_`y' = rowtotal(college_enroll_bi_`y'_1 - college_enroll_bi_`y'_12)
			recode college_enroll_month_`y' (0/5 = 0 "Not enrolled") (6/12 = 1 "Enrolled"), ///
			gen(enroll_`y')
			
		}
		
		list enroll_2011 college_enroll_month_2011 in 1/100
		
		// If >= 4 months in 2022 --> enrolled
		egen college_enroll_month_2022 = rowtotal(college_enroll_bi_2022_1 - college_enroll_bi_2022_10)
		recode college_enroll_month_2022 (0/5 = 0 "Not enrolled") (6/12 = 1 "Enrolled"), ///
		gen(enroll_2022)
	
		list enroll_2022 college_enroll_month_2022 in 1/100
	
********** End ***************















