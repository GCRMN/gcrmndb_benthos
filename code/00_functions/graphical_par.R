# 1. Required packages ----

require(extrafont) # For fonts

# 2. Set the default font family ----

windowsFonts("ArialMT" = windowsFont("ArialMT"))

font_choose_graph <- "ArialMT"
font_choose_map <- "ArialMT"

# 3. Set the colors ----

col_fill_graph <- "#89C4F4"
col_color_graph <- "#446CB3"
col_fill_map <- "#f2caae"
col_color_map <- "#6c7a89"
col_background_map <- "#e4f1fe"
col_facet <- "#ECF0F1"

col_fill_bleaching <- "#d64541"
col_fill_ts <- "#2abb9b"

# 4. Number of facets by plot ----

facets_by_plot <- 20 

# 5. Variable names ----

var_names <- c("datasetID", "higherGeography", "country", "territory", "locality",
               "habitat", "parentEventID", "eventID", "decimalLatitude", "decimalLongitude",
               "verbatimDepth", "year", "month", "day", "eventDate", "samplingProtocol",
               "recordedBy", "category", "subcategory", "condition", "phylum", "class",
               "order", "family", "genus", "scientificName", "measurementValue")
