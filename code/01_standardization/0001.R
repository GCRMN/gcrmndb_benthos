# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # To dates format

dataset <- "0001" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(file = ., na = c("nd", "", "NA", " ")) %>% 
  select(-percentCover_CTB) %>% # CTB combine categories of CCA, Turf and bare, non recategorisable
  pivot_longer(percentCover_allCoral:percentCover_macroalgae, names_to = "taxid", values_to = "cover") %>% 
  filter(cover != 0) %>% 
  rename(replicate = transect, date = Date) %>% 
  mutate(dataset_id = dataset,
         year = year(date),
         location = "USVI",
         quadrat = str_split_fixed(quadrat, "Q", 2)[,2],
         # Manually add metadata from file "edi.291.2.txt"
         depth = case_when(site == "Tektite" ~ 14,
                           site == "Yawzi" ~ 9),
         lat = case_when(site == "Tektite" ~ 18.30996508,
                         site == "Yawzi" ~ 18.31506678),
         long = case_when(site == "Tektite" ~ -64.72321746,
                          site == "Yawzi" ~ -64.72551007),
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
