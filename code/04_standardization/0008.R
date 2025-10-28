# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0008" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls(path = ., sheet = 2, col_types = "text") %>% 
  filter(UE != "Moyenne") %>% 
  rename(year = "Année", eventDate = Date, recordedBy = Observateur, 
         parentEventID = UE) %>% # Rename variables
  select(-"Total %", -"...42", -"Total % Corail vivant") %>% 
  pivot_longer(5:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = str_replace_all(organismID, c("Corail mort récent \\(< 1 an\\), compté en 2020, avant et après compté en turf" = "Tuff",
                                                    "Turbinaria" = "Algae - Turbinaria")),
         measurementValue = as.numeric(measurementValue),
         measurementValue = replace_na(measurementValue, 0),
         eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30")) %>% 
  mutate(datasetID = dataset,
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = 12,
         decimalLongitude = -149.901167,
         decimalLatitude = -17.470833,
         parentEventID = str_replace_all(parentEventID, c("1-2" = "1",
                                                          "3-4" = "2",
                                                          "5-6" = "3",
                                                          "7-8" = "4")),
         parentEventID = as.numeric(parentEventID),
         samplingProtocol = "Point intersect transect, 50 m transect length, every 50 cm") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
