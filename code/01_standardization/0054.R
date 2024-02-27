# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0054" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(., na = c("NA", "na")) %>% 
  rename(locality = site, eventDate = date, verbatimDepth = Depth_Stratum,
         decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, eventDate, verbatimDepth, decimalLatitude, decimalLongitude) %>% 
  mutate(eventDate = as.Date(eventDate, format = "%m/%d/%Y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

# 2.2 Main data --

# 2.3.1 Extract paths -

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path)

# 2.3.2 Combine and transform data -

map_dfr(data_main$data_path, ~read_csv(file = .x)) %>% 
  select(-Expedition_ID, -Island_Code, -Date, -Sum, -Calcifying, -"Non Calcifying") %>% 
  rename(locality = Station_ID) %>% 
  pivot_longer("Acropora":ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  left_join(., data_site) %>% 
  mutate(parentEventID = as.numeric(str_extract(str_split_fixed(PicName, "_", 5)[,4], "[1-9]")),
         eventID = as.numeric(str_split_fixed(PicName, "_", 5)[,5]),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  select(-PicName) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
