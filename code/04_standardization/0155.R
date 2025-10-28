# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0155" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(decimalLatitude = as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,1]) +
         as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,2])/60,
       decimalLongitude = as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,1]) +
         as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,2])/60,
       decimalLongitude = -decimalLongitude,
       verbatimDepth = as.numeric(verbatimDepth)*0.32808)

## 2.2 Main data ----

### 2.2.1 Path of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, pattern = ".xls")

### 2.2.2 Function to combine the files ----

convert_data_155 <- function(path_i){
  
  data <- read_xls(path = path_i, sheet = 1, range = "Q5004:AA5049") %>% 
    pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
    mutate(locality = path_i)

  return(data)
  
}

### 2.2.3 Map over the function ----

map_dfr(data_paths, ~convert_data_155(.x)) %>% 
  mutate(locality = str_split_fixed(locality, "/", 4)[,4],
         locality = str_remove_all(locality, ".xls"),
         parentEventID = as.numeric(str_remove_all(parentEventID, "T")),
         measurementValue = measurementValue*100,
         locality = str_remove_all(locality, "99"),
         datasetID = dataset,
         year = 1999) %>%
  rename(organismID = Category) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
