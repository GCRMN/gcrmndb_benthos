# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
source("code/00_functions/reefcloud_converter.R")

dataset <- "0268" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  reefcloud_converter() %>% 
  filter(measurementValue != 0) %>%
  # Correct error for date
  mutate(eventDate = case_when(eventDate == "2002-02-16" ~ as.Date("2022-02-16"),
                               TRUE ~ eventDate),
         year = case_when(year == 2002 ~ 2022,
                          TRUE ~ year)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
