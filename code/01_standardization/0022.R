# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0022" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(.) %>% 
  rename(decimalLatitude = x, decimalLongitude = y, verbatimDepth = depth, locality = site_code, habitat = reeftype) %>% 
  pivot_longer("BRANCHING.CORALLINE.ALGAE":"TURF.ALGAE", values_to = "measurementValue", names_to = "organismID") %>% 
  filter(measurementValue != 0) %>% 
  mutate(datasetID = dataset,
         year = str_split_fixed(event_date, "/", 3)[,3],
         month = str_split_fixed(event_date, "/", 3)[,1],
         day = str_split_fixed(event_date, "/", 3)[,2],
         eventDate = as_date(paste(year, month, day, sep = "-")),
         verbatimDepth = str_replace_all(verbatimDepth, c("8m" = "8",
                                                          "3-5m" = "4",
                                                          "3m" = "3")),
         verbatimDepth = as.numeric(verbatimDepth),
         transect_length = str_replace_all(transect_length, c("50m" = "50",
                                                              "50 m" = "50",
                                                              "25m" = "25",
                                                              "50" = "50")),
         transect_length = as.numeric(transect_length),
         samplingProtocol = paste0("Photo-quadrat, ", transect_length," m transect length, every 1 m")) %>% 
  select(-event_date, -"date.site", -transect_length, -subregion_name) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

