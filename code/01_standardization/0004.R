# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0004" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .) %>% 
  select(-Archipelago, -Country) %>% 
  rename(site = Site, zone = Zone, depth = Depth, lat = Latitude, 
         long = Longitude, location = Location)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 4) %>% 
  select(-Campaign, -Season, -observations) %>% 
  rename(year = Year, date = Date, site = "Marine Area", zone = Habitat, observer = Observer,
         replicate = Transect, taxid = Substrate, cover = proportion) %>% 
  left_join(., data_site) %>% 
  mutate(dataset_id = dataset,
         location = "Moorea",
         cover = cover*100,
         method = "Point intersect transect, 25 m transect length, every 50 cm",
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both"))),
         taxid = str_replace_all(taxid, "[^A-z- -. ]", "e")) %>% # Remove accents (in regex due to encoding issues) 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
