# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0228" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  mutate(coordinates = coalesce(`Transect start`, `Transect end`),
         decimalLatitude = str_split_fixed(coordinates, ";|E", 2)[,1],
         decimalLongitude = str_split_fixed(coordinates, ";|E", 2)[,2],
         across(c(decimalLatitude, decimalLongitude), ~str_remove_all(.x, "o|S|E|;")),
         across(c(decimalLatitude, decimalLongitude), ~str_squish(.x)),
         across(c(decimalLatitude, decimalLongitude), ~str_replace_all(.x, " ", "°")),
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x)),
         decimalLatitude = -decimalLatitude,
         Transects = parse_number(Transects),
         Stations = str_replace_all(Stations, c("Techobanine 1" = "Techo1",
                                                "Techobanine 2" = "Techo2",
                                                "Kev’s Ledge" = "Kev's Ledge"))) %>% 
  rename(parentEventID = Transects,
         locality = Stations) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude) %>% 
  group_by(locality) %>% 
  drop_na(decimalLatitude) %>% 
  slice_sample(n = 1) %>% 
  ungroup() %>% 
  drop_na(locality) %>% 
  select(-parentEventID)

## 2.2 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()

## 2.3 Function to combine the files ----

convert_data_228 <- function(row_i){
  
  data <- read_xls(path = as.character(list_files[row_i, "path"]),
                   range = as.character(list_files[row_i, "range"]),
                   sheet = as.character(list_files[row_i, "sheet"])) %>% 
    filter(row_number() > 16) %>% 
    drop_na(2) %>% 
    pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
    rename(organismID = 1) %>% 
    mutate(parentEventID = parse_number(parentEventID),
           locality = as.character(list_files[row_i, "locality"]),
           year = as.numeric(list_files[row_i, "year"]))
  
 return(data)
  
}

## 2.4 Map over the function ----

map(1:nrow(list_files), ~convert_data_228(row_i = .x)) %>% 
  list_rbind() %>% 
  mutate(datasetID = dataset,
         organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID)) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_files, convert_data_228)
