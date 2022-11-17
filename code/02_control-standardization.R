# 1. Load packages ----

library(tidyverse)

# 2. List of individual data standardization scripts ----

list_path <- list.files("R/01_standardization/", full.names = TRUE)

# 3. Run all scripts ---- 

walk(list_path, ~source(.)) # walk() is from the map family (purrr)
