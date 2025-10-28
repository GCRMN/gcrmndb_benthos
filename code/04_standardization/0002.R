# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0002" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(file = ., na = c("NA", "", "nd", "999", "unk")) %>% 
  select(-percentCover_all, -percentCover_CTB) %>% # CTB combine categories of CCA, Turf and bare, non recategorisable
  pivot_longer(percentCover_macroalgae:Millepora, names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = site, eventID = quadrat) %>% 
  # Convert photoquadrat image name to quadrat number (for some of the rows)
  group_by(locality, year) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         # Manually add metadata from file "edi.291.2.txt"
         verbatimDepth = 8, # between 7-9 m, mean chosen
         samplingProtocol = "Photo-quadrat, na, na, area of 0.5 x 0.5 m") %>% 
  left_join(., data_site) %>% 
  # Fix the issue of missing date
  mutate(year = case_when(year %in% c("7_2017", "11_2017") ~ "2017",
                          TRUE ~ year)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
