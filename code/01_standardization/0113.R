# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0113" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "DATA_V2", skip = 1, na = c("NA", "(blank)")) %>% 
  # Remove HRI data since they are included within AGRRA data
  filter(`Organization that produced the data` != "The Healthy Reefs Initiative <www.healthyreefs.org>") %>% 
  select(-`...54`) %>% 
  pivot_longer("Acropora":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Nombre_sitio, day = Día, month = Mes, year = Anio,
         decimalLatitude = Latitud, decimalLongitude = longitud, verbatimDepth = `Depth (m)`,
         parentEventID = Transecto, samplingProtocol = Metodo) %>% 
  select(locality, day, month, year, decimalLatitude, decimalLongitude,
         verbatimDepth, parentEventID, samplingProtocol, organismID, measurementValue) %>% 
  mutate(eventDate = paste0(year, "-", str_pad(month, width = 2, pad = "0"),
                            "-", str_pad(day, width = 2, pad = "0")),
         datasetID = dataset) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, eventDate) %>% 
  mutate(parentEventID = as.numeric(as.factor(parentEventID))) %>% 
  ungroup() %>% 
  drop_na(decimalLatitude) %>% # remove one empty row
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
