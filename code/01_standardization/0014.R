# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0014" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(., na = c("", "NA", "NaN")) %>% 
  slice(-1) %>% 
  mutate(verbatimDepth = (as.numeric(min_depth) + as.numeric(max_depth))/2,
         verbatimDepth = round(verbatimDepth*0.3048, 1), # Convert depth from feet to meters
         datasetID = dataset,
         longitude = as.numeric(longitude),
         latitude = as.numeric(latitude),
         date_ = as.Date(date_),
         rep = as.numeric(as.factor(rep)),
         organismID = coalesce(genera_name, subcategory_name, category_name)) %>% 
  rename(locality = site, parentEventID	= rep, eventID = photoid, habitat = reef_zone,
         decimalLatitude = latitude, decimalLongitude = longitude, eventDate = date_,
         recordedBy = analyst) %>% 
  select(datasetID, eventDate, locality, habitat, decimalLatitude, decimalLongitude, parentEventID, 
         eventID, organismID, verbatimDepth) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat") %>% 
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
  # Add 0 values for un-observed categories
  tidyr::complete(organismID,
                  nesting(datasetID, eventDate, locality, habitat, decimalLatitude, 
                          decimalLongitude, parentEventID, eventID, verbatimDepth,
                          year, month, day, samplingProtocol),
                  fill = list(measurementValue = 0)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
