# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format

dataset <- "0004" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 4) %>% 
  select(-Campaign, -Season, -observations, -Year) %>% 
  rename(eventDate = Date, locality = "Marine Area", habitat = Habitat, recordedBy = Observer,
         parentEventID = Transect, organismID = Substrate, measurementValue = proportion) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         measurementValue = measurementValue*100,
         samplingProtocol = "Point intersect transect, 25 m transect length, every 50 cm") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
