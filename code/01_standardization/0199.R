# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0199" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "data_with_summary") %>% 
  # Select the organization since multiple datasetID in a single Excel sheet
  filter(Organization == "IHSM") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude, year = Year,
         samplingProtocol = Method, organismID = `Benthic category`, measurementValue = mean_cover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, samplingProtocol, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         decimalLatitude = case_when(str_detect(decimalLatitude, "S") == TRUE ~ as.character(-convert_coords(decimalLatitude)),
                                      str_detect(decimalLatitude, "\\.") == FALSE ~ paste0(str_sub(decimalLatitude, 1, 3),
                                                                                           ".", str_sub(decimalLatitude, 4, 20)),
                                      TRUE ~ decimalLatitude),
         decimalLatitude = as.numeric(decimalLatitude),
         decimalLongitude = case_when(str_detect(decimalLongitude, "E") == TRUE ~ as.character(convert_coords(decimalLongitude)),
                                     str_detect(decimalLongitude, "\\.") == FALSE ~ paste0(str_sub(decimalLongitude, 1, 2),
                                                                                          ".", str_sub(decimalLongitude, 3, 20)),
                                     TRUE ~ decimalLongitude),
         decimalLongitude = as.numeric(decimalLongitude)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
