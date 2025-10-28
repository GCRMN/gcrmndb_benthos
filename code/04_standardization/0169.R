# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0169" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  pivot_longer("Actinaria..Anemone.":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  select(-locality) %>% 
  rename(eventDate = date..UTC., locality = site, decimalLatitude = site_latitude,
         decimalLongitude = site_longitude, verbatimDepth = depth_m, parentEventID = transect,
         recordedBy = observer, eventID = image_name) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID, eventID, verbatimDepth,
         recordedBy, eventDate, organismID, measurementValue) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, verbatimDepth, eventDate) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 50 m transect length",
         eventDate = as.Date(eventDate),
         parentEventID = as.numeric(parentEventID),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
