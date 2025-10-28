# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0001" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(file = ., na = c("nd", "", "NA", " ")) %>% 
  select(-percentCover_CTB) %>% # CTB combine categories of CCA, Turf and bare, non recategorisable
  pivot_longer(percentCover_allCoral:percentCover_macroalgae, names_to = "organismID", values_to = "measurementValue") %>% 
  rename(parentEventID = transect, eventID = quadrat, eventDate = Date, locality = site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         eventID = as.numeric(str_split_fixed(eventID, "Q", 2)[,2]),
         # Manually add metadata from file "edi.291.2.txt"
         verbatimDepth = case_when(locality == "Tektite" ~ 14,
                                   locality == "Yawzi" ~ 9),
         decimalLatitude = case_when(locality == "Tektite" ~ 18.30996508,
                                     locality == "Yawzi" ~ 18.31506678),
         decimalLongitude = case_when(locality == "Tektite" ~ -64.72321746,
                                      locality == "Yawzi" ~ -64.72551007)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
