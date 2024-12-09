# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0130" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .) %>% 
  rename(locality = 1, decimalLatitude = latitude, decimalLongitude = longitude) %>% 
  mutate(locality = case_when(locality == "Pigeon Pt" ~ "Pigeon Point Reef",
                              locality == "Kariwak Reef" ~ "Kariwak",
                              TRUE ~ locality),
         decimalLongitude = -abs(decimalLongitude))

## 2.2 Main data (major categories) ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 2) %>% 
  rename(year = Year, locality = Site, parentEventID = Transect) %>% 
  pivot_longer(4:ncol(.), names_to = "organismID", values_to = "measurementValue")

## 2.3 Main data (hard corals) ----

data_main_hc <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, col_names = FALSE) %>% 
  t() %>% 
  as_tibble()

colnames(data_main_hc) <- data_main_hc[1,]

data_main_hc <- data_main_hc %>% 
  filter(row_number() != 1) %>% 
  pivot_longer(5:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, parentEventID = Transect) %>% 
  select(-`Site ID`) %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         year = as.numeric(year))

## 2.4 Join data ----

data_main %>% 
  filter(organismID != "coral") %>% 
  bind_rows(., data_main_hc) %>% 
  left_join(., data_site) %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, 2, 2)),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 10 m transect length") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_main, data_main_hc)
