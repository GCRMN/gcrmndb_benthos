# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0006" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., 
            sheet = "Brut", 
            col_types = c("numeric", "text", "date", "text", "text", 
                          "numeric", "numeric", "text", "text")) %>% 
  select(-Year, -Season, -Remarques) %>% # Delete useless variables
  rename(eventDate = Date, recordedBy = Observer, habitat = Habitat, 
         code = Substrate, eventID = Station) %>% 
  left_join(., data_code) %>% 
  group_by(eventDate, recordedBy, habitat, eventID, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(eventDate, recordedBy, habitat, eventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         measurementValue = (measurementValue/total)*100,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 50 m transect length, every 1 m") %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code)
