# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(mermaidr) # API to mermaid data. To install -> remotes::install_github("data-mermaid/mermaidr")

dataset <- "0008" # Define the dataset_id

# 2. Import, standardize and export the data ----

projects <- mermaid_get_projects()
