# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0007" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 3) %>% 
  left_join(., data_code) %>% # Merge main data with substrates codes
  select(-Substrate, -Observations) %>% # Delete useless variables
  rename(year = Year, date = Date, zone = Habitat, observer = Observer, 
         replicate = Station, taxid = Tax_ID) %>% # Rename variables
  group_by(year, date, observer, zone, replicate, taxid) %>% 
  count(name = "cover") %>% 
  ungroup() %>% 
  group_by(year, date, observer, zone, replicate) %>% 
  mutate(total = sum(cover)) %>% 
  ungroup() %>% 
  mutate(dataset_id = dataset,
         location = "Moorea", 
         cover = (cover/total)*100,
         long = -149.901167,
         lat = -17.470833,
         replicate = str_extract(replicate, "[1-9]"),
         method = "Point intersect transect, 50 m transect length, every 50 cm",
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code)