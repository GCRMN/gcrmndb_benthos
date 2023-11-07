# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0043" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(., na = c("NA", "na")) %>% 
  rename(locality = site, decimalLatitude = Latitude, eventDate = date,
         decimalLongitude = Longitude, verbatimDepth = Depth_Stratum) %>% 
  mutate(eventDate = case_when(str_detect(eventDate, "-") == TRUE ~ 
                                 format(strptime(eventDate, "%d-%b-%y"), "%Y-%m-%d"),
                               TRUE ~ format(strptime(eventDate, "%Y%m%d"), "%Y-%m-%d")),
         eventDate = as_date(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  select(-Island, -Station_ID, -island) %>% 
  distinct()

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv() %>% 
  rename(eventDate = date, locality = site, parentEventID = trans_num,
         eventID = image_number, measurementValue = prcnt) %>% 
  mutate(samplingProtocol = "Photo-quadrat",
         organismID = paste(functional_group, "-", label),
         parentEventID = as.numeric(gsub("\\D", "", parentEventID)),
         eventID = as.numeric(gsub("\\D", "", eventID)),
         eventDate = case_when(str_detect(eventDate, "-") == TRUE ~ 
                               format(strptime(eventDate, "%d-%b-%y"), "%Y-%m-%d"),
                             TRUE ~ format(strptime(eventDate, "%Y%m%d"), "%Y-%m-%d")),
         eventDate = as_date(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  select(-picname, -island, -functional_group, -label, -count, -point_count) %>% 
  filter(measurementValue != 0) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
