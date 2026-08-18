pacman::p_load(tidyverse, rvest, purrr)

researchers <-
  read_tsv("SMS_researchers.tsv", col_names = FALSE) |>
  rename(urls = X1) |>
  as.tibble() |>
  mutate(urls = paste0("https://researchers.adelaide.edu.au/profile/",
                       researchers$urls))

researchers |>
  mutate(
    pages = map(urls, read_html)
  ) |>
  mutate(
    researcher = map_chr(
    pages,
    function(pages){
      html_node(pages, ".docs-heading") |>
        html_text(trim = TRUE)
    }
    )
  ) -> researchers
