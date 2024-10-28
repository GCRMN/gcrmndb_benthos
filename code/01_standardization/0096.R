# 1. Packages ----

library(tidyverse)
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0096" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(., fileEncoding = "Latin1") %>% 
  mutate(decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = -convert_coords(decimalLongitude))

## 2.2 List of files and range to combine ----

if(file.exists("data/01_raw-data/0096/master_file.csv") == FALSE){
  
  read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>% 
    select(data_path) %>% 
    pull() %>% 
    tibble(path = list.files(path = ., full.names = TRUE, pattern = ".xls")) %>% 
    select(path) %>% 
    mutate(locality = case_when(str_detect(path, "Passe") == TRUE ~ "Passe-a-Colas",
                                str_detect(path, "Pigeon") == TRUE ~ "Ilet Pigeon",
                                str_detect(path, "Louis") == TRUE ~ "Port Louis",
                                str_detect(path, "Fajou") == TRUE ~ "Fajou",
                                str_detect(path, "Coco") == TRUE ~ "Ilet Coco",
                                str_detect(path, "Baleine") == TRUE ~ "Baleine du Pain de Sucre",
                                TRUE ~ NA),
           range = NA,
           eventDate = NA,
           type = NA) %>% 
    # File to complete manually
    write.csv2(.,
               file = paste0("data/01_raw-data/", dataset, "/master_file.csv"),
               row.names = FALSE,
               fileEncoding = "latin1")
  
}else{
  
  data_paths <- read.csv2("data/01_raw-data/0096/master_file.csv",
                          fileEncoding = "latin1")
  
}

## 2.3 Create a function to standardize data ----

convert_data_096 <- function(file_i){
  
  data_paths_i <- data_paths %>% 
    filter(path == file_i)
  
  print(as.character(data_paths_i$path))
  
  if(as.character(data_paths_i$type) == "A"){
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path),
                        range = as.character(data_paths_i$range)) %>% 
      rename(position = 1, intercept = 2, organismID = 3) %>% 
      mutate(parentEventID = case_when(str_detect(organismID, "ransect") == TRUE ~ organismID,
                                       TRUE ~ NA_character_),
             parentEventID = zoo::na.locf(parentEventID),
             parentEventID = as.numeric(str_sub(parentEventID, -1, -1)),
             eventDate = as.Date(as.character(data_paths_i$eventDate), tryFormats = c("%d/%m/%Y")),
             locality = as.character(data_paths_i$locality)) %>% 
      filter(str_detect(organismID, "ransect") == FALSE)
    
  }else if(as.character(data_paths_i$type) == "B"){
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path),
                        range = as.character(data_paths_i$range)) %>% 
      rename(position = 1, intercept = 2, organismID = 3) %>% 
      arrange(position) %>% 
      mutate(parentEventID = case_when(str_detect(organismID, "ransect") == TRUE ~ organismID,
                                       TRUE ~ NA_character_),
             parentEventID = zoo::na.locf(parentEventID),
             parentEventID = as.numeric(str_sub(parentEventID, -1, -1)),
             eventDate = as.Date(as.character(data_paths_i$eventDate), tryFormats = c("%d/%m/%Y")),
             locality = as.character(data_paths_i$locality)) %>% 
      filter(str_detect(organismID, "ransect") == FALSE)
    
  }else{
    
    data_i <- read_xlsx(path = "data/01_raw-data/0096/Ilet-Coco_août_2008.xlsx",
                        range = "A4:C481") %>% 
      rename(position = 1, intercept = 2, organismID = 3) %>% 
      # Re-create the intercept because of negative values
      arrange(position) %>% 
      mutate(intercept = position-lag(position),
             intercept = replace_na(intercept, 0)) %>% 
      mutate(parentEventID = case_when(str_detect(organismID, "ransect") == TRUE ~ organismID,
                                       TRUE ~ NA_character_),
             parentEventID = zoo::na.locf(parentEventID),
             parentEventID = as.numeric(str_sub(parentEventID, -1, -1)),
             eventDate = as.Date(as.character(data_paths_i$eventDate), tryFormats = c("%d/%m/%Y")),
             locality = as.character(data_paths_i$locality)) %>% 
      filter(str_detect(organismID, "ransect") == FALSE)
    
  }
  
  return(data_i)
  
}

### 2.4 Map over the function ----

data_paths <- data_paths %>% 
  drop_na(range)

map_dfr(unique(data_paths$path), ~convert_data_096(file_i = .)) %>% 
  # convert from length to percentage cover
  group_by(locality, parentEventID, eventDate, organismID) %>% 
  summarise(intercept = sum(intercept)) %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, eventDate) %>% 
  mutate(total = sum(intercept)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (intercept*100)/total) %>% 
  select(-intercept, -total) %>% 
  # Add other variables
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Line intersect transect, 10 m transect length") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_paths, convert_coords, convert_data_096)
