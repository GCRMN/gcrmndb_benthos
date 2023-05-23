# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(mermaidr) # API to mermaid data. To install -> remotes::install_github("data-mermaid/mermaidr")

source("code/00_functions/mermaid_converter.R")

dataset <- "0010" # Define the dataset_id

# 2. Import, standardize and export the data ----

A <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(.) %>% 
  mutate(row = row_number()) %>% 
  group_by(row) %>% 
  group_modify(~mermaid_converter(data = .x)) %>% 
  ungroup() %>% 
  select(-row)


############# TEST ###################


projects <- mermaid_get_projects()

data <- mermaid_get_project_data(project = "60dd6ca0-d9d5-4f81-a3b7-7ac88ab3519c")

wcs_mozambique <- projects %>%
  filter(name == "2013-2014_Koro Island, Fiji") %>%
  mermaid_get_project_data(method = "fishbelt", data = "sampleevents")


# 1. Access the data and download it in the appropriate folder
# 2. Standardize the data using the function dedicated to MERMAID data
# 3. Export the data to the folder standardized data

