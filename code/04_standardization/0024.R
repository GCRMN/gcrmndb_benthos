# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0024" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = "Station metadata") %>% 
  select(-Location, -Site, -"...9", -Zone2) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude, 
         verbatimDepth = "Depth (m)", locality = Station, habitat = Zone1)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = "Remarks", range = "A19:B48") %>% 
  rename(code = 1, organismID = 2)

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = "Benthic data", na = "N/A") %>% 
  select(-"RCK+CA+CYA") %>% 
  rename(year = "Année", locality = Station) %>% 
  pivot_longer("DC":"WA", names_to = "code", values_to = "measurementValue") %>% 
  # Correct site names
  mutate(locality = str_replace_all(locality, c("CE29b" = "CE29B",
                                                "CE30b" = "CE30B",
                                                "BO07b" = "BO07B",
                                                "BO12b" = "BO12B"))) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Line intersect transect, 50 m transect length",
         habitat = str_replace_all(habitat, c("lagoon" = "Lagoon",
                                              "Outer reticultae reef" = "Outer reticulate reef"))) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code)
