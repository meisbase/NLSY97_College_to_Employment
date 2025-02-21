* Last editted: 07/23/2024
* This do flie is for transforming the original data format (csv)) to dta.
* Also, it relables and renames the variables and save a new dta file.


* Import csv and transform it to dta

* Because there're too many vars
clear all
set maxvar 32767, permanently
pwd
cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Original_Data"

*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Original_Data"
import delimited "97.csv", delimiter(comma) varnames(1) case(upper) clear 

* convert csv to dta, save a back up and used data .

save "97_backup.dta",replace
run "97-value-labels"
quietly compress
cd "C:\Users\kuo.355\OneDrive - The Ohio State University\1_Second_Year_Paper\3_Data_Analysis\Data\Cleaned_Data"
*cd "/Users/kuomico/Library/CloudStorage/OneDrive-TheOhioStateUniversity/1_Second_Year_Paper/3_Data_Analysis/Data/Cleaned_Data"
save "97.dta", replace

/* If want to merge data: 

* Merge with another datset -- 0906Sup
cd "/Users/kuomico/Desktop/NLSY97/Work/Data"
import delimited "0906Sup.csv", delimiter(comma) varnames(1) case(upper) clear 
run "/Users/kuomico/Desktop/NLSY97/Work/Data/0906Sup/0906Sup-value-labels.do"
save "/Users/kuomico/Desktop/NLSY97/Work/Data/0906Sup/97_0906.dta",replace

cd "/Users/kuomico/Desktop/NLSY97/Work"
use "97.dta",replace
merge 1:1 PUBID using "/Users/kuomico/Desktop/NLSY97/Work/Data/0906Sup/97_0906.dta" 
save "97.dta",replace

* Merge with another datset -- 1220Sup
cd "/Users/kuomico/Desktop/NLSY97/Work"
use "97.dta",replace
drop _merge
save "97.dta",replace
cd "/Users/kuomico/Desktop/NLSY97/Work/Data"
import delimited "1220Sup.csv", delimiter(comma) varnames(1) case(upper) clear 
run "/Users/kuomico/Desktop/NLSY97/Work/Data/1220Sup/1220Sup-value-labels.do"
save "/Users/kuomico/Desktop/NLSY97/Work/Data/1220Sup/97_1220.dta",replace

cd "/Users/kuomico/Desktop/NLSY97/Work"
use "97.dta",replace
merge 1:1 PUBID using "/Users/kuomico/Desktop/NLSY97/Work/Data/1220Sup/97_1220.dta" 
save "97.dta",replace

*/
