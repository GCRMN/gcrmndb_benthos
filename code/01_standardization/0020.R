# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0020" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/0020/tbl_Benthic_Cover.csv") %>% 
  # 1. Join the different tables of the database
  left_join(., read_csv("data/01_raw-data/0020/tbl_Points.csv")) %>% 
  left_join(., read_csv("data/01_raw-data/0020/tlu_Taxon.csv")) %>% 
  left_join(., read_csv("data/01_raw-data/0020/tbl_Events.csv")) %>% 
  left_join(., read_csv("data/01_raw-data/0020/tbl_Locations.csv")) %>% 
  left_join(., read_csv("data/01_raw-data/0020/tbl_Sites.csv")) %>% 
  # 2. Rename and select variables
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth,
         organismID = Taxon_Name, eventDate = Start_Date, parentEventID	= Loc_Name,
         eventID = Frame, locality = Island, recordedBy = FramdIder) %>% 
  select(decimalLatitude, decimalLongitude, verbatimDepth, recordedBy,
         locality, parentEventID, eventDate, eventID, Point, organismID) %>%
  distinct() %>% 
  # 3. Calculate percentage cover (measurementValue)
  group_by(decimalLatitude, decimalLongitude, verbatimDepth, recordedBy,
           locality, parentEventID, eventDate, eventID) %>%
  mutate(total_points = n()) %>% 
  ungroup() %>% 
  group_by(decimalLatitude, decimalLongitude, verbatimDepth, recordedBy,
           locality, parentEventID, eventDate, eventID, total_points, organismID) %>%
  summarise(n_points = n()) %>% 
  ungroup() %>% 
  mutate(measurementValue = (n_points*100)/total_points) %>% 
  select(-n_points, -total_points) %>% 
  group_by(decimalLatitude, decimalLongitude, locality, eventDate) %>%
  mutate(parentEventID = as.numeric(as.factor(parentEventID))) %>% 
  ungroup() %>% 
  # 4. Add additional variables
  mutate(datasetID = dataset,
         eventDate = ymd(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat, 25 m transect length, every 1 m, na, image analyzed by 50 point count") %>% 
  # 5. Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
