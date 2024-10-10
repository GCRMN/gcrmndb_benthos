# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0086" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  mutate(verbatimDepth = (`Depth 2021-1` + `Depth 2021-2`)/2) %>% 
  rename(locality = Punto, decimalLatitude = Latitud, decimalLongitude = Longitud) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth)

## 2.2 List of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE) %>% 
  as_tibble() %>% 
  rename(path = 1) %>% 
  filter(str_detect(path, "Peces") == FALSE) %>% 
  mutate(locality = str_split_fixed(path, "_", 6)[,5],
         eventDate = paste0("20", str_sub(path, 23, 24), "-", str_sub(path, 25, 26), "-", str_sub(path, 27, 28)),
         eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  left_join(., data_site)

## 2.3 Create a function to standardize data ----

convert_data_086 <- function(index_i){
  
  data_paths_i <- data_paths %>% 
    filter(row_number() == index_i)
  
  if(str_detect(as.character(data_paths_i$path), ".csv")){
    
    data_i <- read.csv(as.character(data_paths_i$path)) %>% 
      rename(eventID = Image, organismID = spp.Name, measurementValue = Cov..per.species) %>% 
      select(eventID, organismID, measurementValue) %>% 
      bind_cols(., data_paths_i)
    
  }else{
    
    data_i <- read_xlsx(as.character(data_paths_i$path)) %>% 
      rename(eventID = 1, organismID = 3, measurementValue = 6) %>% 
      select(eventID, organismID, measurementValue) %>% 
      bind_cols(., data_paths_i)
    
  }
  
  return(data_i)
  
}

### 2.4 Map over the function ----

map_dfr(1:nrow(data_paths), ~convert_data_086(index_i = .)) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat",
         parentEventID = str_split_fixed(eventID, "_|\\.", 8)[,6],
         parentEventID = as.numeric(str_remove_all(parentEventID, "TR")),
         eventID = str_split_fixed(eventID, "_|\\.", 8)[,7],
         eventID = as.numeric(str_remove_all(eventID, "FC"))) %>% 
  select(-path) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_paths, convert_data_086)
