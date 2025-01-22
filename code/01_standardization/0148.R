# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0148" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2(., fileEncoding = "latin1") %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x)),
         decimalLongitude = -decimalLongitude)

## 2.2 Main data ----

### 2.2.1 2001 to 2010 data ----

data_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos") %>% 
  rename(year = YEAR, month = MONTH, code = SITE, organismID = SPECIES) %>% 
  left_join(., data_site) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, month, organismID, Position, Intercept) %>% 
  mutate(month = as.numeric(str_sub(month, -2, -1))) %>% 
  # Convert intercept (i.e. distance) to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, year, month, organismID) %>% 
  summarise(measurementValue = sum(Intercept)) %>% 
  ungroup() %>% 
  group_by(locality, decimalLatitude, decimalLongitude, year, month) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total,
         samplingProtocol = "Line Intercept Transect, 60 m transect length")

### 2.2.2 2011 to 2019 data ----

data_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  rename(year = YEAR, month = MONTH, code = SITE, parentEventID = TRANSECT,
         organismID = SPECIES) %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, -1, -1)),
         organismID = ifelse(is.na(organismID), CODE_SP, organismID),
         organismID = str_replace_all(organismID, "UDOT", "Udotea")) %>%
  left_join(., data_site) %>% 
  select(-code, -ID, -CODE_SP, -CODE_BENTH) %>% 
  # Convert number of points to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, year, month, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, year, month) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total,
         samplingProtocol = "Photo-quadrat, 50 m transect length")
  
### 2.2.3 Combine the two tibbles ----
  
bind_rows(data_b, data_a) %>% 
  select(-total) %>% 
  mutate(datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_a, data_b, convert_coords)
