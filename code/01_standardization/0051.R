# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0051" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(., na = c("NA", "na", "", " ", "Unk", "??")) %>% 
  rename(locality = Site.Name, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, decimalLatitude, decimalLongitude) %>% 
  drop_na(locality) %>% 
  mutate(locality = str_squish(str_to_sentence(locality)),
         locality = str_replace_all(locality, c("Montipora maddness" = "Montipora madness",
                                                "Orona lagoon a" = "Orona lagoon 1",
                                                "Orona lagoon c" = "Orona lagoon 3",
                                                "Nikita's lookout" = "Nikitas lookout",
                                                "Nai'a point" = "Naia point",
                                                "Obs spot" = "Observation spot",
                                                "Blobo corner" = "Bolbo corner",
                                                "Rock n roll" = "Rocknroll",
                                                "Simon's logger" = "Simons",
                                                "Rush hour" = "Rush",
                                                "Core site/ sw corner" = "Core")))

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv() %>% 
  select(-Island, -Grand.Total, -Hard.Coral, -Site.Num) %>% 
  rename(year = Year, locality = Site) %>% 
  mutate(locality = str_squish(str_to_sentence(locality)),
         locality = str_replace_all(locality, c("Souther ocean" = "Southern ocean",
                                                "Puffmagic" = "Puff magic",
                                                "Prognathuspoint" = "Prognathus point",
                                                "Windy city" = "Windward city",
                                                "Wreck city" = "Windward wreck",
                                                "Rush hour" = "Rush"))) %>% 
  left_join(., data_site) %>% 
  pivot_longer("Acropora":"Zooanthid", values_to = "measurementValue", names_to = "organismID") %>% 
  group_by(locality, year) %>% 
  mutate(eventID = as.numeric(as.factor(Picture))) %>% 
  ungroup() %>% 
  select(-Picture) %>% 
  mutate(samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
