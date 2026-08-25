pacman::p_load(rvest, tidyverse)

readRDS("researchers.rds") -> researchers

Pudney <- researchers |>
  filter(researcher == "Prof Peter Pudney") |>
  pull(urls) |>
  read_html()

Pudney |> 
  html_text2()

Pudney |>
  html_element(".accordion-button") |>
  html_attr("data-bs-target")

Pudney |>
  html_elements(".accordion-item") |>
  length()

Pudney |>
  html_elements(".accordion-item") |>
  map(html_text2) |>
  purrr::keep(\(contents) stringr::str_detect(contents, "Journals"))

Pudney |>
  html_elements(".accordion-item") |>
  map(html_text2) |>
  stringr::str_detect("Books")

Pudney |>
  html_elements(".accordion-item") |>
  map(html_text2) |>
  purrr::keep(\(contents) stringr::str_detect(contents, "Books"))
