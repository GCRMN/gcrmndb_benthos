reefcloud_converter <- function(data, datasetID = dataset, pivot_nb = 15){
  
  result <- data %>% 
    pivot_longer(as.numeric(pivot_nb):ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    rename(eventDate = date..UTC., verbatimDepth = depth_m, decimalLongitude = site_longitude,
           decimalLatitude = site_latitude, eventID = unique_id, parentEventID = transect,
           locality = site) %>% 
    mutate(eventDate = as.Date(str_sub(eventDate, 1, 10)),
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           datasetID = datasetID,
           samplingProtocol = "Photo-quadrat") %>% 
    select(datasetID, locality, parentEventID, eventID, decimalLatitude, decimalLongitude,
           verbatimDepth, year, month, day, eventDate, samplingProtocol, organismID, measurementValue) %>% 
    group_by(eventDate, locality, parentEventID, verbatimDepth) %>% 
    mutate(eventID = as.numeric(as.factor(eventID))) %>% 
    ungroup()
  
  return(result)
  
}