pacman::p_load(tidyverse, rvest, purrr) #load libraries

researchers <- #reads .tsv file
  read_tsv("SMS_researchers.tsv", col_names = FALSE) |>
  rename(urls = X1) |> #renames first column
  as_tibble()

researchers |> #paste weblink with urls column together
  mutate(urls = paste0("https://researchers.adelaide.edu.au/profile/",
                       researchers$urls)) -> researchers

researchers |>
  mutate(
    pages = map(urls, read_html)
  ) -> researchers

pubs <-
  c("Journals", "Books", "Book Chapters", "Conference Papers",
    "Conference Items", "Report for External Bodies", "Patents",
    "Internet Publications", "Preprint")

get_researcher <- #function to grab all the names of researchers
  function(pages){
    researcher <-
      html_node(pages, ".docs-heading") |>
      html_text(trim = TRUE)
    
    if (length(researcher) == 0) {
      return(NA_character_)
    }
    else{
      return(researcher)
    }
  }

get_journals <- 
  function(pages){
    contents <-
      pages |>
      html_elements(".accordion-item") |>
      html_text2() 
    
    headings <- 
      pages |>
      html_elements("h1, h2, h3, h4, h5, h6")
    
    journal <- character(0)
    
    for(heading in headings){
      heading_text <- 
        html_text2(heading)
      
      if(stringr::str_detect(heading_text, "Journals")){
        information <-
          heading |>
          html_element(xpath = "following-sibling::*[1]") |>
          html_text2()
        
        journal <- c(journal, information)
      }
    }
    if (length(journal) == 0){
      return(NA_character_)
    }
    else{
      return(paste(journal, collapse = "; "))
    }
  }

get_book <-
  function(pages){
    contents <-
      pages |>
      html_elements(".accordion-item") |>
      html_text2() 
    
    headings <- 
      pages |>
      html_elements("h1, h2, h3, h4, h5, h6")
      
    book <- character(0)
    
    for(heading in headings){
      heading_text <- 
        html_text2(heading)
      
      if(stringr::str_detect(heading_text, "Books")){
        information <-
          heading |>
          html_element(xpath = "following-sibling::*[1]") |>
          html_text2()
        
        book <- c(book, information)
      }
    }
    if (length(book) == 0){
      return(NA_character_)
    }
    else{
      return(paste(book, collapse = "; ")) 
    } #joins into one string with ; between
  }

get_information <-
  function(pages, heading_name){
    headings <- 
      pages |>
      html_elements("h1, h2, h3, h4, h5, h6")
    
    information <- character(0)
    
    for(heading in headings){
      heading_text <- 
        html_text2(heading)
      
      if(stringr::str_detect(heading_text, heading_name)){
        content <-
          heading |>
          html_element(xpath = "following-sibling::*[1]") |>
          html_text2()
        
        information <- c(information, content)
      }
    }
      if (length(information) == 0){
        return(NA_character_)
      }
      else{
        return(paste(information, collapse = "// ")) 
      } #joins into one string with ; between
    }

researchers |> 
  mutate(
    researcher = map_chr(pages, 
                         \(pages) get_researcher(pages))) |>
  bind_cols(
    map_dfc(pubs, \(pub_name){
      tibble(!!pub_name := map_chr(researchers$pages,
                                   get_information,
                                   heading_name = pub_name))
    }
    )
  ) -> researchers
  
researchers |>
  select(-pages, -urls) |>
  write_csv("researcher.csv")
  
