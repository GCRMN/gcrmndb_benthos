# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0009" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read_csv(file = .) %>% 
  select(surveyid, transectid, surveydate) %>% 
  rename(eventDate = surveydate) %>% 
  mutate(eventDate = as.Date(as.character(eventDate), format = "%Y%m%d"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = 10) # Based on the value given in the data paper

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read_csv(file = .) %>% 
  mutate(organismID = paste0(func_group, " - ", label_name)) %>% 
  select(region, label, organismID) %>% 
  mutate(region_id = as.character(as.numeric(as.factor(region))))

# 2.3 Main data --

# 2.3.1 Extract paths -

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  mutate(region = str_split_fixed(data_path, "_", 4)[,4],
         region = str_remove_all(region, ".csv"),
         region = str_replace_all(region, c("atlantic" = "Atlantic",
                                            "indianocean" = "Indian Ocean",
                                            "pacificaustralia" = "Pacific Australia",
                                            "pacifichawaii" = "Pacific Hawaii",
                                            "southeastasia" = "Southeast Asia")),
         region_id = as.character(1:5))

# 2.3.2 Combine and transform data -

map_dfr(data_main$data_path, ~read_csv(file = .x), .id = "region_id") %>% 
  pivot_longer(7:ncol(.), values_to = "measurementValue", names_to = "label") %>% 
  drop_na(measurementValue) %>% 
  left_join(., data_code) %>% 
  left_join(., data_site) %>% 
  select(-region_id, -region, -label, -surveyid, -imageid) %>% 
  rename(decimalLongitude = lng, decimalLatitude = lat, 
         parentEventID = transectid, eventID = quadratid) %>% 
  mutate(datasetID = dataset,
         measurementValue = measurementValue*100,
         samplingProtocol = "Photo-quadrat") %>%
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code, data_main)
