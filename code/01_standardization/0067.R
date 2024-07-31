# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0067" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(file = ., na.strings = c("NA", "", " ")) %>% 
  rename(locality = Station, eventDate = Date, parentEventID = REPLICAT_Numero,
         decimalLongitude = REPLICAT_Coordonnees_MINX, decimalLatitude = REPLICAT_Coordonnees_MINY,
         verbatimDepth = OBSERVATION_Profondeur.Metre) %>% 
  mutate(eventDate = as.Date(strptime(eventDate, "%d/%m/%Y")),
         verbatimDepth = case_when(verbatimDepth == "06,1 - 09 m" ~ "7.5",
                                   verbatimDepth == "09,1 - 12 m" ~ "10.5",
                                   verbatimDepth == "03,1 - 06 m" ~ "4.5",
                                   verbatimDepth == "15,1 - 20 m" ~ "17.5"),
         verbatimDepth = as.numeric(verbatimDepth),
         organismID = coalesce(Taxon, Groupe_taxons, REPLICAT_Substrat_Protocole_PIT_transects_stationnaires)) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate, organismID) %>% 
  group_by(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate) %>% 
  mutate(total = n()) %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate, organismID, total) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total) %>% 
  select(-total, -n) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 20 cm",
         datasetID = dataset) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
