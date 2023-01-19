# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0007" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read_csv(file = .) %>% 
  select(surveyid, transectid, surveydate) %>% 
  mutate(surveydate = as.Date(as.character(surveydate), format = "%Y%m%d")) %>% 
  mutate(depth = 10) # Based on the value given in the data paper

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read_csv(file = .) %>% 
  select(region, label, func_group, label_name)

# 2.3 Main data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  map_dfr(., ~read_csv(file = .x)) %>% 
  pivot_longer(6:ncol(.), values_to = "cover", names_to = "category")



































# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .) %>% 
  rename(site = Site, lat = Latitude, long = Longitude, zone = Zone, depth = Depth)

# 2.2 code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(dataset_id == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., 
            sheet = "Brut", 
            col_types = c("numeric", "text", "date", "text", "text", 
                          "numeric", "numeric", "text", "text")) %>% 
  left_join(., data_code) %>% # Merge main data with substrates codes
  select(-Season, -Substrate, -Remarques) %>% # Delete useless variables
  rename(year = Year, date = Date, zone = Habitat, observer = Oserver, 
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
         method = "Point intersect transect, 50 m transect length, every 1 m",
         taxid = str_to_sentence(str_squish(str_trim(taxid, side = "both")))) %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code)
