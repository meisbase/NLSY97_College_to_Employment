* Last editted: 07/23/2024
* Author: Mei
* Title: SOP when importing new NLSY97 dataset

	*1 : correct "97_MMDD_value-labels.do"
		*1 : KEY! --> KEY_
		*2 : delete /* */
		
	*2 : rename new NLSY97 files
		*1 : "97_MMDD_value-labels.do" --> "97-value-labels.do"
		*2 : "97_MMDD.csv" --> "97.csv"
		
	*3 : delete all files in "Data\Original_Data"
		* This step ensure you can recover everything just in case.
		* Replacement will wipe out the old files. 
	
	*4 : paste all the new files into "Data\Original_Data"
		* Be careful -- not to move the file "Readme_when_download_new_NLSY97.txt"!	
	*5: test
		*1: Go to "Code".
		*2: Run "1_csv_to_dta.do".

	*6: check output
		* There should be a file "97.dta" in "Data\Cleaned_Data".