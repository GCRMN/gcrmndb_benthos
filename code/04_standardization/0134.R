# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0134" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., skip = 2,
            col_names = c("location", "management", "locality", "habitat",
                          "decimalLatitude", "decimalLongitude", "verbatimDepth",
                          "Method", "Replication", "Sampling")) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, habitat) %>% 
  mutate(locality = str_squish(locality),
         verbatimDepth = str_replace_all(verbatimDepth, c("Within 4 m of reef crest" = "4",
                                                          "~10 m depth" = "10")),
         verbatimDepth = as.numeric(verbatimDepth),
         decimalLatitude = case_when(locality == "Berthier Is" ~ -14.4954825033352,
                                     TRUE ~ decimalLatitude),
         decimalLongitude = case_when(locality == "Berthier Is" ~ 124.994755514999,
                                      TRUE ~ decimalLongitude))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  mutate(organismID = paste0(Level2Class, " - ", Level4Class)) %>% 
  rename(locality = Site, parentEventID = Replicate, eventID = ImageName,
         eventDate = Date, measurementValue = Percent_cover) %>% 
  select(locality, parentEventID, eventID, eventDate, organismID, measurementValue) %>% 
  group_by(locality, parentEventID, eventDate) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, 2, 2)),
         eventDate = as.Date(eventDate, tryFormats = "%d/%m/%Y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         locality = str_squish(locality),
         samplingProtocol = "Photo-quadrat, 350 m transect length",
         datasetID = dataset,
         locality = str_replace_all(locality, c("Berthier_Turbin Is" = "Berthier Is",
                                                "Seahorse Is" = "Seahorse Island",
                                                "Niiwalarra Is Nth" = "Niiwalara Nth",
                                                "Niiwalarra Is NW" = "Niiwalara NW"))) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
  
# 3. Remove useless objects ----

rm(data_site)
