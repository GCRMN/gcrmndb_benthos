# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0018" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "Coordinates") %>% 
  rename(locality = Site, decimalLatitude = "Lat (dec)", decimalLongitude = "Lon (dec)") %>% 
  select(locality, decimalLatitude, decimalLongitude)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "Cover codes") %>% 
  rename(organismID = CATEGORIES) %>% 
  mutate(organismID = str_replace_all(organismID, c("Porites \\(branching\\)" = "Porites branching",
                                                    "Mussid \\(family\\)" = "Mussid",
                                                    "Pocillopora \\(genus\\)" = "Pocillopora",
                                                    "Porites \\(family\\)" = "Porites",
                                                    "Porites \\(massive\\)" = "Porites massive",  
                                                    "Porites rus \\(species\\)" = "Porites rus",
                                                    "Siderastrea \\(genus\\)" = "Siderastrea",
                                                    "Turbinara \\(coral\\)" = "Turbinara coral",
                                                    "Favia stelligera \\(species\\)" = "Favia stelligera",
                                                    "Macroalgae \\(other\\)" = "Macroalgae",
                                                    "Turbinaria \\(algae\\)" = "Turbinaria algae",
                                                    "Fungiid \\(family\\)" = "Fungiid",
                                                    "Favid \\(family\\)" = "Favid",
                                                    "Hard coral \\(other\\)" = "Hard coral")),
         code = str_split_fixed(organismID, " \\(", 2)[,2],
         code = str_remove_all(code, "\\)"),
         organismID = str_split_fixed(organismID, " \\(", 2)[,1]) %>% 
  filter(!(code == "")) %>% 
  add_row(organismID = c("turf algae", "dead coral covered in blue-green algae", "bleached coral", "recently dead coral"), 
          code = c("TRF", "BGC", "BLC", "RDC")) # Based on values provided by mail

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "Data") %>% 
  filter(!(Site %in% c("North Tarawa / Abaiang", "South Tarawa", "Abaiang Lagoon"))) %>% 
  drop_na(Site) %>% 
  select(-"...121", -"# points") %>% 
  pivot_longer(2:ncol(.), names_to = "code", values_to = "measurementValue") %>% 
  group_by(Site) %>% 
  mutate(n_points = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         year = 2018,
         month = 5,
         verbatimDepth = 11,
         samplingProtocol = "Photo-quadrat, 50 m transect length, every 0.5 m, area of 0.33 m2, image analyzed by 20 point count",
         measurementValue = (measurementValue*100)/n_points) %>% 
  rename(locality = Site) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-code, -n_points) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site)
