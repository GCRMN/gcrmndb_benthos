mermaid_converter_sampleevents <- function(data, dataset, method){
  
  result <- data %>% 
    pivot_longer("percent_cover_benthic_category_avg_sand":"percent_cover_benthic_category_avg_crustose_coralline_algae",
                 names_to = "organismID", values_to = "measurementValue") %>% 
    mutate(organismID = str_remove_all(organismID, "percent_cover_benthic_category_avg_")) %>% 
    select(site, latitude, longitude, sample_date, depth_avg, organismID, measurementValue) %>% 
    rename(decimalLatitude = latitude, decimalLongitude = longitude, eventDate = sample_date,
           verbatimDepth = depth_avg, locality = site) %>% 
    mutate(eventDate = as_date(eventDate),
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           datasetID = dataset,
           samplingProtocol = method,
           organismID = str_to_sentence(str_replace_all(organismID, "_", " ")))
  
  return(result)
  
}