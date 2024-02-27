# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0052" # Define the dataset_id

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
  mutate(eventDate = as.Date(eventDate),
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
  pivot_longer("Acropora":ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  select(-Habitat, -Locality, -Island, -File) %>% 
  rename(locality = Site, parentEventID = Transect, eventID = Quadrat) %>% 
  left_join(., data_site) %>% 
  group_by(locality) %>% 
  mutate(parentEventID = as.numeric(as.factor(parentEventID))) %>% 
  ungroup() %>% 
  group_by(locality, parentEventID) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
