# package load
pacman::p_load(tidyverse, rvest, stringr) 

# Summary Table: 
get_headings <- #function to grab all headings under publications
  function(files){
    pages <-
      read_html(files)
    
    researcher <-
      pages |>
      html_element(".docs-heading") |>
      html_text2()
    
    pages |>
      html_elements("button.nav-link") |>
      html_text2() |>
      str_detect("Publications") |>
      any() -> has_pubs
    
    if (has_pubs == TRUE){
      pages |>
        html_elements("button.nav-link:contains('Publications')") |>
        html_attr("data-bs-target") -> pub_id
      
      category <-
        pages |>
        html_element(pub_id) |>
        html_elements("h1, h2, h3, h4, h5, h6") |>
        html_text2() |>
        str_c(collapse = " | ")
    }
    else{
      category <- NA_character_
    }
    
    tibble(researcher, has_pubs, category)
  }

get_publications <- 
  function(files){
    pages <-
      read_html(files)
    
    elem <- ".accordion-button, h1, h2, h3, h4, h5, h6" #html elements
    
    researcher <- #names
      pages |>
      html_element(".docs-heading") |>
      html_text2()
    
    has_pubs <- # publication check
      pages |> 
      html_elements("button.nav-link") |>
      html_text2() |>
      str_detect("Publications") |>
      any()
    
    if (has_pubs == TRUE){
      pub_id <-
        pages |>
        html_elements("button.nav-link:contains('Publications')") |>
        html_attr("data-bs-target")
      
      pub_blocks <- 
        pages |>
        html_element(pub_id) |>
        html_elements(".accordion-item")
      
      if (length(pub_blocks) == 0){
        pub_blocks <-
          pages |>
          html_element(pub_id) |>
          html_children() |>
          keep(~ length(html_elements(.x, elem)) > 0)
      }
      
      category <- #publication type
        pub_blocks |>
        map_chr(~ {
          .x |>
            html_element(elem) |>
            html_text2()
        })
      
      pub_data <- #data extraction
        pub_blocks|> 
        map(~ {#target spans strictly inside citation cells, links or pub blocks
          spans <-.x |>
            html_elements("tr, li, p, td[data-th='Citation']") |>
            html_text2() |>
            str_trim() |>
            #remove empty spans, short UI tags and stray action buttons
            keep(~ nchar(.x) > 15 & !str_detect(.x, "^(?i)(pdf|doi|view|download|link)$")) |>
            unique()
          
          if (length(spans) == 0){
            spans <-
              .x |>
              html("tf, div.citation") |>
              html_text2() |>
              str_trim() |>
              keep(~ nchar(.x) > 15 & !str_detect(.x, "^(?i)(pdf|doi|view|download|link)$")) |>
              unique()
          }
          
          if (length(spans) == 0){
            NA_character_
          } else {
            spans
          }
        })
      
      df <- #tibble df, unnest lists into rows
        tibble(researcher, category = category, pub_data) |>
        unnest_longer(pub_data) |>
        filter(!is.na(pub_data)) |>
        mutate(pub_data = str_squish(pub_data)) |>
        distinct(researcher, category, pub_data, .keep_all = TRUE) |>
        group_by(researcher, category) |>
        mutate(row = row_number()) |>
        ungroup() |> #temp index so unequal lengths pivot correctly
        pivot_wider(names_from = category,
                    values_from = pub_data) |>
        select(-any_of("row")) #drops temp index cols, and researcher names
    }
    else{
      df <-
        tibble(researcher)
    }
    df
  }

data_clean <-
  function(files){
    df <- map_df(files, get_publications)
    
    final_df <-
      df |>
      ungroup() |>
      pivot_longer( # category col
        cols = -researcher,
        names_to = "category",
        values_to = "pub_data",
        values_drop_na = TRUE ) |> # year col
      mutate(year = str_extract(pub_data, "\\b(19|20)\\d{2}\\b")) |>
      mutate( # titles
        # extracts text after (YYYY).
        publication = case_when(
          str_detect(pub_data, "\\(\\d{4}\\)\\.") ~
            str_remove(pub_data, "^.*?\\(\\d{4}\\)\\.\\s*") |>
            str_trim(),
          
          # if it has ". (n.d.)", extract text after
          str_detect(pub_data, "\\.\\s*\\(n\\.d\\.\\)") ~
            str_remove(pub_data, "^.*?\\.\\s*\\(n\\.d\\.\\)\\.?\\s*") |>
            str_trim(),
          
          # anything left over
          TRUE ~ str_trim(pub_data)
        )
      ) |>
      mutate(
        # extracts text before "(YYYY)."
        author = case_when(
          str_detect(pub_data, "\\(\\d{4}\\)\\.") ~
            str_remove(pub_data, "\\s*\\(\\d{4}\\)\\..*$") |>
            str_trim(),
          
          # if it has ". (n.d.)", extract text before
          str_detect(pub_data, "\\.\\s*\\(n\\.d\\.\\)") ~
            str_remove(pub_data, "\\.\\s*\\(n\\.d\\.\\)\\..*$") |>
            str_trim(),
          
          # NA if nothing
          TRUE ~ NA_character_
        )
      ) |>
      mutate(
        author = str_remove_all(author, "\\b(19|20)\\d{2}\\b") |>
          str_trim()
      ) |>
      mutate( # researcher name and their title. add more titles in b(TITLES)\\b
        title = str_extract(researcher, "(?i)\\b(APrf|Dr|Mrs|Ms|Prof)\\b\\.?") |>
          str_squish(),
        researcher = str_remove_all(researcher, "(?i)\\b(APrf|Dr|Mrs|Ms|Prof)\\b\\.?")
      ) |>
      mutate(researcher = str_squish(researcher),
             category = str_squish(category)) |>
      select(title, researcher, category, year, publication, author)
    
    final_df
  }

save_pubs <-
  function(files){
    tryCatch({
      df <- 
        data_clean(files)
      
      df_names <-
        get_headings(files)
      
      researcher <- #extracts researcher name
        unique(df_names$researcher)
      
      #check name exists
      if (!is.na(researcher) &&  length(researcher) > 0 && researcher != ""){
        
        clean_name <- #name sanitisation 
          gsub("[^a-zA-Z0-9_-]", "-", researcher)
        clean_name <- gsub("-+", "-", clean_name)
        
        #saves output as CSV
        write_csv(df, paste0("publications/", clean_name, ".csv"))
      } else {
        warning(paste0("Researcher name not found in ", files))
      }
    },
    error = function(e){
      warning(paste0("Error processing file ", files, ": ", e$message))
    })
  }

#1. Create output folder
dir.create("publications", showWarnings = FALSE)

#2. Get html files
html <-
  list.files("html", pattern = "\\.html$", full.names = TRUE)

#3. iterate through all files and execute function
purrr::walk(html, save_pubs)

#4. summary table, make sure folder is closed
df <- 
  map_df(html, get_headings)

readr::write_csv(df, "publications/Summary.csv")
