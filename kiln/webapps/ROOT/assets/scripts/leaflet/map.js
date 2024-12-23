/**
 * Add a legend to the map.
 *
 * @param {Map} map - map to add legend to
 * @param {String} baseImagePath - base path for images
 */
function addLegend(map, baseImagePath) {
  let legend = L.control({position: 'bottomright'});
  legend.onAdd = function(map) {
    let div = L.DomUtil.create('div', 'info_legend');
    div.innerHTML = ('<br>' + '<img src="' + baseImagePath +
                     'legendicon.png"  height="50" width="50">' + '<br>');
    div.setAttribute('onmouseenter', "showLegend('" + baseImagePath + "')");
    div.setAttribute('onclick', "hideLegend('" + baseImagePath + "')");
    div.setAttribute('onmouseleave', "hideLegend('" + baseImagePath + "')");
    div.id = 'info_legend';
    return div;
  };
  legend.addTo(map);
}


/**
 * Add a GeoJSON-sourced layer to the map and return it.
 *
 * @param {Map} map - map to add layer to
 * @return {Layer}
 */
function addRegionLayer(map) {
  let region = L.Proj.geoJson(null, {
    style: function(feature) {
      return {color: 'yellow', opacity: 0.7, fillColor: 'none'};
    },
    onEachFeature: function(feature, layer) {
      var popupContent;
      if (feature.properties && feature.properties.place_type) {
        popupContent = 'Source Region: ' +
          feature.properties.name +
          '<br>Region Type: ' + feature.properties.place_type;
      }
      layer.bindPopup(popupContent);
    }
  });
  region.addData(source_region_geojson);
  map.addLayer(region);
  return region;
}

/**
 * Add a GeoJSON-sourced layer to the map and return it.
 *
 * @param {Map} map - map to add layer to
 * @param {String} baseImagePath - base path for images
 * @return {Layer}
 */
function addRelatedLayer(map, baseImagePath) {
  // Define the icon to use as the default icon for each related point
  // when not included in a marker cluster.
  let relatedIcon = L.icon({
    iconUrl: baseImagePath + 'REED_circle_red_10.png',
    iconSize: [10, 10],
    iconAnchor: [5, 5],
    popupAnchor: [0, -5]
  });
  let relatedMarkers = L.markerClusterGroup({
    maxClusterRadius: 20,
    showCoverageOnHover: true,
    zoomToBoundsOnClick: true,
    polygonOptions: {color: '#03f', weight: 2, opacity: 0.5},
    spiderfyOnMaxZoom: true,
    spiderfyDistanceMultiplier: 0.4,
    spiderLegPolylineOptions: {weight: 1.5, color: '#B3B3B3', opacity: 0.6}
  });
  let relatedLayer = L.Proj.geoJson(null, {
    pointToLayer: function(feature, latlng) {
      return L.marker(latlng, {icon: relatedIcon});
    },
    onEachFeature: function(feature, layer) {
      layer.bindPopup(getRelatedPopupContent(feature));
    }
  });
  relatedLayer.addData(related_location_geojson);
  relatedMarkers.addLayer(relatedLayer);
  map.addLayer(relatedMarkers);
  return relatedLayer;
}


/**
 * Add a GeoJSON-sourced layer to the map and return it.
 *
 * @param {Map} map - map to add layer to
 * @param {String} baseImagePath - base path for images
 * @return {Layer}
 */
function addSourceLayer(map, baseImagePath) {
  let sourceIcon = L.icon({
    iconUrl: baseImagePath + 'Yellow-Hollow-22.png',
    iconSize: [22, 22],
    iconAnchor: [11, 11],
    popupAnchor: [0, -11]
  });
  let sourceLayer = L.Proj.geoJson(null, {
    pointToLayer: function(feature, latlng) {
      return L.marker(latlng, {icon: sourceIcon,
                               zIndexOffset: 1000, interactive: false});
    },
  });
  sourceLayer.addData(source_location_geojson);
  map.addLayer(sourceLayer);
  return sourceLayer;
}


/**
 * Add tile layers (base and overlays) to the map.
 *
 * @param {Map} map - map to add layers to
 */
