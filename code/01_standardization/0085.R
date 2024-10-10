# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0085" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  select(-Baseline, -Name, -Zone, -Date_surveyed) %>% 
  rename(locality = Site, decimalLatitude = Lat, verbatimDepth = Depth,
         decimalLongitude = Long) %>% 
  # Add missing site (obtained from the file Bermuda2021Monitoring_Smith_SPAW_RAQ2024)
  add_row(locality = 60, decimalLatitude = 32.4014, decimalLongitude = -64.8093, verbatimDepth = 12)

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2, range = "A19:B44") %>% 
  rename(code = 1, organismID = 2) %>% 
  bind_rows(., tibble(code = c("LopVar", "SIDRAD", "CMOR"),
                      organismID = NA))

## 2.3 Main data ----

### 2.3.1 2015 data ----

data_main_2015 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  select(Site, Trans, Image, Label) %>% 
  rename(locality = Site, parentEventID = Trans, eventID = Image, code = Label) %>% 
  # Transform from number of points to percentage cover
  group_by(locality, parentEventID, eventID, code) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, eventID) %>%
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total) %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  mutate(year = 2015)
  
### 2.3.2 2016 data ----

data_main_2016 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  select(Site, Trans, Image, Label) %>% 
  rename(locality = Site, parentEventID = Trans, eventID = Image, code = Label) %>% 
  # Transform from number of points to percentage cover
  group_by(locality, parentEventID, eventID, code) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, eventID) %>%
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total) %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  mutate(year = 2016)

### 2.3.3 2021 data ----

data_main_2021 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "master") %>%
  select("Site...1", "Benthic...8") %>% 
  mutate(locality = str_split_fixed(Site...1, "_", 4)[,1],
         parentEventID = str_split_fixed(Site...1, "_", 4)[,3],
         eventID = str_split_fixed(Site...1, "_", 4)[,4]) %>% 
  mutate(across(c("locality", "parentEventID", "eventID"), ~as.numeric(.))) %>% 
  rename(code = "Benthic...8") %>% 
  select(-"Site...1") %>% 
  # Transform from number of points to percentage cover
  group_by(locality, parentEventID, eventID, code) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, eventID) %>%
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total) %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  mutate(year = 2021)

### 2.3.4 Bind datasets ----

bind_rows(data_main_2015, data_main_2016, data_main_2021) %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  mutate(datasetID = dataset,
         locality = paste0("S", locality)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main_2015, data_main_2016, data_main_2021, data_code, data_site)
