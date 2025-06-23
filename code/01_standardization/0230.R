# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(sf)

dataset <- "0230" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2(, skip = 1) %>% 
  rename(eventDate = Date, decimalLatitude = Lat, decimalLongitude = Long,
         locality = Station_new) %>% 
  select(eventDate, decimalLatitude, decimalLongitude, locality, X._Rec_coral, X._algal) %>% 
  pivot_longer(5:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = str_replace_all(organismID, c("X._algal" = "Algae",
                                                    "X._Rec_coral" = "Hard coral")),
         eventDate = as.Date(eventDate, format = "%d/%m/%y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Visual estimate, circulate plot of 5.6 m radius") %>% 
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = "EPSG:2975") %>% 
  st_transform(crs = 4326) %>%
  mutate(decimalLatitude = st_coordinates(.)[,2],
         decimalLongitude = st_coordinates(.)[,1]) %>% 
  st_drop_geometry() %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