function addTileLayers(map) {
  let county_coverage = L.tileLayer(
    getREEDLayerURL('EREED_gis_counties_base'), {
      attribution: '<a href="http://reed.utoronto.ca/">Records of Early English Drama</a>',
    });
  let relief = L.tileLayer(getREEDLayerURL('REED_gis_relief'));
  let osm = L.tileLayer(
    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
      attribution: '© <a href="https://www.mapbox.com/about/maps/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> <strong><a href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a></strong>',
      id: 'mapbox/light-v10',
      accessToken: 'pk.eyJ1IjoicmVlZHVvZnQiLCJhIjoiY2l6aWpiODQ2MDE2NjJ4b2RwZ3MyODl6byJ9.A67HGpPtAeCayuReK1ahtA'
    });
  let roads = L.tileLayer(getREEDLayerURL('EREED_gis_roads'));
  let london_roads = L.tileLayer(getREEDLayerURL('EREED_gis_roads_wlabels_Z8-18'));
  let symbols = L.tileLayer(getREEDLayerURL('EREED_places_geojson_points'));
  let labels = L.tileLayer(getREEDLayerURL('EREED_places_geojson_labels'));
  let dioceses_pre = L.tileLayer(getREEDLayerURL('EREED_gis_dioceses_pre1541'));
  let dioceses_post = L.tileLayer(getREEDLayerURL('EREED_gis_dioceses_post1541'));

  let baseLayers = {
    'REED coverage by county': county_coverage,
    'REED relief map': relief,
    'OpenStreetMap (Mapbox)': osm
  };
  let overlays = {
    'Pre-1642 roads': roads,
    'Detailed roads in London area': london_roads,
    'EREED Place symbols': symbols,
    'EREED Place labels': labels,
    'Historical dioceses before 1541': dioceses_pre,
    'Historical dioceses 1541 and after': dioceses_post
  };

  // Set initially active layers.
  county_coverage.addTo(map);
  roads.addTo(map);
  symbols.addTo(map);
  labels.addTo(map);

  L.control.layers(baseLayers, overlays).addTo(map);
}


/**
 * Zoom to the region if there is one, otherwise to the best fit for
 * the related markers.
 *
 * This overrides initial zoom extent.
 *
 * @param {Map} map - map to fit bounds on
 * @param {Layer} regionLayer - layer showing the source region
 * @param {Layer} relatedLayer - layer showing sources of related records
 */
function fitBounds(map, regionLayer, relatedLayer) {
  let zoom = 12;
  if (source_region_geojson.length > 0) {
    map.fitBounds(regionLayer.getBounds());
  } else if (related_location_geojson.length > 0) {
    map.fitBounds(relatedLayer.getBounds(), {maxZoom: zoom});
  } else if (source_location_geojson.length > 0) {
    let coordinates = swapCoordinates(
      source_location_geojson[0].features[0].geometry.coordinates);
    map.setView(coordinates, zoom);
  }
}


/**
 * Return the parameterised URL for the specified set of map tiles
 * hosted by the REED project.
 *
 * @param {String} name - name of map tile set
 * @returns {String}
 */
function getREEDLayerURL(name) {
  return 'https://library2.utm.utoronto.ca/tileserver/' + name + '/{z}/{x}/{-y}.png';
}


/**
 * Return the HTML content of the popup for the supplied feature, that
 * is the source of a related record.
 *
 * @param {Object} feature - GeoJSON map feature
 * @returns {String}
 */
function getRelatedPopupContent(feature) {
  return 'Location: <a href="' + feature.properties.eats_url +
    '">' + feature.properties.eats_name + '</a><br>Record: <a href="' +
    feature.properties.record_url + '">' + feature.properties.record_title
    + '</a>';
}


function hideLegend(baseImagePath) {
  let div = document.getElementById('info_legend')
  div.innerHTML = ('<br>' + '<img src="' + baseImagePath +
                   'legendicon.png" height="50" width="50">' + '<br>');
}


/**
 * Create the Leaflet map.
 */
function makeMap() {
  let initialZoom = 6;
  let minZoom = 6;
  let maxZoom = 16;
  let baseImagePath = '/assets/images/map/';

  let map = L.map('map', {
    center: [52.7, -1.77],
    maxBounds: [[46.5, -20.5], [62.0, 7.0]],
    maxZoom: maxZoom,
    minZoom: minZoom,
    zoom: initialZoom
  });

  addTileLayers(map);
  addLegend(map, baseImagePath);
  L.control.scale({position: 'bottomleft', maxWidth: 100}).addTo(map);
  addSourceLayer(map, baseImagePath);
  let relatedLayer = addRelatedLayer(map, baseImagePath);
  let regionLayer = addRegionLayer(map);
  fitBounds(map, regionLayer, relatedLayer);
  return [map, relatedLayer, regionLayer];
}


function showLegend(baseImagePath) {
  let div = document.getElementById('info_legend');
  div.innerHTML = ('<br>' + '<img src="' + baseImagePath +
                   'legend.png" height="335" width="150">' + '<br>');
}


/**
 * Return the supplied coordinates with the values swapped (eg,
 * lat-long becomes long-lat).
 *
 * @param {Array} coordinates - coordinates to swap
 * @returns {Array}
 */
function swapCoordinates(coordinates) {
  return [coordinates[1], coordinates[0]]
}


var [map, relatedLayer, regionLayer] = makeMap();
