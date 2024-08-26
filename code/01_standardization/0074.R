# 1. Packages ----

library(tidyverse)
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0074" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., skip = 1, na = c("NA", "", " ", "?")) %>% 
  filter(!(row_number() %in% c(1, 2, 3))) %>% 
  select(-"...1", -"Country", -"MPA status", -"...19", -"Transect hardware or shadow (for photoquadrats)",                          
         -"Any notes on method or categories", -"Hard coral genus 1 (e.g. Acropora)", -"Hard coral genus 2 (e.g. Cyphastrea)",
         -"Hard coral genus 3 (e.g. Porites)", -"Transect", -"Total number of transects", -"All other") %>% 
  filter(Year != "2015 (Fall)-  2016 (Summer)") %>% 
  rename(recordedBy	 = Surveyor, locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         month = Month, year = Year) %>% 
  mutate(decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = str_replace_all(decimalLongitude, c("52° 40.389 E" = "52° 40.389'' E",
                                                                "52° 35.378 E" = "52° 35.378'' E",
                                                                "52° 35.921 E" = "52° 35.921'' E")),
         decimalLongitude = convert_coords(decimalLongitude),
         decimalLatitude2 = ifelse(decimalLatitude > 30, decimalLongitude, decimalLatitude),
         decimalLongitude = ifelse(decimalLongitude < 30, decimalLatitude, decimalLongitude),
         decimalLatitude = decimalLatitude2) %>% 
  select(-decimalLatitude2) %>% 
  mutate(across(9:ncol(.), ~as.character(.))) %>% 
  pivot_longer(9:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(measurementValue = replace_na(measurementValue, "0"),
         measurementValue = str_replace_all(measurementValue, c("2.5000000000000001E-2" = "0.025",
                                                                "1.8799999999999997E-2" = "0.01879",
                                                                "153" = "15.3",
                                                                "44038" = "44.038",
                                                                "6.3E-3" = "0.0063",
                                                                "7.4999999999999997E-2" = "0.07499")),
         measurementValue = as.numeric(measurementValue),
         samplingProtocol = "Line intersect transect, 20 m transect length",
         datasetID = dataset) %>% 
  select(-"Transect length (m)", -"Method") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_coords)
