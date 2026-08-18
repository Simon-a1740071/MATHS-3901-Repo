pacman::p_load(rvest, tidyverse, chromote)

url <-
  "https://researchers.adelaide.edu.au/profile/nicholas.fewster-young"

page <-
  read_html_live(url)

page$click("button#tab-2.nav-link")

page$view()

Sys.sleep(1) #adds a delay so R doesn't immediately start the next function

