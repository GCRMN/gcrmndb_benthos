# 1. Packages ----

library(tidyverse)

dataset <- "0273" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2(., na.strings = c("NA", "na", "")) %>% 
  mutate(organismID = case_when(str_detect(Taxon, "Turbinaria") == TRUE ~ 
                                  paste0(Taxon, " - ", Groupe_taxons),
                                str_detect(Taxon, "Turbinaria") == FALSE ~ 
                                  coalesce(Taxon, Groupe_taxons, REPLICAT_Substrat_Protocole_LIT))) %>% 
  rename(eventDate = Date, parentEventID = REPLICAT_Numero, locality = Station, 
         decimalLatitude = REPLICAT_Coordonnees_MINY,
         decimalLongitude = REPLICAT_Coordonnees_MINX,
         measurementValue = "REPLICAT_Section_Protocole_LIT.Centimetre",
         verbatimDepth = "OBSERVATION_Profondeur.Metre") %>% 
  mutate(eventDate = as.Date(eventDate, format = "%d/%m/%Y"),
         day = day(eventDate),
         month = month(eventDate),
         year = year(eventDate),
         datasetID = dataset,
         verbatimDepth = case_when(verbatimDepth == "06,1 - 09 m" ~ "7.5",
                                   verbatimDepth == "00 - 03 m" ~ "1.5",
                                   verbatimDepth == "03,1 - 06 m" ~ "4.5"),
         verbatimDepth = as.numeric(verbatimDepth),
         samplingProtocol = "Line intersect transect, 20 m transect length") %>% 
  select(datasetID, eventDate, year, month, day, locality, decimalLatitude, decimalLongitude, parentEventID,
         samplingProtocol, verbatimDepth, organismID, measurementValue) %>% 
  group_by(eventDate, locality, parentEventID, decimalLatitude, decimalLongitude) %>% 
  mutate(total_length_transect = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total_length_transect) %>% 
  select(-total_length_transect) %>% 
  group_by(across(c(-measurementValue))) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
