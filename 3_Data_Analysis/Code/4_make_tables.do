* Last editted: 03/31/2024
* This do flie is for making tables.

* To-do list


/******************************************************************************/
/*1: Set up & load data*/
/******************************************************************************/
	pwd
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_2024_second year paper draft\3_data analysis\Code"

	log using "4_make_tables", replace


/******************************************************************************/
/*2: Tabout desc stats                                                        */
/******************************************************************************/
	
	cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_2024_second year paper draft\3_data analysis\Tables"
	* svyset [pw=rwtresp]
	
	* For categorical vars
	gen dummy = 1
	tabout Y1 gender racep edu_degree dummy using cat.xls, replace cells(freq col) clab(n col%) f(2)
	
	* For continuous vars
	tabout dummy using cont.xls, replace svy oneway c(mean Y2) sum clab (Y2) f(2) ptotal(none)
	foreach var of varlist age{
			tabout dummy using cont.xls, append svy oneway ///
			c(mean `var') sum clab (`var') f(2) ptotal(none)
	}
		
	
/******************************************************************************/
/*99: Done                                                      */
/******************************************************************************/
log close
