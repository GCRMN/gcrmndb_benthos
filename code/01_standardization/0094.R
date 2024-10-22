# 1. Packages ----

library(tidyverse)
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0094" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List of files and range to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

data_paths <- tibble(file = paste0(data_paths, c("Coral Cover_Albuquerque_2018.xlsx",
                             "Coral Cover_Albuquerque_2018.xlsx",
                             "Coral Cover_BajoNuevo_2021.xlsx",
                             "Coral Cover_BajoNuevo_2021.xlsx",
                             "Coral Cover_Bolívar_2022.xlsx",
                             "Coral Cover_Bolívar_2022.xlsx",
                             "Coral Cover_PNN Tayrona_2023.xlsx",
                             "Coral Cover_PNN Tayrona_2023.xlsx")),
                    sheet = rep(c(1, 2), 4),
                    range = c("B6:D21", "B7:N13307",
                              "B6:D18", "B7:N11007",
                              "B7:D29",
                              "B8:O55908",
                              "B7:D17",
                              "B8:P41208"))

## 2.2 Create a function to standardize data ----

convert_data_094 <- function(file_i){
  
  # Site coordinates
  
  data_paths_i <- data_paths %>% 
    filter(file == file_i & sheet == 1)
  
  data_site_i <- read_xlsx(path = as.character(data_paths_i$file),
                           sheet = as.numeric(data_paths_i$sheet),
                           range = as.character(data_paths_i$range)) %>% 
    rename(locality = 1, decimalLatitude = 2, decimalLongitude = 3) %>% 
    mutate(locality = str_remove_all(locality, "\\*"))
  
  if(str_detect(unique(data_paths_i$file), "Tayrona") == TRUE){
    
    data_site_i <- data_site_i %>% 
      mutate(decimalLatitude = convert_coords(decimalLatitude),
             decimalLongitude = -convert_coords(decimalLongitude),
             locality = str_split_fixed(locality, "_", 2)[,2])
      
  }
  
  # Main data
  
  data_paths_i <- data_paths %>% 
    filter(file == file_i & sheet == 2)
  
  if(str_detect(unique(data_paths_i$file), "Bolívar") == TRUE){
    
    data_main_i <- read_xlsx(path = as.character(data_paths_i$file),
                             sheet = as.numeric(data_paths_i$sheet),
                             range = as.character(data_paths_i$range)) %>% 
      rename(eventDate = 2, locality = 3, verbatimDepth = 5, parentEventID = 8, eventID = 9, organismID = 14) %>% 
      mutate(organismID = ifelse(organismID == "Turbinaria spp",
                                 paste0(GRUPO, " ", organismID), organismID)) %>% 
      select(eventDate, locality, verbatimDepth, parentEventID, eventID, organismID) %>% 
      mutate(eventDate = as.Date(eventDate),
             parentEventID = as.numeric(str_remove_all(parentEventID, "T")),
             eventID = as.numeric(str_remove_all(eventID, "C"))) %>% 
      left_join(., data_site_i)
    
  }else if(str_detect(unique(data_paths_i$file), "Tayrona") == TRUE){

    data_main_i <- read_xlsx(path = as.character(data_paths_i$file),
                             sheet = as.numeric(data_paths_i$sheet),
                             range = as.character(data_paths_i$range)) %>% 
      rename(eventDate = 2, locality = 8, verbatimDepth = 3, parentEventID = 9, eventID = 10, organismID = 15) %>% 
      mutate(organismID = ifelse(organismID == "Turbinaria spp",
                                 paste0(GRUPO, " ", organismID), organismID)) %>% 
      select(eventDate, locality, verbatimDepth, parentEventID, eventID, organismID) %>% 
      mutate(eventDate = as.Date(eventDate),
             verbatimDepth = str_replace_all(verbatimDepth, c("2,0 a 3,0" = "2.5",
                                                              "2,0 a 3,5" = "2.75",
                                                              "1,3 a 2,5" = "1.9",
                                                              "1,5 a 2,5" = "2",
                                                              "1,3 a 2,6" = "1.95",
                                                              "2,5 a 3,9" = "3.2",
                                                              "4,5 m" = "4.5")),
             verbatimDepth = as.numeric(verbatimDepth),
             parentEventID = as.numeric(str_remove_all(parentEventID, "T")),
             eventID = as.numeric(str_remove_all(eventID, "C"))) %>% 
      left_join(., data_site_i)
    
  }else{
      
  data_main_i <- read_xlsx(path = as.character(data_paths_i$file),
                           sheet = as.numeric(data_paths_i$sheet),
                           range = as.character(data_paths_i$range)) %>% 
    rename(eventDate = 2, locality = 3, verbatimDepth = 5, eventID = 8, organismID = 13) %>% 
    mutate(organismID = ifelse(organismID == "Turbinaria spp",
                               paste0(GRUPO, " ", organismID), organismID)) %>% 
    select(eventDate, locality, verbatimDepth, eventID, organismID) %>% 
    mutate(eventDate = as.Date(eventDate),
           eventID = as.numeric(str_remove_all(eventID, "C"))) %>% 
    left_join(., data_site_i)

  }
  
  return(data_main_i)
  
}

### 2.3 Map over the function ----

map_dfr(unique(data_paths$file), ~convert_data_094(file_i = .)) %>% 
  # Convert from number of points to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, eventID, verbatimDepth, eventDate, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, eventID, verbatimDepth, eventDate) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  # Add other variables
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat, 30 m transect length, every 1 m",
         # Correct decimalLongitude value
         decimalLongitude = case_when(decimalLongitude == -162.97100 ~ -81.485500,
                                      TRUE ~ decimalLongitude)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_paths, convert_coords, convert_data_094)
