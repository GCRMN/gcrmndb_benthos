# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0145" # Define the dataset_id

# 2. Import, standardize and export the data ----

# /!\ Data from the original .xlsx file were copy, paste,
# and transposed to another .xlsx file to avoid issue with the dates

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

A <- map_dfr(1:4, ~read_xlsx(data_path, sheet = .)) %>% 
  mutate(parentEventID = rep(seq(1, 4), nrow(.)/4), .after = "Site") %>% 
  rename(locality = "Site", eventDate = "Date", verbatimDepth = "Depth (m)") %>% 
  pivot_longer(5:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  filter(!(organismID %in% c("Stony Coral %", "Turf  CH (mm)", "Macro CH (mm)",
                           "Art CH (mm)", "Stony coral %"))) %>% 
  drop_na(measurementValue)



B <- A %>% 
  group_by(locality, parentEventID, eventDate) %>% 
  summarise(tot = sum(measurementValue))



# Uniformiser les noms de site puis demander les coordinés
sort(unique(A$locality))



