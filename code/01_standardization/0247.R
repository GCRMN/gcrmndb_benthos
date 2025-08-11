# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0247" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, skip = 1, na = c("", "NA", "na")) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method,
         parentEventID = Replicate) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         samplingProtocol, parentEventID, Hardcoral_percent, Softcoral_percent,
         Reckilledcoral_percent, Macroalgae_percent, Turfalgae_percent,
         Corallinealgae_percent, Other_percent) %>%  
  pivot_longer("Hardcoral_percent":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = str_remove_all(organismID, "_percent"),
         samplingProtocol = str_replace_all(samplingProtocol,
                                            c("Point_intercept_transect_Reefcheck; Belt transect" = "Point Intercept Transect",
                                            "Point_intercept_transect_Reefcheck" = "Point Intercept Transect",
                                            "Photo_transect_Reefcloud" = "Photo-quadrat",
                                            "Photo_transect_Reefcloud; Belt transect" = "Photo-quadrat")),
         verbatimDepth = str_remove_all(verbatimDepth, "m"),
         verbatimDepth = str_replace_all(verbatimDepth, ",", "\\."),
         verbatimDepth = case_when(str_detect(verbatimDepth, "-") == TRUE ~ 
                            (as.numeric(str_split_fixed(verbatimDepth, "-", 2)[,1]) + 
                               as.numeric(str_split_fixed(verbatimDepth, "-", 2)[,2]))/2,
                          TRUE ~ as.numeric(verbatimDepth)),
         datasetID = dataset) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)




