# 1. Packages ----

library(tidyverse)

dataset <- "0093" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(., fileEncoding = "Latin1") %>% 
  rename(locality = "Site.Name", decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = "Z...true..m.") %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(decimalLatitude = str_replace_all(decimalLatitude, "18.07169; 18.34732", "18.07169"),
         decimalLatitude = as.numeric(decimalLatitude),
         decimalLongitude = str_replace_all(decimalLongitude, "-67.93698;-67.26997", "-67.93698"),
         decimalLongitude = as.numeric(decimalLongitude),
         locality = str_squish(locality),
         locality = str_replace_all(locality, "Caña Gorda", "Cana Gorda"))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(., fileEncoding = "Latin1", na.strings = c("", " ", "NA", "na")) %>% 
  filter(!(row_number() %in% c(1860, 1861))) %>% 
  pivot_longer("Recently.dead.coral":ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  rename(locality = "SITE.NAME", parentEventID = "TRANSECT", year = YEAR) %>% 
  select(locality, parentEventID, year, organismID, measurementValue) %>% 
  mutate(locality = str_squish(locality),
         locality = str_replace_all(locality, "Berbería", "Berberia"),
         measurementValue = as.numeric(measurementValue),
         datasetID = dataset,
         samplingProtocol = "Chain intersect transect, 10 m transect length") %>% 
  left_join(., data_site) %>% 
  filter(!(organismID %in% c("Abiotic..total.", "Anemones..total.", "Macroalgae..total.", "Turf.Algae..total.",
                             "Octocorals..total.erect.", "Octocorals..total.encrusting.", "Zoanthids..total.",
                             "Stony.Corals..total.", "Stony.Corals..total...diseased.col..", 
                             "Stony.Corals..total..col..", "Stony.Corals..total...bleached.col..",
                             "Partially.bleached.coral..total.", "Antillogorgia.acerosa....col..",
                             "Antillogorgia.americana....col..", "Antillogorgia.bipinnata....col..",
                             "Antillogorgia.spp.....col..", "Briareum.asbestinum....col..", "Erythropodium.caribaeorum....col..",
                             "Eunicea.asperula....col..", "Eunicea.calyculata....col..", "Eunicea.flexuosa....col..",
                             "Eunicea.laciniata....col..", "Eunicea.laxispica....col..", "Eunicea.mammosa....col..",
                             "Eunicea.spp.....col..", "Eunicea.succinea....col..", "Eunicea.tourneforti....col..",
                             "Gorgonia.ventalina....col..", "Muricea.atlantica....col..", "Muricea.elongata....col..",
                             "Muricea.laxa....col..", "Muricea.muricata....col..", "Muricea.spp.....col..",
                             "Muriceopsis.flavida....col..", "Plexaura.homomalla....col..", "Plexaura.kukenthali....col..",
                             "Plexaura.kuna....col..", "Plexaura.spp.....col..", "Plexaurella.dichotoma....col..",
                             "Plexaurella.nutans....col..", "Plexaurella.spp.....col..", "Pseudoplexaura.flagellosa....col..",
                             "Pseudoplexaura.porosa....col..", "Pterogorgia.citrina....col..", "Pterogorgia.guadalupensis....col..",
                             "Pterogorgia.spp.....col..", "Octocoral..total...col..", "Tunicata..total.", "Sponges..total.",
                             "Seagrass..total.", "Peyssonneliaceae..total.", "Orbicella.annularis..complex."))) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, version)
