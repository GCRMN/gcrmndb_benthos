# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
source("code/00_functions/ncrmp_converter.R")

dataset <- "0103" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(path = ., full.names = TRUE)

## 2.2 Combine files ----

map_dfr(data_paths, ~ncrmp_converter(data_path = .)) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Point intersect transect, 15 m transect length, every 15 cm") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_paths, ncrmp_converter)
