# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0212" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Coordinates") %>% 
  rename(locality = Site, decimalLatitude = Lat, decimalLongitude = Long) %>% 
  select(locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., na = c("NA")) %>%
  rename(eventDate = Date, locality = Site, parentEventID = Transect, eventID = Quadrat,
         organismID = Benthic_category, measurementValue = Percent, verbatimDepth = Relative_depth) %>% 
  select(eventDate, locality, parentEventID, eventID, verbatimDepth, organismID, measurementValue) %>% 
  left_join(., data_site) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         verbatimDepth = case_when(verbatimDepth == "deep" ~ 14.5,
                                   verbatimDepth == "shallow" ~ 8),
         organismID = case_when(organismID == "DC" ~ "Dead coral",
                                organismID == "CCA_DC" ~ "CCA on dead coral",
                                TRUE ~ organismID),
         parentEventID = parse_number(parentEventID)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
