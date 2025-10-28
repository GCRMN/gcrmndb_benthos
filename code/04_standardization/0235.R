# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0235" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data site ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "site") == TRUE) %>% 
  pull(value) %>% 
  read_xlsx(., na = "NA")

## 2.2 Data code ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "code") == TRUE) %>% 
  pull(value) %>% 
  read_xlsx(.)

## 2.3 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "code|site") == FALSE) %>% 
  pull(value)

## 2.4 Create a function ----

convert_data_235 <- function(file_i){
  
  data <- read_xlsx(path = file_i, sheet = "Benthos", skip = 8) %>% 
    mutate(path = file_i)
  
  return(data)
  
}

## 2.5 Map over the function ----

map(list_files, ~convert_data_235(file_i = .x)) %>% 
  list_rbind() %>% 
  filter(!(`Intercept points` %in% c("Intercept points", NA))) %>% 
  pivot_longer(2:11, names_to = "parentEventID", values_to = "code") %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, 1, 1)) + 1) %>% 
  select(-1) %>% 
  # Convert from nb of points to percentage cover
  group_by(path, parentEventID, code) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(path, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  left_join(., data_code) %>% 
  mutate(path = str_split_fixed(path, "/|\\.", 5)[,4]) %>% 
  left_join(., data_site) %>% 
  select(-code, -path) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point Intercept Transect, 10 m transect length") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site, list_files, convert_data_235)
