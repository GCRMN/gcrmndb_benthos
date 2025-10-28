# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(mermaidr) # API to mermaid data. To install -> remotes::install_github("data-mermaid/mermaidr")

mermaid_projects <- mermaid_get_projects()

included_datasets_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv")

pacific_mermaid_projects <- mermaid_projects %>% 
  filter(if_any(.cols = c(name, countries), 
                .fns = ~str_detect(., pattern = "Fiji|Papua New Guinea|Vanuatu|Micronesia, Federated States of|
                                   Solomon Islands|Samoa|Tonga"))) %>% 
  # Remove already integrated datasets
  filter(!(id %in% unique(included_datasets_paths$project_id))) %>% 
  arrange(-num_sites)
  
