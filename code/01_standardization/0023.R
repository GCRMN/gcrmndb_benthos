# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0023" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(.) %>% 
  select(-Zone) %>% 
  rename(station = Station, decimalLatitude = Latitude, decimalLongitude = Longitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., na = "NA") %>% 
  left_join(., data_site) %>% 
  rename(parentEventID = transect, eventDate = date, measurementValue = "%", locality = station) %>% 
  mutate(eventDate = as_date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Line intersect transect, 20 m transect length",
         verbatimDepth = 3,
         locality = str_to_sentence(locality),
         parentEventID = str_sub(parentEventID, -1),
         parentEventID = as.numeric(parentEventID),
         organismID = coalesce(genre_corallien, famille_corallienne, categorie_detaillee, categorie_intermediaire, categorie_generale)) %>% 
  select(-genre_corallien, -famille_corallienne, -categorie_detaillee, -categorie_intermediaire,
         -categorie_generale, -morpho_corallienne, -distance, -lineaire, -campagne) %>% 
  # Correct a wrong date for a transect
  mutate(eventDate = ifelse(eventDate == as_date("2022-02-18") & locality == "Uare" & parentEventID == 2, 
                            as_date("2022-02-17"), 
                            eventDate),
         eventDate = as_date(eventDate)) %>% 
  group_by(across(c(-measurementValue))) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  ungroup() %>% 
  # Add 0 values for un-observed categories
  tidyr::complete(organismID,
                  nesting(eventDate, locality, parentEventID, decimalLatitude, decimalLongitude,
                          year, month, day, datasetID, samplingProtocol, verbatimDepth),
                  fill = list(measurementValue = 0)) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
