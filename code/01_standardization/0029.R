# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0029" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2()

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 1, skip = 2) %>% 
  select(-Status, -TOTAL, -"TOTAL SOFT CORALS") %>% 
  select(-starts_with("BL ")) %>% # Remove bleached % (that are included in non bleached %)
  pivot_longer("Anacropora":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Reef, year = Year, parentEventID = Transect, verbatimDepth = Depth) %>% 
  select(locality, year, verbatimDepth, parentEventID, organismID, measurementValue) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Point intersect transect, 50 m transect length, every 50 cm", # See email
         habitat = "Reef flat",
         organismID = str_replace_all(organismID, c("Turbinaria" = "Turbinaria coral",
                                                    "TOTAL SOFT CORALS" = "Soft corals",
                                                    "Ouloastrea?" = "Ouloastrea"))) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----
  
rm(data_site)
