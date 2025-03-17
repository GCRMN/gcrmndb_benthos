# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0174" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(, skip = 1) %>% 
  rename(decimalLatitude = Approx_Lat,
         decimalLongitude = Approx_Long,
         eventDate = "Date_of_Observation/Survey",
         samplingProtocol = Method,
         locality = Reef,
         verbatimDepth = Approx_Depth_of_Bleaching,
         `Partially Live Coral` = "Partially Live") %>% 
  select(locality, decimalLatitude, decimalLongitude, samplingProtocol,
         eventDate, verbatimDepth, "Live Coral", "Bleached Coral", "Dead Coral",
         "Partially Live Coral", "macroalgae", "turf algae", "crustose coralline algae") %>% 
  mutate(across(c("Live Coral", "Bleached Coral", "Dead Coral",
                  "Partially Live Coral"), ~.x*100)) %>% 
  pivot_longer(7:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(verbatimDepth = as.numeric(str_replace_all(verbatimDepth, "Reef Flat", "0.5")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
