// var reef = reef_500_poly.shp

var reef_buffer = function(feature) {
  return feature.buffer(100000); // 100 km  
};

var reef_buffer = reef.map(reef_buffer);

var reef_buffer = reef_buffer.union();

//Map.addLayer(reef_buffer);

Export.table.toDrive({
  collection: reef_buffer,
  folder: "GEE",
  description: "reef_buffer",
  fileFormat: "SHP"
});
