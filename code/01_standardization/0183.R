# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0183" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(site_code, date, latitude, longitude, depth) %>% 
  rename(locality = site_code, eventDate = date, decimalLatitude = latitude,
         decimalLongitude = longitude, verbatimDepth = depth) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         locality = str_remove_all(locality, "_"),
         locality = str_to_upper(locality))

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  select(-functional_group) %>% 
  mutate(across(c("code", "organismID"), ~str_squish(.x)))

## 2.3 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  select(Name, Label) %>% 
  rename(locality = Name, code = Label) %>% 
  mutate(transect_quadrat = str_split_fixed(locality, "_T|_ T", 2)[,2],
         locality = str_split_fixed(locality, "_2024|_02024", 2)[,1],
         locality = str_remove_all(locality, "_"),
         locality = str_to_upper(locality),
         transect_quadrat = str_remove_all(transect_quadrat, "\\.JPG|\\.jpg"),
         parentEventID = str_sub(transect_quadrat, 1, 1),
         parentEventID = as.numeric(parentEventID),
         eventID = str_split_fixed(transect_quadrat, "_", 2)[,2],
         eventID = str_remove_all(eventID, "Q|Q_|_"),
         eventID = as.numeric(eventID)) %>% 
  left_join(., data_site) %>%
  left_join(., data_code) %>% 
  select(-transect_quadrat, -code) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  group_by(pick(everything())) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
