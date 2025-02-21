
// Import Cweight

/*
* This is a custom combined weight across used waves.
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Weight"
	import delimited "weight.dat", delim(" ") 
	rename v1 id 
	rename v2 cweight
	save "weight.dta", replace

*/


	****************	
	* Select data *
	****************
	clear all
	
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	// For X_M
	*use "used_M.dta", clear

	// For X_Y, lagged
	use "used_Y.dta", clear
	
	// For X_Y, unlagged
	*use "used_Y_unlagged.dta", clear
		
***********************************************************************	

	*************************************
	* Generate Tables, Time-invariant  *
	*************************************

	// Merge with Custom_Weight_NLSY97
	*cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Weight"
	*merge m:1 id using "weight.dta"
	*keep if _merge == 3
	
	*save "test.dta", replace
	
	***********************************
	* Clean var category, name, label *
	***********************************
	*use "test.dta", clear
	
	// Gen sum of pos/neg EMP transitions of each id
	bysort id: egen sum_pos = total(shift_pos)
	bysort id: egen sum_neg = total(shift_neg)
	bysort id: gen countid = _N
	
	gen avg_pos = sum_pos / countid
	gen avg_neg = sum_neg / countid
	
	list id age_BA countid sum_pos avg_pos sum_neg avg_neg in 1/30
	
	// Keep the first obs of each id
	bysort id (age_BA): keep if _n == 1
	count
	
	// Relabel vars
	lab var gender "R's gender"
	lab var race "R's race/ethnicity"
	lab var major_apst "R's college major"
	lab var census_region "Region"
	lab var census_msa "Metropolitan Area"
	lab var job_ind "Industry/Sector"
	lab var fm_status "Marital Status"
	lab var child_all_bi ">=1 Child in Residence"
	lab define vlevent 0 "Non Occururence" 1 "Occururence"
	lab values shift_pos vlevent
	lab values shift_neg vlevent
	
	*************************************
	* Tabout with Custom_Weight_NLSY97  *
	*************************************
	
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	// Set sample weight
	*svyset [pw=cweight]
	
	/*
	11/12/2024
	
	I do not weight the sample so far.
	1) The stats in categorical variables are strange.
	2) Schneider (2019) paper on demography did not weight the sample in desc.stats, either
	
	*/
	
	// Categorical Xs : race, major_apst
	tabout race major_apst gender using T12.xls, replace ///
cells(freq col) format(0c 2p) clab(n %) h2("Table 1. Descriptive Statistics of Time-Invariant Characteristics in Used Sample.")

	// Numerical Xs : age, ln(first_wage)
	global var_stat "median age median avg_pos median avg_neg median wage_first"
	global var_stat "Age_of_BA Positive_Transition Negative_Transition Ln(First_Wage)"
	
	tabout gender using T12.xls, append ///
	c(median age median avg_pos median avg_neg median wage_first) ///
	clab(Age_of_BA Positive_Transition Negative_Transition Ln(First_Wage)) f(2c) sum
	
	
**************************************************************************************	
	
	**********************************
	* Generate Tables, Time-varying *
	**********************************

	
	****************	
	* Select data *
	****************
	clear all
	
	* For Office-PC
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\cleaned_Data\R"
	
	* For Macbook
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data/R"
	
	// For X_M
	use "used_M.dta", clear

	// For X_Y, lagged
	*use "used_Y.dta", clear
	
	// For X_Y, unlagged
	*use "used_Y_unlagged.dta", clear
	
	***********************************
	* Clean var category, name, label *
	***********************************

	// Relabel vars
	lab var gender "R's gender"
	lab var race "R's race/ethnicity"
	lab var major_apst "R's college major"
	lab var census_region "Region"
	lab var census_msa "Metropolitan Area"
	lab var job_ind "Industry/Sector"
	lab var fm_status "Marital Status"
	lab var child_all_bi ">=1 Child in Residence"
	lab define vlevent 0 "Non Occururence" 1 "Occururence"
	lab values shift_pos vlevent
	lab values shift_neg vlevent
	lab var job_full "Emp. Status"
		
	*************************************
	* Tabout with Custom_Weight_NLSY97  *
	*************************************
	
	*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Tables"
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Tables"
	
	// Set sample weight
	*svyset [pw=cweight]
	
	/*
	11/12/2024
	
	I do not weight the sample so far.
	1) The stats in categorical variables are strange.
	2) Schneider (2019) paper on demography did not weight the sample in desc.stats, either
	
	*/
	
	// Categorical Xs : race, major_apst
	tabout census_region census_msa  ///
	job_ind fm_status child_all_bi shift_pos shift_neg gender using T12.xls, append ///
cells(freq col) format(0c 2p) clab(n %) h2("Table 2. Descriptive Statistics of Time-Varying Characteristics in Used Sample.")

	// Numerical Xs : ln(wage)
	tabout gender using T12.xls, append ///
	c(median wage) ///
	clab(Ln(Wage)) f(2c) sum
	
	
	
	
	
	
	
	
	
	
	
	
	
