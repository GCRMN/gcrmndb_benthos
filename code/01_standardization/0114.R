# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0114" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  drop_na(Latitude) %>% 
  rename(locality = `Site Name`, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = `Max depth (m)`) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth)

## 2.2 Main data ----

data_main_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Data", skip = 1)

data_main_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Data")

bind_rows(data_main_b, data_main_a) %>% 
  pivot_longer("Acropora cervicornis":ncol(.),
               names_to = "organismID", values_to = "measurementValue") %>% 
  rename(parentEventID = Transect, locality = Site, year = Year, month = Month, day = Day,
         eventID = `Image name`) %>% 
  select(locality, parentEventID, eventID, year, month, day, organismID, measurementValue) %>% 
  mutate(locality = str_replace_all(locality, c("OuterJenkins" = "Outer Jenkins Bay",
                                                "Cave" = "The Cave",
                                                "Venus" = "Venus Bay",
                                                "ValleyofSponges" = "Valley of the Sponges",
                                                "Barracuda" = "Barracuda Reef",
                                                "FiveFingersSouth" = "Five Fingers South",
                                                "CrooksCastle" = "Crooks Castle",
                                                "STENAPA" = "STENAPA Reef**",
                                                "DoubleWreck" = "Double Wreck",
                                                "SE19" = "STE_19",
                                                "CorreCorre" = "Corre Corre",
                                                "TwinSisters" = "Twin Sisters",
                                                "TripleWreck" = "Triple Wreck",
                                                "Whitewall" = "White Wall",
                                                "AnchorPointSouth" = "Anchor Point South",
                                                "AnchorPoint" = "Anchor Point South",
                                                "STE19" = "STE_19"))) %>% 
  left_join(., data_site) %>%
  # Convert eventID from character to numeric
  group_by(locality, parentEventID, year, month, day, verbatimDepth) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(eventDate = case_when(!(is.na(day)) ~ as.Date(paste0(year, "-",
                                                              str_pad(month, pad = "0", width = 2), "-",
                                                              str_pad(day, pad = "0", width = 2))),
                               TRUE ~ NA),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_main_a, data_main_b)
