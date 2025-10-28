# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0150" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data site ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(.x)))

## 2.2 Benthic codes ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2()

## 2.3 Main data ----

### 2.2.1 Cocos Keeling ----

data_cki <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  select(-Island, -`Year + b`, -`siteNo.`, -NationalPark, -`Σ coral`, -`Σ bleached`) %>% 
  rename(year = Year, month = Month, locality = Site, parentEventID = Transect) %>% 
  mutate(month = as.numeric(str_replace_all(month, c("Nov" = "11",
                                                     "May-BL" = "5",
                                                     "June" = "6",
                                                     "Dec" = "12"))),
         parentEventID = as.numeric(str_sub(parentEventID, 2, 2))) %>% 
  pivot_longer("HC":ncol(.), names_to = "code", values_to = "measurementValue")
  
### 2.2.2 Christmas Island ----

data_ci <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  select(-Island, -`year + 1`, -`siteNo.`, -NationalPark, -`Σ coral`, -`Σ bleached`) %>% 
  rename(year = Year, month = Month, locality = Site, parentEventID = Transect) %>% 
  mutate(month = as.numeric(str_replace_all(month, c("Nov" = "11",
                                                     "May-BL" = "5",
                                                     "July" = "7"))),
         parentEventID = as.numeric(str_sub(parentEventID, 2, 2))) %>% 
  pivot_longer("HC":ncol(.), names_to = "code", values_to = "measurementValue")

### 2.2.3 Combine the two tibbles ----

bind_rows(data_cki, data_ci) %>% 
  mutate(datasetID = dataset,
         verbatimDepth = 10) %>% 
  left_join(., data_site) %>% 
  filter(!(code %in% c("coral genera (from 2019)", "coral genera"))) %>% 
  filter(code != "HCM" & !is.na(measurementValue)) %>% 
  filter(!(year >= 2019 & code %in% c("HC", "HCP", "BHCP", "HCB", "BHCB", "HCD", "BHCD", "BLC", "BPHC"))) %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code, data_cki, data_ci)
