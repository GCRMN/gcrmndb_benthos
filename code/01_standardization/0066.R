# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0066" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(file = .) %>% 
  rename(locality = Site,
         decimalLatitude = Latitude,
         decimalLongitude = Longitude,
         verbatimDepth = Depth_m, 
         year = Year,
         month = Month,
         day = Day) %>% 
  mutate(samplingProtocol	= "Photo-quadrat",
         year = str_remove_all(year, "_pre|_post"),
         year = as.numeric(year),
         month = str_replace_all(month, c("July" = "07",
                                          "August" = "08",
                                          "November" = "11",
                                          "December" = "12",
                                          "September" = "09",
                                          "May" = "05")),
         month = as.numeric(month),
         eventDate = as.Date(paste0(as.character(year),
                                    "-",
                                    str_pad(month, width = 2, pad = "0"),
                                    "-",
                                    str_pad(day, width = 2, pad = "0")))) %>% 
  select(Site_ID, eventDate, year, month, day, locality, decimalLatitude, decimalLongitude, verbatimDepth)

## 2.2 Main data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(file = .) %>% 
  select(-Number.of.frames, -CORAL, -GORGONIANS, -SPONGES, -ZOANTHIDS, -MACROALGAE, -OTHER.LIVE,
         -DEAD.CORAL.WITH.ALGAE, -CORALLINE.ALGAE, -DISEASED.CORALS, -SAND..PAVEMENT..RUBBLE,
         -UNKNOWNS, -Aspergillus, -Black.Band.Disease, -Bleached.coral.point, -Other.disease,
         -Plague..Type.II, -White.Band.Disease, -Yellow.Blotch.Disease, -Number_frames_bleaching,
         -Number_frames_disease, -Bleaching_frequency, -Disease_frequency, -TURF) %>% 
  pivot_longer(2:ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset) %>% 
  select(-Site_ID) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_path, data_site)
