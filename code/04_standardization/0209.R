# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0209" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(decimalLatitude2 = decimalLatitude, decimalLongitude2 = decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  left_join(., data_site) %>%
  mutate(decimalLatitude = coalesce(decimalLatitude, decimalLatitude2),
         decimalLongitude = coalesce(decimalLongitude, decimalLongitude2)) %>%
  select(-decimalLatitude2, -decimalLongitude2) %>% 
  select(-location, -scientificNameAccepted) %>% 
  rename(year = eventDate, organismID = functional_group) %>% 
  filter(organismID != "other") %>% 
  mutate(organismID = case_when(organismID == "Algae" ~ "Macroalgae",
                                TRUE ~ organismID)) %>% 
  # sum for identical benthic categories
  group_by(locality, decimalLatitude, decimalLongitude, eventID, year, organismID) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  ungroup() %>% 
  # Mean per site since eventID is present but not parentEventID
  group_by(locality, decimalLatitude, decimalLongitude, year, organismID) %>% 
  summarise(measurementValue = mean(measurementValue)) %>% 
  ungroup() %>% 
  mutate(samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
