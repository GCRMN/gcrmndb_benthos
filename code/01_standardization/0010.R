# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(mermaidr) # API to mermaid data. To install -> remotes::install_github("data-mermaid/mermaidr")

dataset <- "0008" # Define the dataset_id

# 2. Import, standardize and export the data ----

projects <- mermaid_get_projects()



data <- mermaid_get_project_data(project = "fe3f915c-ffd3-4290-a413-85672a8946e2")


wcs_mozambique <- projects %>%
  filter(name == "WCS Mozambique Coral Reef Monitoring") %>%
  mermaid_get_project_data(method = "fishbelt", data = "sampleevents")
