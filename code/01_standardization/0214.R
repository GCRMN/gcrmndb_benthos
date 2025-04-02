# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0214" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(.x)),
         decimalLatitude = -abs(decimalLatitude))

## 2.2 Function to combine the files ----

convert_data_214 <- function(row_i){
  
    data <- read_xlsx(path = as.character(list_files[row_i, "path"]),
                      range = as.character(list_files[row_i, "range"]),
                      sheet = as.character(list_files[row_i, "sheet"])) %>% 
      filter(row_number() > 16) %>% 
      drop_na(2) %>% 
      pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
      rename(organismID = 1) %>% 
      mutate(parentEventID = parse_number(parentEventID),
             locality = as.character(list_files[row_i, "locality"]),
             decimalLatitude = as.numeric(list_files[row_i, "decimalLatitude"]),
             decimalLongitude = as.numeric(list_files[row_i, "decimalLongitude"]),
             year = as.numeric(list_files[row_i, "year"]))

  return(data)
  
}

## 2.3 Map over the function ----

map(1:nrow(list_files), ~convert_data_214(row_i = .x)) %>% 
  list_rbind() %>% 
  mutate(datasetID = dataset,
         organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_files, convert_data_214)
