// 1. Define background map style ----

Map.setOptions('TERRAIN');

// 2. Import and show WRI coral reef distribution data ----

var reef = ee.FeatureCollection("users/jeremywicquart/data_reefs");
Map.addLayer(reef, {color: '#2c82c9'}, 'Coral reefs');

// 3. Import and show gcrmndb_benthos monitoring sites ----

// 3.1 Add the layers ----

var site_coords = ee.FeatureCollection("users/jeremywicquart/gcrmndb-benthos_site-coords");

var site_coords_1 = site_coords.filter("int_class == '1 year'");
Map.addLayer(site_coords_1, {color: '#fac484'}, '1 year');

var site_coords_2 = site_coords.filter("int_class == '2-5 years'");
Map.addLayer(site_coords_2, {color: '#f8a07e'}, '2-5 years');

var site_coords_3 = site_coords.filter("int_class == '6-10 years'");
Map.addLayer(site_coords_3, {color: '#ce6693'}, '6-10 years');

var site_coords_4 = site_coords.filter("int_class == '11-15 years'");
Map.addLayer(site_coords_4, {color: '#a059a0'}, '11-15 years');

var site_coords_5 = site_coords.filter("int_class == '>15 years'");
Map.addLayer(site_coords_5, {color: '#5c53a5'}, '>15 years');

// 3.2 Add the legend ----

// set position of panel
var legend = ui.Panel({
  style: {
    position: 'bottom-left',
    padding: '8px 15px'
  }
});
 
// Create legend title
var legendTitle = ui.Label({
  value: 'Monitoring years',
  style: {
    fontWeight: 'bold',
    fontSize: '18px',
    margin: '0 0 4px 0',
    padding: '0'
    }
});
 
// Add the title to the panel
legend.add(legendTitle);
 
// Creates and styles 1 row of the legend.
var makeRow = function(color, name) {
 
      // Create the label that is actually the colored box.
      var colorBox = ui.Label({
        style: {
          backgroundColor: '#' + color,
          // Use padding to give the box height and width.
          padding: '8px',
          margin: '0 0 4px 0'
        }
      });
 
      // Create the label filled with the description text.
      var description = ui.Label({
        value: name,
        style: {margin: '0 0 4px 6px'}
      });
 
      // return the panel
      return ui.Panel({
        widgets: [colorBox, description],
        layout: ui.Panel.Layout.Flow('horizontal')
      });
};
 
//  Palette with the colors
var palette =["fac484", "f8a07e", "ce6693", "a059a0", "5c53a5"];
 
// name of the legend
var names = ["1 year", "2-5 years", "6-10 years", "11-15 years", ">15 years"];
 
// Add color and and names
for (var i = 0; i < 5; i++) {
  legend.add(makeRow(palette[i], names[i]));
  }  
 
// add legend to map (alternatively you can also print the legend to the console)
Map.add(legend);

// 4. Import and show gcrmndb_benthos monitoring sites for a given datasetID ----

//var site_coords_i = ee.FeatureCollection("users/jeremywicquart/gcrmndb-benthos_site-coords").filter("datasetID == '0047'");

//Map.addLayer(site_coords_i, {color: 'red'});
//Map.centerObject(site_coords_i);
