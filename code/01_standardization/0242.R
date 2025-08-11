# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0242" # Define the dataset_id

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
  mutate(verbatimDepth = str_replace_all(verbatimDepth, c("2-6m" = "4",
                                                          "6m" = "6",
                                                          "3-6m" = "4.5",
                                                          "2m" = "2",
                                                          "5m" = "5",
                                                          "8m" = "8",
                                                          "15m" = "15",
                                                          "3m" = "3",
                                                          "3-4m" = "3.5",
                                                          "4m" = "4",
                                                          "3.5m" = "3.5",
                                                          "1.5m" = "1.5")),
       verbatimDepth = as.numeric(verbatimDepth),
       organismID = str_remove_all(organismID, "_percent"),
       samplingProtocol = str_replace_all(samplingProtocol, "Point_intercept_transect", "Point intercept transect"),
       datasetID = dataset) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
