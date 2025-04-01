# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0207" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude,
         locality = `Site name`) %>% 
  select(-Location)

## 2.2 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "code|coordinates") == FALSE)

## 2.3 Function to combine the files ----

convert_data_207 <- function(path_i){

  if(str_detect(path_i, "2014") == TRUE){
    
    data <- read_xlsx(path = path_i, range = "A21:D64",
                      col_names = c("organismID", "T1", "T2", "T3"),
                      sheet = "Data Summary") %>% 
      drop_na(T1) %>% 
      pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
      mutate(parentEventID = parse_number(parentEventID),
             locality = str_split_fixed(path_i, "Vamizi_2014/", 2)[,2],
             locality = str_remove_all(locality, "\\.xls"),
             year = 2014)
    
  }else{
    
    data <- read_xlsx(path = path_i, range = "A21:B64",
                      col_names = c("organismID", "measurementValue"),
                      sheet = "Data Summary") %>% 
      drop_na(measurementValue) %>% 
      mutate(locality = str_split_fixed(path_i, "Vamizi_2006/", 2)[,2],
             locality = str_remove_all(locality, "\\.xls"),
             parentEventID = as.numeric(str_sub(locality, 6, 6)),
             locality = str_sub(locality, 1,4),
             year = 2006)
    
  }
  
  return(data)
  
}

## 2.4 Map over the function ----

map(list_files$value, ~convert_data_207(path_i = .x)) %>% 
  list_rbind() %>% 
  mutate(locality = str_replace_all(locality, "R", "_"),
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
  
# 3. Remove useless objects ----

rm(data_site, list_files, convert_data_207)
