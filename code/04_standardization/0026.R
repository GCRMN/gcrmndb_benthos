# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(mermaidr) # API to mermaid data. To install -> remotes::install_github("data-mermaid/mermaidr")
source("code/00_functions/mermaid_converter_sampleevents.R")

dataset <- "0026" # Define the dataset_id

# 2. Get the MERMAID project ID ----

project_id <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset) %>% 
  select(project_id) %>% 
  pull()

# 3. Get data from the mermaidr API ----

data <- mermaid_get_project_data(project = project_id, 
                                 method = "benthicpit", data = "sampleevents", token = NULL)

# 4. Save raw data ----

write.csv(data, file = paste0("data/01_raw-data/", dataset, "/mermaid_", project_id, "_", lubridate::date(Sys.time()), ".csv"),
          row.names = FALSE)

# 5. Standardize data ----

mermaid_converter_sampleevents(data, dataset, method = "Point intersect transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 6. Remove useless objects ----

rm(data, project_id, mermaid_converter_sampleevents)
