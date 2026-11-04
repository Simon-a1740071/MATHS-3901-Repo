#package load
pacman::p_load(rvest, tidyverse)

#reads .tsv file
researchers <- 
  read_tsv("SMS_researchers.tsv", col_names = FALSE) |>
  rename(name = X1) |> #renames first column
  as_tibble()

prefix <-
  "https://researchers.adelaide.edu.au/profile/"

get_researcher <- #function to grab all the html of researchers
  function(name){
    tryCatch({
      page <-
        read_html(paste0(prefix, name))
      
      if(!is.na(html_element(page, ".docs-heading"))){
        #saves as text
        writeLines(as.character(page), paste("html/", name, ".html"))
        
      }
      else{
        warning(paste0(name, " not found"))
        writeLines(paste("html/", name, ".html")) 
      }
      Sys.sleep(1) #pause for 1 second 
    },
      error = function(e) {
        warning(paste0(name, " not found"))
        writeLines(paste("html/", name, ".html"))
      }
    )
  }
      

dir.create("html", showWarnings = FALSE) #creates a folder
#goes through all the pages and runs the function.
purrr::walk(researchers$name, get_researcher)
