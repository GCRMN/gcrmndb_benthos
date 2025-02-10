# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0156" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Path of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  excel_sheets()

## 2.2 Function to combine the files ----

convert_data_156 <- function(sheet_i){
  
  data <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>%
    select(data_path) %>% 
    pull() %>% 
    read_xlsx(path = ., sheet = sheet_i) %>% 
    mutate(locality = sheet_i)

  return(data)
  
}

## 2.3 Map over the function ----

map_dfr(data_paths, ~convert_data_156(.x)) %>% 
  rename(decimalLatitude = Lat,
         decimalLongitude = Lon,
         year = Year,
         measurementValue = CoralCover) %>% 
  mutate(organismID = "Hard coral",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_paths, convert_data_156)
