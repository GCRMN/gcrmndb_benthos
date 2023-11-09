# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0041" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "RECAP 2016-2022", range = "A1:BU26") %>% 
  rename(code = 1) %>% 
  pivot_longer(2:ncol(.), names_to = "id", values_to = "measurementValue") %>% 
  mutate(date = str_split_fixed(id, "-", 3)[,1],
         year = as.numeric(paste0("20", str_sub(date, 3, 4))),
         month = as.numeric(str_sub(date, 1, 2)),
         station = str_split_fixed(id, "-", 3)[,2],
         parentEventID = str_split_fixed(id, "-", 3)[,3],
         parentEventID = as.numeric(str_extract(parentEventID, "\\d+")),
         measurementValue = measurementValue*100,
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 20 m transect length, every 50 cm") %>% 
  left_join(., data_code) %>% 
  left_join(., data_site) %>% 
  select(-id, -date, -code, -station) %>% 
  filter(measurementValue != 0) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code)
