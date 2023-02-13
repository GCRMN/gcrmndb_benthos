# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format

dataset <- "0011" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(., na = c("", "NA", "NaN")) %>% 
  slice(-1) %>% 
  mutate(verbatimDepth = (as.numeric(MIN_DEPTH) + as.numeric(MAX_DEPTH))/2,
         verbatimDepth = round(verbatimDepth*0.3048, 1), # Convert depth from feet to meters
         datasetID = dataset,
         longitude = as.numeric(longitude),
         latitude = as.numeric(latitude),
         DATE_ = as.Date(DATE_),
         REPLICATE = as.numeric(as.factor(REPLICATE)),
         organismID = coalesce(GENERA_NAME, SUBCATEGORY_NAME, CATEGORY_NAME)) %>% 
  rename(locality = SITE, parentEventID	= REPLICATE, eventID = PHOTOID, habitat = REEF_ZONE,
         decimalLatitude = latitude, decimalLongitude = longitude, eventDate = DATE_,
         recordedBy = ANALYST) %>% 
  select(datasetID, eventDate, locality, habitat, decimalLatitude, decimalLongitude, parentEventID, 
         eventID, organismID, verbatimDepth) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  # Calculate the number of points per image
  group_by(across(c(-organismID))) %>% 
  mutate(total_points = n()) %>% 
  ungroup() %>% 
  # Calculate the number of points per benthic categories within image
  group_by_all() %>% 
  summarise(n_points = n()) %>% 
  ungroup() %>% 
  # Calculate percentage cover
  mutate(measurementValue = (n_points/total_points)*100) %>% 
  select(-total_points, -n_points) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
