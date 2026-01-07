// 1. WRI coral reef distribution ----

var data_wri = ee.FeatureCollection("users/jeremywicquart/misc/reef_500_poly");

// 2. ETP coral reefs sites ----

var data_etp = ee.FeatureCollection("users/jeremywicquart/gcrmndb_benthos/gcrmndb-benthos_etp-reef-sites");

var site_buffer = function(feature) {
  return feature.geometry()
    .buffer({distance: 250, maxError: 10})
    .bounds(1);
};

var data_etp = data_etp.map(site_buffer)
  .union(1);

// 3. Create reefs for Norfolk island ----

// Point obtained from observation of coral reefs presence from 
// "Anthropogenic Impacts on Coral-Algal Interactions of the
// Subtropical Lagoonal Reef, Norfolk Island"

var data_norfolk = ee.Geometry.Point([167.958552, -29.061416])
  .buffer({distance: 250, maxError: 10})
  .bounds(1);

// 4. Visual check ----

//Map.addLayer(data_norfolk, {color: '#e74c3c',  fillColor: '#e74c3c'});
//Map.addLayer(data_etp, {color: '#6c5ce7',  fillColor: '#a29bfe'});
//Map.addLayer(data_wri, {color: '#e1b12c',  fillColor: '#fbc531'});

// 5. Merge data ----

var data_reefs = data_etp.merge(data_norfolk)
  .merge(data_wri)
  .union(1);

//Map.addLayer(data_all, {color: '#6c5ce7',  fillColor: '#a29bfe'});

// 6. Remove Galapagos, except Darwin and Wolf Islands ----

var data_galapagos = ee.Geometry.Polygon([
  [-92.61271, -2.13939],
  [-88.54777, -2.13939],
  [-88.54777,  0.82638],
  [-92.61271,  0.82638],
  [-92.61271, -2.13939]
]);

var data_reefs = data_reefs.map(function(f) {
  var g = f.geometry().difference(data_galapagos, ee.ErrorMargin(1));
  return ee.Feature(g).copyProperties(f);
});

// 7. Export shapefile ----

Export.table.toDrive({
  collection: data_reefs,
  fileNamePrefix:"reefs_corrected",
  folder: "GEE",
  description: "reefs_corrected",
  fileFormat: "SHP"
});

// 8. Create 100 km buffer ----

// 8.1 Create a function to create the buffer ----

var reef_buffer = function(feature) {
  return feature.buffer({distance: 100000, maxError: 1000}); // 100 km  
};

// 8.2 Map over the function ----

var reef_buffer = data_reefs.map(reef_buffer)
  .union(1);

// 8.3 Export the data ----

Export.table.toDrive({
  collection: reef_buffer,
  fileNamePrefix:"reef_buffer_100",
  folder: "GEE",
  description: "reef_buffer_100",
  fileFormat: "SHP"
});
