// var land = ne_10m_land.shp

var land_buffer = function(feature) {
  return feature.buffer(-5000); // -5km  
};

var land_buffer = land.map(land_buffer);

var land_buffer = land_buffer.union();

//Map.addLayer(land_buffer);

Export.table.toDrive({
  collection: land_buffer,
  folder: "GEE",
  description: "land_buffer",
  fileFormat: "SHP"
});