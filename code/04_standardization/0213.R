# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0213" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  rename(locality = Name, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~as.numeric(.x)))

## 2.2 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "site") == FALSE)

## 2.3 Function to combine the files ----

convert_data_213 <- function(path_i){
  
  if(str_detect(path_i, "Puga") == TRUE){
    
    data <- read_xlsx(path = path_i, range = "A6:I79",
                      sheet = "Data Summary") %>% 
      filter(row_number() > 17) %>% 
      drop_na(2) %>% 
      pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue")
    
  }else if(str_detect(path_i, "Mafamede") == TRUE){
    
    data <- read_xlsx(path = path_i, range = "A6:G79",
                      sheet = "Data Summary") %>% 
      filter(row_number() > 17) %>% 
      drop_na(2) %>% 
      pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue")
    
  }else{
    
    data <- read_xlsx(path = path_i, range = "A6:J79",
                      sheet = "Data Summary") %>% 
      filter(row_number() > 17) %>% 
      drop_na(2) %>% 
      pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue")
    
  }
  
  return(data)
  
}

## 2.4 Map over the function ----

map(list_files$value, ~convert_data_213(path_i = .x)) %>% 
  list_rbind() %>% 
  rename(organismID = 1) %>% 
  mutate(datasetID = dataset,
         year = 2019,
         locality = str_sub(parentEventID, 1, 4),
         parentEventID = as.numeric(str_sub(parentEventID, 6, 6))) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, list_files, convert_data_213)
