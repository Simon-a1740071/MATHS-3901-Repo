get_researcher.R:

What this script does is:
	* Scrapes the Adelaide University's researcher profiles.
	* Extracts the researcher profiles and outputs as a raw HTML text file for local use. 
	* Creates a folder of HTML text files. 
More detail:
	* This can scrape from a large list of researchers. Provided a mailing list of researchers is provided it is in ".tsv".
	* The script uses the format "firstname.lastname" and pastes it in to an established web link. Here it is using "SMS_researher.tsv".
	* This script checks for if a researcher profile has a specific HTML element that marks their name and title as the main heading.
	* If the file is empty with only "0" and the script returns a warning. Then no profile is found. 
	  Please manually check if this is the case. 

get_publications.R:

What this script does is:
	* Extracts publications data from the HTML files. 
	* Cleans the publications data and outputs as a table as a ".csv"
	* Creates a summary table in the ".csv" format of which researcher has unique publication types if any.
	* Creates a folder to store publications and summary table.
More detail:
	* This script is using HTML elements, string detects and grouping, functions from Rvest, Tidyverse to extract and clean the data.
	* Publication tables for a researcher are going to look roughly like this:

		Title | Researcher | Category | Year | Publication 						  | Author
		APrf  | Tokai Teio | Journal  | 1993 | 38th Arima Kinen December 26th 1993 at Nakayama Racecourse | Teio, T., Hayahide, B., & Nature, N.
 