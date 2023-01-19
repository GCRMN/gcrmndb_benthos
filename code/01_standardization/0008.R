# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0008" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls(path = ., sheet = 2, col_types = "text") %>% 
  filter(UE != "Moyenne") %>% 
  pivot_longer(5:ncol(.), names_to = "taxid", values_to = "cover") %>% 
  filter(!(taxid %in% c("Total %", "...42", "Total % Corail vivant"))) %>% 
  rename(year = "Année", date = Date, observer = Observateur, 
         replicate = UE) %>% # Rename variables
  mutate(taxid = str_replace_all(taxid, "Corail mort récent \\(< 1 an\\), compté en 2020, avant et après compté en turf", "Tuff"),
         cover = as.numeric(cover),
         date = as.Date(as.numeric(date), origin = "1899-12-30")) %>% 
  drop_na(cover) %>% 
  mutate(dataset_id = dataset,
         location = "Moorea", 
         depth = 12,
         method = "Point intersect transect, 50 m transect length, every 50 cm",
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
