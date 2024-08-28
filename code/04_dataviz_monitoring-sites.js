// 1. Import and show WRI coral reef distribution data ----

var reef = ee.FeatureCollection("users/jeremywicquart/data_reefs");

Map.addLayer(reef, {color: 'lightblue'});

// 2. Import and show gcrmndb_benthos monitoring sites ----

var site_coords = ee.FeatureCollection("users/jeremywicquart/gcrmndb-benthos_site-coords");

Map.addLayer(site_coords, {color: 'red'});

// 3. Import and show gcrmndb_benthos monitoring sites for a given datasetID ----

//var site_coords_i = ee.FeatureCollection("users/jeremywicquart/gcrmndb-benthos_site-coords").filter("datasetID == '0070'");

//Map.addLayer(site_coords_i, {color: '#9b59b6'});
