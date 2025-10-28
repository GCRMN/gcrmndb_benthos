# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0087" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(organismID = case_when(Taxon != "" ~ paste0(Groupe_taxons, " - ", Taxon),
                                TRUE ~ Groupe_taxons),
         verbatimDepth = case_when(OBSERVATION_Profondeur.Metre == "03,1 - 06 m" ~ 4.5,
                                   OBSERVATION_Profondeur.Metre == "00 - 03 m" ~ 1.5,
                                   TRUE ~ NA),
         samplingProtocol = case_when(is.na(REPLICAT_Longueur_transect_metre_ruban.Metre) ~ "Point intersect transect",
                                      TRUE ~ paste0("Point intersect transect, ",
                                                    REPLICAT_Longueur_transect_metre_ruban.Metre,
                                                    " m transect length")),
         Date = as.Date(Date, "%d/%m/%Y")) %>% 
  rename(locality = Station, eventDate = Date, parentEventID = REPLICAT_Numero, 
         decimalLongitude = OBSERVATION_Coordonnees_MINX, decimalLatitude = OBSERVATION_Coordonnees_MINY) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
         samplingProtocol, organismID) %>% 
  # Transform from number of points to percentage cover
  group_by(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
           samplingProtocol, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
           samplingProtocol) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = measurementValue*100/total) %>% 
  select(-total) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         # Correct site coordinates (based on email from data owner)
         decimalLatitude = case_when(locality == "Petite-Terre - NE Passe" ~ 16.17443,
                                     locality == "Petite-Terre - Passe" ~ 16.17427,
                                     TRUE ~ NA),
         decimalLongitude = case_when(locality == "Petite-Terre - NE Passe" ~ -61.10583,
                                      locality == "Petite-Terre - Passe" ~ -61.10637,
                                      TRUE ~ NA)) %>% 
  filter(organismID != "") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
