# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0118" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  pivot_longer("Sand":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         parentEventID = Replicate, eventID = Individual.Quadrat.ID,
         verbatimDepth = Depth_Below_Chart_Datum..m., recordedBy = Person.in.charge.of.observation) %>% 
  mutate(locality = paste0("S", locality),
         samplingProtocol = "Photo-quadrat",
         year = case_when(Sampling.time == "February/March, 2016" ~ 2016,
                          Sampling.time == "January, 2018" ~ 2018,
                          Sampling.time == "January, 2020" ~ 2020,
                          Sampling.time == "January/February, 2021" ~ 2021,
                          Sampling.time == "October, 2016" ~ 2016),
         month = case_when(Sampling.time == "February/March, 2016" ~ 3,
                           Sampling.time == "January, 2018" ~ 1,
                           Sampling.time == "January, 2020" ~ 1,
                           Sampling.time == "January/February, 2021" ~ 2,
                           Sampling.time == "October, 2016" ~ 10),
         datasetID = dataset) %>% 
  select(-Country, -Region, -Location, -Habitat, -Exposure, -Method, -Zone, -Sampling.time) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
