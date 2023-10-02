# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0039" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  select(-Sum, -Station, -"Photo Name", -"Island", -"No. Points") %>% 
  pivot_longer("Hard Coral":"TWS", values_to = "measurementValue", names_to = "organismID") %>% 
  drop_na(measurementValue) %>% 
  filter(measurementValue != 0) %>% 
  # Remove Tapes, wands and shadow as not included in the sum (see metadata)
  filter(!(organismID %in% c("Cyanobacteria", "TWS"))) %>%
  rename(year = Year, decimalLatitude = Latitude, decimalLongitude = Longitude,
         locality = Site, eventID = Replicate, habitat = Habitat) %>% 
  mutate(datasetID = dataset,
         verbatimDepth = 10, # See metadata
         habitat = str_replace_all(habitat, c("ORT" = "Fore reef",
                                              "FT" = "Fringing reef",
                                              "TOKA" = "Patch reef",
                                              "KAOA" = "Patch reef")),
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
