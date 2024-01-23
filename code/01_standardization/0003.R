# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0003" # Define the dataset_id

# 2. Import, standardize and export the data ----

Sys.setlocale("LC_TIME", "C") # Set parameters for date transformation

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(file = .) %>% 
  mutate(datasetID = dataset,
         locality = paste(REEF_NAME, SITE_NO, sep = " - ")) %>% 
  select(-VISIT_NO, -REEF_NAME, -SITE_NO, -FULLREEF_ID, -YEAR_CODE, -A_SECTOR) %>% 
  rename(decimalLatitude = SITE_LAT, decimalLongitude = SITE_LONG, 
         habitat = SHELF, eventDate = SAMPLE_DATE, organismID = CATEGORY, measurementValue = COVER) %>% 
  mutate(eventDate = format(strptime(as.character(eventDate), "%d-%b-%Y"), "%Y-%m-%d"),
         year = year(eventDate),
         month = month(eventDate), 
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
