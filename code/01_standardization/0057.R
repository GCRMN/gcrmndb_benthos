# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0057" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(site_code = "Site code", decimalLatitude = "lat", decimalLongitude = "lng", locality = "Site name") %>% 
  select(site_code, locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xls(., sheet = 2, skip = 3, col_names = c("row", "site_code", "year", "reef", "zone", "site_num", "sum",
                                                 "Coral Acropora branching", "Coral Acropora digitate",	"Coral Acropora tabular",
                                                 "Coral branching", "Heliopora", "Millepora",	"Coral Tubastrea", "Coral foliose/Fungidae",
                                                 "Coral massive",	"Others Clams",	"Coral encrusting", "Coralline Algae",
                                                 "Others Corallimorpharians", "Others Palythoa",	"Soft corals azooxanthellatae",
                                                 "Soft corals zooxanthellatae", "Fleshy Algae",	"Sponges", "Others Tunicates",
                                                 "Others Fan & feather corals", "Others Whip & wire corals",
                                                 "Dead coral", "Coral rock", "Coral rubble", "Sand", "Bleached Corals",
                                                 "...1", "Hard corals", "...2", "note")) %>% 
  select(-sum, -"...34", -"Hard corals", -"...36", -"note", -"reef", -"zone", -"row", -"site_num") %>% 
  # Create parentEventID
  group_by(site_code, year) %>% 
  mutate(parentEventID = seq(1:3), .before = year) %>% 
  ungroup() %>% 
  pivot_longer("Coral Acropora branching":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(measurementValue = replace_na(measurementValue, 0),
         site_code = as.numeric(site_code)) %>% 
  left_join(., data_site) %>% 
  select(-site_code) %>% 
  mutate(datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
