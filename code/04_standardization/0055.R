# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0055" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(., na = c("NA", "na")) %>% 
  drop_na(site) %>% 
  rename(locality = site, verbatimDepth = Depth_Stratum, eventDate = date,
         decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, verbatimDepth, decimalLatitude, decimalLongitude, eventDate) %>% 
  mutate(locality = paste0("S", locality),
         eventDate = paste(str_sub(eventDate, 1, 4), 
                           str_sub(eventDate, 5, 6), 
                           str_sub(eventDate, 7, 8),
                         sep = "-"),
         eventDate = as.Date(eventDate))

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv() %>% 
  select(-picname, -island, -functional_group, -count, -point_count) %>% 
  rename(locality = site, parentEventID = trans_num, eventID = image_number,
         organismID = label, eventDate = date, measurementValue = prcnt) %>% 
  mutate(eventDate = paste(str_sub(eventDate, 1, 4), 
                           str_sub(eventDate, 5, 6), 
                           str_sub(eventDate, 7, 8),
                           sep = "-"),
         eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         locality = paste0("S", locality),
         parentEventID = as.numeric(str_sub(parentEventID, 2,2)),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
