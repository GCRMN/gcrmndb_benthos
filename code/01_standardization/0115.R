# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0115" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  rename(locality = Site_Name, decimalLatitude = Northing, decimalLongitude = Easting) %>% 
  select(locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  pivot_longer("prop_coral":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(year = Year, parentEventID = Transect, verbatimDepth = Depth, locality = Site) %>% 
  select(locality, parentEventID, verbatimDepth, year, locality, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         measurementValue = measurementValue*100,
         locality = str_replace_all(locality, c("Coral City" = "Coral City",
                                                "Coral City " = "Coral City",
                                                "Grundys  Gardens" = "Grundy's Gardens",
                                                "Grundys" = "Grundy's Gardens",
                                                "Icon" = "Icon",
                                                "Jigsaw" = "Jigsaw Puzzle",
                                                "Joys Joy" = "Joy's Joy",
                                                "Marilyns Cut" = "Marylin's Cut",
                                                "Marilyns" = "Marylin's Cut",
                                                "Marthas" = "Martha's Finyard",
                                                "Meadows" = "The Meadows",
                                                "Mixing Bowl" = "Mixing Bowl",
                                                "Pauls Anchor" = "Paul's Anchor",
                                                "Rock Bottom" = "Rock Bottom Wall",
                                                "Sailfin" = "Sailfin Reef",
                                                "Snapshot" = "Snap Shot",
                                                "West Point" = "West Point",
                                                "Westpoint" = "West Point")),
         verbatimDepth = round(verbatimDepth*0.3048, 1)) %>% # Convert depth from feet to meters
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
