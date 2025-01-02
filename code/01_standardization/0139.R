# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(zoo)

source("code/00_functions/convert_coords.R")

dataset <- "0139" # Define the dataset_id

# 2. Import, standardize and export the data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .) %>% 
  select(-32:-48) %>% 
  filter(row_number() != 41) %>% 
  filter(row_number() != 24) %>% 
  filter(if_any(everything(), ~ !is.na(.))) %>% 
  mutate(...1 = ifelse(row_number() == 30, "Abiotic", ...1),
         ...1 = na.locf(...1, na.rm = FALSE),
         ...1 = ifelse(...1 == "Others", "Other fauna", ...1)) %>% 
  mutate(...2 = case_when(is.na(...1) ~ ...2,
                          is.na(...2) ~ ...1,
                          !(is.na(...1)) & !(is.na(...2)) ~ paste0(...1, " - ", ...2))) %>% 
  select(-1) %>% 
  t()

colnames(data_main) <- data_main[1,]

bind_cols(rownames(data_main), data_main) %>% 
  as_tibble() %>% 
  filter(row_number() != 1) %>% 
  pivot_longer("Dead Coral":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         across(c(Latitude, Longitude), ~ convert_coords(str_replace_all(., c("¢" = "'",
                                                               "″" = "''",
                                                               "´" = "'",
                                                               "’" = "'",
                                                               "'" = "'",
                                                               "'" = "'",
                                                               "ʹ" = "'",
                                                               "º" = "°"))))) %>% 
  rename(locality = "...1", decimalLatitude = Latitude, decimalLongitude = Longitude, year = "Year of Survey",
         samplingProtocol = "Methods Applied") %>% 
  mutate(datasetID = dataset,
         year = str_sub(year, 1, 4),
         samplingProtocol = str_replace_all(samplingProtocol, "LIT", "Line intersect transect")) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main, convert_coords)
