# MATHS-3901-Repo

## Comments:

Welcome to the MATHS 3901 Project in Maths Repository. Here I'll be keeping files and documentation concerning this course and project. When files are added, there will be a dated comment with a brief explanation of what it is. Main documentation seen here will be weekly reports, and notes concerning web page scrapers and knowledge graphs. 

__18/08/26:__ What was added: 

* `Test.R`. This is just a test file to see if the repository is working, there's nothing in here. Please ignore.

* `Week 2 Report.qmd`. This is a quarto markdown file briefly summarising findings found for the period 10th to 14th of August. ~~A pdf will be added later once this is finished.~~ A pdf file of the report has been added. See `Week-2-Report.pdf`.

* `web_scraper.R`. A prototype file scraping just names at the moment. For research and documentation see `Web Scraping in R.qmd`

* `journal_scraper.R`. Work in progress script, trying to pull data for a single page before further use on multiple pages. 

* `Knowledge Graph Research.qmd`. Self explanatory, has references and dot points looking into knowledge graphs. 

* `SMS_researchers.tsv` is the data provided to be used. 

__20/08/26:__ What was added and modified

* `web_scraper.R` Now writes out a `.rds` file of the now modified data set. See `researchers.rds`. This is only has the URLs and researcher names, omitting the xml column since that becomes unusable when saved and modified. 

* `journal_scraper.R`. Further work has been done. It reads the `rds` file then looks for a single researcher and extracts the journal publications. 