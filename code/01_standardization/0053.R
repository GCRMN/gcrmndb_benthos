# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0053" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(., na = c("NA", "na")) %>% 
  rename(eventDate = date, locality = site, decimalLatitude = Latitude,
         decimalLongitude = Longitude, verbatimDepth = Depth_Stratum) %>% 
  select(locality, eventDate, verbatimDepth, decimalLongitude, decimalLatitude) %>% 
  mutate(eventDate = as.Date(paste(str_sub(eventDate, 1, 4), 
                                   str_sub(eventDate, 5, 6), 
                                   str_sub(eventDate, 7, 8), sep = "-")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv() %>% 
  select(-picname, -island, -functional_group, -date, -prcnt, -point_count) %>% 
  rename(locality = site, parentEventID = trans_num, eventID = image_number,
         organismID = label, measurementValue = count) %>% 
  left_join(., data_site) %>% 
  group_by(locality, parentEventID, eventID, eventDate, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total,
         parentEventID = as.numeric(str_extract(parentEventID, "[1-9]")),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
