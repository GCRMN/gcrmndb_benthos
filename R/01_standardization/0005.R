# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate)

dataset <- "0005" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = ., na.strings = c("", "NA")) %>% 
  select(-Archipelago, -Country) %>% 
  rename(location = Location, site = Site, 
         lat = Latitude, long = Longitude)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., 
            sheet = 1, 
            col_types = c("date", "numeric", "text", "text", "text", "text", "numeric", "text", 
                          "numeric", "text", "text", "text")) %>% 
  select(1, 5, 6, 7, 8, 9) %>% 
  rename(ID = 2, observer = 3, quadrat = 4, taxid = 5, cover = 6) %>% 
  mutate(dataset_id = dataset,
         date = as.Date(date),
         year = year(date),
         zone = "Outer slope", # cf website SNO Corail
         depth = 10, # Depth between 7 and 13 meters (cf website SNO Corail)
         method = "Photo-quadrat, 20 m transect length, every 1 m, area of 1 x 1 m, image analyzed by 81 point count",
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  left_join(., data_site) %>% 
  select(-ID) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
