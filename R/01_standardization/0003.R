# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # To dates format

dataset <- "0003" # Define the dataset_id

# 2. Import, standardize and export the data ----

Sys.setlocale("LC_TIME", "C") # Set parameters for date transformation

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(file = .) %>% 
  mutate(dataset_id = dataset,
         site = paste(REEF_NAME, SITE_NO, sep = " - ")) %>% 
  select(-VISIT_NO, -REEF_NAME, -SITE_NO, -FULLREEF_ID, -YEAR_CODE) %>% 
  rename(location = A_SECTOR, lat = SITE_LAT, long = SITE_LONG, zone = SHELF, date = SAMPLE_DATE,
         taxid = CATEGORY, cover = COVER) %>% 
  mutate(date = format(strptime(as.character(date), "%d-%b-%Y"), "%Y-%m-%d"),
         year = year(date),
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  filter(cover != 0) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
