# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format

dataset <- "0005" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = ., na.strings = c("", "NA")) %>% 
  select(locality, decimalLatitude, decimalLongitude)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., 
            sheet = 1, 
            col_types = c("date", "numeric", "text", "text", "text", "text", "numeric", "text", 
                          "numeric", "text", "text", "text")) %>%
  rename(eventDate = "date", locality = "île x site", recordedBy = "identificateur", eventID = "n° quadrat",
         organismID = "genre", measurementValue = "recouvrement %") %>% 
  select(eventDate, locality, recordedBy, eventID, organismID, measurementValue) %>% 
  filter(measurementValue != 0) %>% 
  mutate(datasetID = dataset,
         eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         habitat = "Outer slope", # cf website SNO Corail
         verbatimDepth = 10, # Depth between 7 and 13 meters (cf website SNO Corail)
         samplingProtocol = "Photo-quadrat, 20 m transect length, every 1 m, area of 1 x 1 m, image analyzed by 81 point count") %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
