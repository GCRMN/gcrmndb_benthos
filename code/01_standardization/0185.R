# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0185" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  select(-Satation_ID) %>% 
  rename(locality = "Station Name", decimalLatitude = latitude, decimalLongitude = longitude) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)),
         locality = str_split_fixed(locality, ",", 2)[,1])

## 2.2 Main data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull()

bind_rows(read_xlsx(path = data_path, sheet = 1, range = "A2:M33") %>% 
                    mutate(locality = "Curubo Beach"),
                  read_xlsx(path = data_path, sheet = 1, range = "A65:M99") %>% 
                    mutate(locality = "Adale"),
                  read_xlsx(path = data_path, sheet = 1, range = "A132:M165") %>% 
                    mutate(locality = "Warsheekh"),
                  read_xlsx(path = data_path, sheet = 1, range = "A241:M277") %>% 
                    mutate(locality = "Jaziira")) %>% 
  drop_na("Growth form") %>% 
  filter(!(`Growth form` %in% c("Hard coral", "Algae", "Other inverts", "Substrate", "Total"))) %>% 
  select(`Growth form`, locality, `% Rep-1`, `% Rep-2`, `% Rep-3`) %>% 
  pivot_longer(3:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, -1, -1))) %>% 
  left_join(., data_site) %>% 
  rename(organismID = `Growth form`) %>% 
  mutate(organismID = case_when(organismID %in% c("Branching", "Tablet", "Solitary",
                                                  "Massive", "Encrusting", "Tablet( Turbinaria)") ~ paste0("Hard coral - ", organismID),
                                TRUE ~ organismID),
         datasetID = dataset,
         year = 2024) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_path, data_site, convert_coords)
