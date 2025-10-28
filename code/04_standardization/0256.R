# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0256" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 2, na = c("", "NA", "na")) %>% 
  mutate(decimalLatitude = `Latitude Degrees` + (`Latitude Minutes`/60) + (as.numeric(`Latitude Seconds`)/3600),
         decimalLongitude = `Longitude Degrees` + (`Longitude Minutes`/60) + (as.numeric(`Longitude Seconds`)/3600)) %>% 
  rename(locality = "Reef Name", year = Year, eventDate = Date, verbatimDepth = depth, organismID = substrate_code,
         parentEventID = segment_code, measurementValue = total) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID,
         eventDate, verbatimDepth, organismID, measurementValue) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "NI" = "Macroalgae",
                                                    "OT" = "Other fauna",
                                                    "RB" = "Rubble",
                                                    "RC" = "Rock",
                                                    "RK" = "Recently killed coral",
                                                    "SC" = "Soft coral",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt",
                                                    "SP" = "Sponge",
                                                    "FS" = NA)),
         parentEventID = as.numeric(str_sub(parentEventID, 2, 2))) %>% 
  group_by(eventDate, decimalLatitude, decimalLongitude, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
