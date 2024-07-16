# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(zoo)

dataset <- "0061" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Get file path --

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

# 2.2 Combine and transform data --

map_dfr(1:5, ~read_xlsx(path = data_path, sheet = ., col_types = "text")) %>% 
  rename(eventDate = "month/day", locality = site, parentEventID = "transect number", decimalLatitude = "latitude",
         decimalLongitude = "longitude", verbatimDepth = "depth (m)", recordedBy = "observer",
         "Hard coral" = "coral cover (%)", "Macroalgae" = "macroalgae cover (%)") %>% 
  # Standardize the date
  mutate(eventDate = if_else(str_detect(string = eventDate, pattern = "[A-z]") == TRUE,
                             dmy(paste(eventDate, year, sep = "-")),
                             ymd(paste(as.numeric(year), str_sub(as.Date(as.numeric(eventDate),
                                                                         origin = "1904-01-01"), 6, 10), sep = "-")))) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~na.locf(.x))) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude", "verbatimDepth", "parentEventID"), ~as.numeric(.x))) %>% 
  pivot_longer("Hard coral":"Macroalgae", names_to = "organismID", values_to = "measurementValue") %>% 
  select(year, eventDate, recordedBy, locality, parentEventID, habitat, verbatimDepth, decimalLatitude,
         decimalLongitude, organismID, measurementValue) %>% 
  mutate(decimalLatitude = ifelse(locality == "Cooks Rock", -19.546029, decimalLatitude),
         decimalLongitude = ifelse(locality == "Cooks Rock", 169.499078, decimalLongitude),
         datasetID = dataset,
         day = day(eventDate),
         decimalLatitude = if_else(decimalLatitude > 0, -decimalLatitude, decimalLatitude),
         month = month(eventDate)) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_path)
