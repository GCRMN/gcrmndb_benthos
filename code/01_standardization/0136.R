# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0136" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 3) %>% 
  rename(locality = Site, decimalLatitude = `GPS (south)`,
         decimalLongitude = `GPS (east)`, eventDate = Date) %>% 
  select(locality, decimalLatitude, decimalLongitude, eventDate) %>% 
  mutate(decimalLatitude = -decimalLatitude,
         eventDate = as.Date(eventDate))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .) %>% 
  pivot_longer("Acropora - Tabular":"Pavement", values_to = "measurementValue", names_to = "organismID") %>% 
  drop_na(measurementValue) %>% 
  rename(eventDate = Date, locality = Site, parentEventID = Transect, verbatimDepth = Depth) %>% 
  select(eventDate, locality, parentEventID, verbatimDepth, organismID, measurementValue) %>% 
  mutate(eventDate = as.Date(eventDate),
         parentEventID = as.numeric(parentEventID),
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 50 m transect length, every 50 cm") %>% 
  distinct() %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
