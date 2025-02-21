

* Last editted: 09/02/2024


	* remember to change work directory.
	
	pwd
	clear all
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	
	
	use "save_orig.dta", clear
	
	keep id EMP* YEMP* CV*
	 
	 **************
	 * Formatting *
	 **************
	 
	 // Rename weekly roaster
	 
	 foreach week of numlist 6/9{
			
			rename EMP_HOURS_1994_0`week'_XRND EMP_HOURS_1994_`week'_XRND 
			rename EMP_STATUS_1994_0`week'_XRND EMP_STATUS_1994_`week'_XRND 
			
	}
	
	foreach year of numlist 1995/2022{
		
		foreach week of numlist 1/9{
			
			rename EMP_HOURS_`year'_0`week'_XRND EMP_HOURS_`year'_`week'_XRND 
			rename EMP_STATUS_`year'_0`week'_XRND EMP_STATUS_`year'_`week'_XRND 
		}
	}	
	
	list id EMP_HOURS_1994_9_XRND  EMP_HOURS_1998_9_XRND EMP_STATUS_1998_9_XRND in 1/10
	list id EMP_STATUS_2014_1_XRND in 1/10
	list id EMP_HOURS_2022_1_XRND  EMP_STATUS_2022_1_XRND in 1/5
	
	 // Rename employer roaster
	 
	foreach year of numlist 1997/2021{
		foreach EMPno of numlist 1/9{
			
			capture rename YEMP_UID_0`EMPno'_`year' YEMP_UID_`EMPno'_`year'
			capture rename CV_HRS_PER_WEEK_0`EMPno'_`year' CV_HRS_PER_WEEK_`EMPno'_`year'
			capture rename CV_HRLY_PAY_0`EMPno'_`year' CV_HRLY_PAY_`EMPno'_`year'
			capture rename CV_HRLY_COMPENSATION_0`EMPno'_`year' CV_HRLY_COMPENSATION_`EMPno'_`year'
			
			capture rename YEMP_OCCODE_0`EMPno'_`year' YEMP_OCCODE_`EMPno'_`year'
			capture rename YEMP_OCCODE_2002_0`EMPno'_`year' YEMP_OCCODE_2002_`EMPno'_`year'
			capture rename YEMP_INDCODE_0`EMPno'_`year' YEMP_INDCODE_`EMPno'_`year'
			capture rename YEMP_INDCODE_2002_0`EMPno'_`year' YEMP_INDCODE_2002_`EMPno'_`year'
			
			capture rename YEMP_81300_0`EMPno'_`year' YEMP_81300_`EMPno'_`year'
			capture rename YEMP_101200_0`EMPno'_`year' YEMP_101200_`EMPno'_`year'
		} 
	
	}
	
	list id YEMP_UID_1_2001 YEMP_UID_2_2001 YEMP_UID_3_2001  in 1/10 
	list id CV_HRS_PER_WEEK_1_2010 in 1/10
	list id CV_HRLY_PAY_1_2010 in 1/10
	list id YEMP_OCCODE_*_2010  in 1/10 
	list id YEMP_INDCODE_*_2010  in 1/10 
	list YEMP_101200_1_2010 in 1/10
	
	save "temp1.dta", replace
	
	************************************************
	* Locate main job & its characteristic by week *
	************************************************
	
	use "temp1.dta", clear
	
	* 1) Locate unique_EMPID, hours, wage of main job each cweek.
	
	// EMP_STATUS_YYYY_MM_WW: cover all years. no need to jump years
	// However, in 1994 (w6~wn), and in 2022 (w1~w40). They should be cleaned seperately.
	foreach y of numlist 1994/2022{
		
		dis `y'
		
		// Get the # of weeks in each year /* Let's not consider y=1994 to simplify the process */
		local nw = week(mdy(12,31,`y'))

		// Set parameters for testing
		local maxn = 15
		
		foreach w of numlist 1/`nw'{

			local cweek = yw(`y', `w')
			capture gen week_job_status_`cweek' = EMP_STATUS_`y'_`w'_XRND
			capture gen week_job_hour_`cweek' = EMP_HOURS_`y'_`w'_XRND
			
		}
	}
	
	local y = 2022
	local w = 20
	local cw = yw(`y',`w')
	list EMP_STATUS_`y'_`w'_XRND  week_job_status_`cw' EMP_HOURS_`y'_`w'_XRND  week_job_hour_`cw' in 1/10

	
	// Logic: EMP_STATUS_YYYY_MM_WW --> YEMP_UID_XX_YYYY --> EMP roater.
	
	// Note at linking EMP_STATUS_YYYY_MM_WW to YEMP_UID_XX_YYYY.
	// week_job_id can link to YEMP_UID in the same year or in the future rounds.
	// Link it to YEMP_UID starting from the currenr round.
	
	// For 1994/2011 2013 2015 2017 2019 2021
	foreach y of numlist 1994/2011 2013 2015 2017 2019 2021{
		dis `y'
		
		// Get the # of weeks in each year /* Let's not consider y=1994 to simplify the process */
		local nw = week(mdy(12,31,`y'))

		// Set parameters for testing
		local maxn = 15
		
		foreach w of numlist 1/`nw'{

			local cweek = yw(`y', `w')
			
			// Initializing: gen week_* for job each week. 
			cap gen week_job_id_`cweek' = EMP_STATUS_`y'_`w'_XRND 
			/* EMP_STATUS starts at 1994w6 */
			gen week_job_nid_`cweek' = . /* uid's # in the roaster in a given round */
			gen week_job_yid_`cweek' = . /* uid's match in # round */
			
			gen week_job_wage_`cweek' = .
			gen week_job_allwage_`cweek' = .
			gen week_job_occ_`cweek' = .
			gen week_job_ind_`cweek' = .
			gen week_job_sch_`cweek' = .
			gen week_job_sat_`cweek' = .
			
			// Locate R's main employer ID in each week.
			// Format of EMPID: 9701, 199901, 200001, 202199...
	
			foreach y_forward of numlist `y'/2021{
				foreach num of numlist 1/`maxn'{ /* max(#) = 15 */
					capture replace week_job_nid_`cweek' = `num' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_nid_`cweek' == .

					capture replace week_job_yid_`cweek' = `y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_yid_`cweek' == .
					
					capture replace week_job_wage_`cweek' = CV_HRLY_PAY_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_wage_`cweek' == .
					
					capture replace week_job_allwage_`cweek' = CV_HRLY_COMPENSATION_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_allwage_`cweek' == .
					
					capture replace week_job_occ_`cweek' = YEMP_OCCODE_2002_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_occ_`cweek' == .
					
					capture replace week_job_ind_`cweek' = YEMP_INDCODE_2002_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_ind_`cweek' == .
					
					capture replace week_job_sch_`cweek' = YEMP_81300_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_sch_`cweek' == .
					
					capture replace week_job_sat_`cweek' = YEMP_101200_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_sat_`cweek' == .
					
					}
				}
		}
		
	 }
	 
	 // For 2012 2014 2016 2018 2020 2022 : Go backward 1 year to locate YEMP_UID
	foreach y of numlist 2012 2014 2016 2018 2020 2022{
		dis `y'
		
		// Get the # of weeks in each year /* Let's not consider y=1994 to simplify the process */
		local nw = week(mdy(12,31,`y'))

		// Set parameters for testing
		local maxn = 15
		
		foreach w of numlist 1/`nw'{
			local cweek = yw(`y', `w')
			
			// Initializing: gen week_* for job each week. 
			cap gen week_job_id_`cweek' = EMP_STATUS_`y'_`w'_XRND /* expected error at 2022w41 */
			gen week_job_nid_`cweek' = . /* uid's # in the roaster in a given round */
			gen week_job_yid_`cweek' = . /* uid's match in # round */

			gen week_job_wage_`cweek' = .
			gen week_job_allwage_`cweek' = .
			
			gen week_job_occ_`cweek' = .
			gen week_job_ind_`cweek' = .
			
			gen week_job_sch_`cweek' = .
			gen week_job_sat_`cweek' = .
		
			// Locate R's main employer ID in each week.
			// Format of EMPID: 9701, 199901, 200001, 202199...
			
			local y1 = `y' - 1
			foreach y_forward of numlist `y1'/2021{
				foreach num of numlist 1/`maxn'{ /* max(#) = 15 */
					capture replace week_job_nid_`cweek' = `num' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_nid_`cweek' == .

					capture replace week_job_yid_`cweek' = `y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_yid_`cweek' == .
					
					capture replace week_job_wage_`cweek' = CV_HRLY_PAY_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_wage_`cweek' == .
					
					capture replace week_job_allwage_`cweek' = CV_HRLY_COMPENSATION_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_allwage_`cweek' == .
					
					capture replace week_job_occ_`cweek' = YEMP_OCCODE_2002_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_occ_`cweek' == .
					
					capture replace week_job_ind_`cweek' = YEMP_INDCODE_2002_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_ind_`cweek' == .
					
					capture replace week_job_sch_`cweek' = YEMP_81300_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_sch_`cweek' == .
					
					capture replace week_job_sat_`cweek' = YEMP_101200_`num'_`y_forward' if ///
					week_job_id_`cweek' == YEMP_UID_`num'_`y_forward' & ///
					week_job_sat_`cweek' == .
					}
				}
		}
	 }
	 
	 // Testing
	 local testy = 2014
	 dis yw(`testy', 40)
	 local w = yw(`testy', 40)
	 list id if week_job_id_1807 > 9000  
	 list id week_job_id_`w'  week_job_nid_`w' week_job_yid_`w' YEMP_UID_*_2013 if id == 141
	 * Checking EMP vars are matched?
	 local testy = 2014
	 dis yw(`testy', 40)
	 local w = yw(`testy', 40)
	 list id week_job_id_`w'  week_job_wage_`w' week_job_ind_`w' week_job_occ_`w' week_job_sat_`w' in 1/10
	 
	 keep id week_job_*
	 
	save "temp2.dta", replace
	
	*********************
	* Recode & Relabel *
	*********************
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
	use "temp2.dta", clear
	
	// Define labels
	lab define vljob_ind 0 "Extractive and Other" 1 "Core" 2 "High-Wage Service" 3 "Low-Wage Service" ///
	4 "Public Sector" 5 "Armed Forces"
	
	// Recode & Relabel in for-loop by week
	local w1 = yw(1994,6)
	local wn = yw(2022,40)
	
	foreach w of numlist `w1'/`wn'{
		
		// Recode work hours --> full-time (>=30hr)/part-time (0~30hr)/not-employed (-4, valid skip)
		recode week_job_hour_`w' (-4 = 0 "Not employed") (0/29.999 = 1 "Part-time") ///
		(30/168 = 2 "Full-time") (-5 -3 -2 -1 . = 3 "Missing"), gen(week_job_full_`w') 
		
		// Recode wage & all_wage (replace the <0 values with .)
		replace week_job_wage_`w' = . if week_job_wage_`w' < 0
		replace week_job_allwage_`w' = . if week_job_allwage_`w' < 0
		
		// Recode 2002 occup code to 2012 occup code
		
			// 0~999
			replace week_job_occ_`w' = 136 if week_job_occ_`w' == 130
			replace week_job_occ_`w' = 205 if week_job_occ_`w' == 200
			replace week_job_occ_`w' = 205 if week_job_occ_`w' == 210
			replace week_job_occ_`w' = 325 if week_job_occ_`w' == 320
			replace week_job_occ_`w' = 565 if week_job_occ_`w' == 560
			replace week_job_occ_`w' = 565 if week_job_occ_`w' == 620
			replace week_job_occ_`w' = 725 if week_job_occ_`w' == 720
			replace week_job_occ_`w' = 725 if week_job_occ_`w' == 730
			
			// 1000~1999
			replace week_job_occ_`w' = 1010 if week_job_occ_`w' == 1000
			replace week_job_occ_`w' = 1050 if week_job_occ_`w' == 1040
			replace week_job_occ_`w' = 1105 if week_job_occ_`w' == 1100
			replace week_job_occ_`w' = 1105 if week_job_occ_`w' == 1110
			replace week_job_occ_`w' = 1815 if week_job_occ_`w' == 1810
			replace week_job_occ_`w' = 1965 if week_job_occ_`w' == 1960
			
			// 2000~2999
			replace week_job_occ_`w' = 2025 if week_job_occ_`w' == 2020
			replace week_job_occ_`w' = 2145 if week_job_occ_`w' == 2140
			replace week_job_occ_`w' = 2160 if week_job_occ_`w' == 2150
			replace week_job_occ_`w' = 2825 if week_job_occ_`w' == 2820
			
			// 3000~3999
			replace week_job_occ_`w' = 3255 if week_job_occ_`w' == 3130
			replace week_job_occ_`w' = 3245 if week_job_occ_`w' == 3240
			replace week_job_occ_`w' = 3420 if week_job_occ_`w' == 3410
			replace week_job_occ_`w' = 3535 if week_job_occ_`w' == 3530
			replace week_job_occ_`w' = 3645 if week_job_occ_`w' == 3650
			replace week_job_occ_`w' = 3930 if week_job_occ_`w' == 3920
			replace week_job_occ_`w' = 3955 if week_job_occ_`w' == 3950
			
			// 4000~4999
			replace week_job_occ_`w' = 4540 if week_job_occ_`w' == 4550
			replace week_job_occ_`w' = 4965 if week_job_occ_`w' == 4960
			
			// 5000~5999
			replace week_job_occ_`w' = 5940 if week_job_occ_`w' == 5930
			
			// 6000~6999
			replace week_job_occ_`w' = 6005 if week_job_occ_`w' == 6000
			replace week_job_occ_`w' = 6355 if week_job_occ_`w' == 6350
			replace week_job_occ_`w' = 6515 if week_job_occ_`w' == 6510
			replace week_job_occ_`w' = 6765 if week_job_occ_`w' == 6760
			
			// 7000~7999
			replace week_job_occ_`w' = 7315 if week_job_occ_`w' == 7310
			replace week_job_occ_`w' = 7630 if week_job_occ_`w' == 7620
			
			// 8000~8999
			replace week_job_occ_`w' = 8250 if week_job_occ_`w' == 8230
			replace week_job_occ_`w' = 8250 if week_job_occ_`w' == 8240
			replace week_job_occ_`w' = 8255 if week_job_occ_`w' == 8260
			replace week_job_occ_`w' = 8965 if week_job_occ_`w' == 8960
		
		// Recode 2012 occup code --> EGP occup status
		recode week_job_occ_`w' ///
		(800 1320 1600 1300 300 1700 1710 1610 820 1350 1720 10 3000 1360 1005 110 1400 1640 3010 1800 230 1410 1420 1740 840 1430 2105 2100 710 1440 1450 1460 350 1650 1530 1240 360 1220 3040 1520 3050 1760 3060 3120 2200 1820 1020 1840 1230 1815 1340 1200 1210 2110 400 1500 30 = 1 "Class 1") ///
		(3250 40 500 9030 2400 740 2040 135 640 565 1106 1107 1010 1006 2000 1060 3030 2050 2830 2310 425 900 120 950 726 20 3260 136 140 1007 860 2430 700 735 50 2025 430 1860 1105 2810 3256 3258 3150 2550 3540 3245 850 3160 3110 2710 60 2825 530 150 3210 3255 4930 2320 4820 420 2010 2330 3230 1310 2840 137 650 2850 325 = 2 "Class 2") ///
		(100 4800 9040 810 5100 5120 5200 5500 540 5030 5800 1050 5350 5220 830 5230 910 5240 5810 5520 5250 5260 5165 5000 9050 5300 5.360 630 5420 5840 4810 5310 5320 2440 3500 5330 340 3510 725 5530 2160 5940 5860 5900 2340 2145 5140 5540 5150 5600 5910 3200 4920 5410 3220 4965 4840 4850 5700 2016 5920 5010 930 940 2540 5020 5160 4540 4830 1030 5630 5820 5360 5340 5830 5210 = 3 "Class 3a") ///
		(3900 9360 4530 4500 4040 9120 4720 4600 7510 4050 4740 4060 5510 3640 4950 4460 4300 4200 4320 4700 4010 4120 310 4400 4510 3655 4150 3955 3630 3645 3646 4430 4130 4520 4900 4465 4410 4350 3600 9350 4750 4610 4650 4240 3647 3649 3620 2300 5400 4620 2060 4640 4760 3930 4940 9415 3945 4420 3648 4110 5130 3610 9420 4160 = 4 "Class 3b") ///
		(520 810 2600 7150 7200 7800 4500 4040 5120 6220 8500 6230 6240 4720 4000 4600 9610 7010 6660 6320 6260 220 600 4740 5510 910 5240 2630 3320 4950 9520 9130 6330 7040 6355 7120 6200 4200 4210 4710 5000 4320 7700 4700 4010 6100 310 4250 4510 7315 630 9600 6400 4810 4220 9620 8300 7540 340 6130 8030 4230 3630 6050 2160 4520 8965 7260 2750 4350 3600 5860 2340 6420 8810 2145 5140 4610 4240 2910 6440 7430 8255 410 9650 4920 4620 4760 6515 4965 4840 4850 5700 8610 6530 7740 9000 1560 8350 9140 7420 4830 4110 8140 8910 = 5 "Class 4a") ///
		(520 2700 4800 6010 810 2600 2720 7150 7160 7200 4500 4040 5110 5120 6220 2900 7210 9120 510 8500 6230 6240 4720 6250 4000 4600 9610 1050 7010 6320 6260 220 4020 4740 5510 9510 910 2740 3310 2630 3820 4140 4950 1540 9520 9130 6330 6355 7120 2760 6710 6200 4200 4210 7000 4710 4320 7700 4700 4010 6100 8510 4250 4510 3420 7315 6730 7320 630 7330 9600 8740 4810 5310 4220 8750 9620 8300 3500 5330 7540 340 6130 8030 4230 7340 3630 3645 8760 725 6050 7750 7630 2160 9750 2860 5940 4520 8965 8550 4410 2750 4350 3600 5860 2340 8800 9640 6420 2145 4750 6300 4610 4650 4240 2910 6440 7430 2300 8255 3910 5600 410 7020 4920 4620 9720 2060 4760 6515 4965 4840 4850 5700 3930 6520 5610 8330 5620 9000 8350 940 9140 2540 7420 2920 4830 8450 4110 1030 8140 520 8540 7560 6500 6930 2960 7520 7550 9110 6310 6430 = 6 "Class 4b") ///
		(205 = 7 "Class 4c") ///
		(2700 1900 2800 2600 2720 7030 3800 1910 2900 510 4000 1920 3300 7900 6660 220 600 2740 3310 2630 3820 3320 1540 7040 7100 7110 7120 6700 3400 1550 2760 3750 3740 6200 3700 4210 7000 4710 7700 3730 3720 3710 330 1930 3420 3535 3840 1965 2860 2750 3520 2910 3850 3910 2015 410 7020 9240 9310 9000 1560 7420 2920 9410 160 3860 7050 1940 3830 = 8 "Class 5") ///
		(7140 7200 6210 6220 7210 8500 6230 6240 7010 6320 7300 9510 6330 7410 6355 6830 6120 6720 7315 7220 7320 7330 6400 8750 7540 9200 8030 7340 7350 8760 7360 7630 8630 8550 8100 8920 6420 6440 8600 7430 8250 8255 9300 7130 6520 7240 8610 6530 7740 9260 8350 8130 8620 8060 9230 = 9 "Class 6") ///
		(8850 7710 7150 7160 7800 7810 6250 8640 9610 6250 8640 9610 6260 9560 4020 3940 8650 8710 6800 4140 9520 9130 6820 7720 7730 7920 8720 6710 7830 7840 7850 4030 7855 7930 8730 8510 6360 4250 6600 7610 8950 6730 9600 8740 4220 9620 8300 6130 9630 7950 4230 5850 8040 6840 7750 6765 6940 9750 8220 8965 8460 7260 9150 8800 9640 8810 8930 6300 8830 6460 5550 5560 8310 8256 9650 6740 9720 7940 6515 8530 8320 5610 8330 5620 9140 8400 8410 8420 8940 8450 8140 8000 8200 7960 8900 8440 8160 6920 8360 8430 8020 8210 9740 8860 8120 6750 8010 9730 9730 9500 8340 8150 8840 = 10 "Class 7a") ///
		(8540 6010 4340 6005 6100 6040 6020 6110 = 11 "Class 7b") ///
		(9810 9820 9800 9830 9840 = 12 "Military") ///
		(9990 4670 6780 6170 6890 = .) /// *refused or uncodable
		(-5/-1 = .)	, gen(week_job_12egp_`w')
		
		// Recode industry (Ref. Rosigno 2019)
		recode week_job_ind_`w' (170/490 9950/9990 = 0) ///
		(770 1070/3990 6070/6390 570/690 = 1) ///
		(6470/8590 = 2) ///
		(4070/5790 8660/8690 = 3) (9370/9590 = 4) (9670/9890 = 5)
		
		// Recode job satisfaction
		gen jobsat = week_job_sat_`w'
		drop week_job_sat_`w'
		recode jobsat (1 = 5 "Like it very much") (2 = 4 "Like it fairly well") ///
		(3 = 3 "Think it is OK") (4 = 2 "Dislike it somewhat") (5 = 1 "Dislike it very much") ///
		(-5 -4 -3 -2 -1 . = .), gen(week_job_sat_`w')
		drop jobsat
		
		// Label all vars
		lab var week_job_status_`w' "Weekly Employment Status"
		lab var week_job_hour_`w' "Weekly Working Hours"
		lab var week_job_full_`w' "Full/part-time employment, recoded from weekly working hours."
		
		lab var week_job_wage_`w' "Hourly Pay"
		lab var week_job_allwage_`w' "Hourly Compensation, including overtime, tips, bonuses, etc."
		
		lab var week_job_occ_`w' "Census 2002 Occupation Code"
		lab values week_job_occ_`w' vljob_occ 
		lab var week_job_ind_`w' "Census 2002 Industry Code"
		lab values week_job_ind_`w' vljob_ind 
		lab var week_job_12egp_`w' "Occupational status, EGP 12-cat."
		lab var week_job_sat_`w' "Job Satisfaction"
		
		
	}
	 
	 fre week_job_sat_2100 /* Check if 0 is recoded. */
	 save "temp3.dta", replace
	 
	 // Gen 8-EGP
	 use "temp3.dta", clear
	 local w1 = yw(1994,6)
	 local wn = yw(2022,40)
	
	 foreach w of numlist `w1'/`wn'{ 
	 	 
		 replace week_job_12egp_`w' = . if week_job_12egp_`w' == 12
		 replace week_job_12egp_`w' = . if week_job_12egp_`w' < 0
		 
		 recode week_job_12egp_`w' (1=1 "Class 1") (2=2 "Class 2") ///
		 (3 4 = 3 "Class 3") (5 6 7 = 4 "Class 4") (8=5 "Class 5") ///
		 (9=6 "Class 6") (10 = 7 "Class 7")  (11 = 7 "Class 7") (12 = . ) (-5/-1 13 =.), gen(week_job_8egp_`w')
		
	 }
	 
	 // Check
	 list week_job_occ_2100 week_job_12egp_2100 week_job_8egp_2100 in 1/50
	 list week_job_ind_2100 week_job_status_2100 in 1/50
	 
save "step5.dta", replace 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
