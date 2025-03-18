# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0175" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 3) %>% 
  pivot_longer("Ascidians":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(eventDate = `date (UTC)`, decimalLatitude = site_latitude, decimalLongitude = site_longitude,
         verbatimDepth = depth_m, locality = site_id, parentEventID = survey_id, eventID = unique_id) %>% 
  select(-total) %>% 
  mutate(eventDate = as.Date(eventDate),
         organismID = case_when(organismID == "Branching" ~ "Hard coral",
                                organismID == "Bushy" ~ "Hard coral",
                                organismID == "Encrusting" ~ "Hard coral",
                                organismID == "Entangled/mat-like" ~ "Macroalgae",
                                organismID == "Leafy/Fleshy" ~ "Macroalgae",
                                organismID == "Massive" ~ "Hard coral",
                                organismID == "Mushroom" ~ "Hard coral",
                                organismID == "Other anything" ~ "Abiotic - Other anything",
                                organismID == "Plate/Table" ~ "Hard coral",
                                organismID == "Slime" ~ "Macroalgae",
                                organismID == "Tree-Bush-like" ~ "Macroalgae",
                                organismID == "Turfing/Filamentous" ~ "Macroalgae",
                                organismID == "Vase/Foliose" ~ "Hard coral",
                                TRUE ~ organismID),
         locality = paste0("S", locality),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
