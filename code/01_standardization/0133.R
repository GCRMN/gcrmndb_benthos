# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0133" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = REEF_NAME, decimalLatitude = LATITUDE, decimalLongitude = LONGITUDE,
         verbatimDepth = CREST_DEPTH, parentEventID = TRANSECT_NO, organismID = BENTHOS_DESC,
         eventDate = SAMPLE_DATE, recordedBy = OBSERVER, measurementValue = LENGTH) %>% 
  mutate(eventDate = str_sub(eventDate, 1, 11),
         eventDate = str_replace_all(eventDate, c("Dec" = "12",
                                                  "Jan" = "01",
                                                  "Feb" = "02")),
         eventDate = as.Date(eventDate, tryFormats = c("%d-%m-%Y")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Line Intercept Transect",
         decimalLatitude = abs(decimalLatitude),
         decimalLongitude = -decimalLongitude) %>% 
  select(-SAMPLE_ID, -COUNTRY, -REEF_ZONE, -TRANSITION, -BENTHOS, -TRANSECT_LENGTH) %>%  
  # Recalculate total transect length (should be equal to the variable TRANSECT_LENGTH)
  group_by(locality, eventDate, parentEventID, verbatimDepth) %>% 
  mutate(total_length = sum(measurementValue)) %>% 
  ungroup() %>% 
  # Sum of length for same categories within a transect
  group_by(across(c(-measurementValue))) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  ungroup() %>% 
  # Transform length to percentage cover
  mutate(measurementValue = (measurementValue*100)/total_length) %>% 
  select(-total_length) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
