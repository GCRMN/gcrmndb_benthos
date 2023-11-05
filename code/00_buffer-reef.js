// 1. Import coral reef distribution data ----

var reef = ee.FeatureCollection("users/jeremywicquart/reef_area");

// 2. Create a function to create the buffer ----

var reef_buffer = function(feature) {
  return feature.buffer(100000); // 100 km  
};

// 3. Map over the function ----

var reef_buffer = reef.map(reef_buffer);

var reef_buffer = reef_buffer.union();

// 4. Export the data ----

Export.table.toDrive({
  collection: reef_buffer,
  fileNamePrefix:"reef_buffer",
  folder: "GEE",
  description: "reef_buffer",
  fileFormat: "SHP"
});
