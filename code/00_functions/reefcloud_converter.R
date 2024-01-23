reefcloud_converter <- function(data, datasetID = dataset){
  
  result <- data %>% 
    pivot_longer(24:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    rename(eventDate = date, verbatimDepth = depth_m, decimalLongitude = site_longitude,
           decimalLatitude = site_latitude, eventID = unique_id, parentEventID = transect,
           habitat = site_reef_type, locality = site) %>% 
    mutate(eventDate = as_date(dmy_hm(eventDate)),
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           datasetID = datasetID,
           samplingProtocol = "Photo-quadrat") %>% 
    select(datasetID, locality, parentEventID, eventID, decimalLatitude, decimalLongitude,
           verbatimDepth, year, month, day, eventDate, samplingProtocol, organismID, measurementValue)
  
  return(result)
  
}
