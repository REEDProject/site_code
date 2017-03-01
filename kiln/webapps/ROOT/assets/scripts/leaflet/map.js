function getRelatedPopupContent(feature) {
    /* Returns the HTML content of the popup for the supplied feature,
     * that is a the source of a related record. */
    var content = 'Location: <a href="' + feature.properties.eats_url +
        '">' + feature.properties.eats_name + '</a><br>Record: <a href="' +
        feature.properties.record_url + '">' + feature.properties.record_title
        + '</a>';
    if (feature.properties.LOC_NAME != feature.properties.LABELS) {
        content = 'Site: ' + feature.properties.LABELS + '<br>' + content;
    }
    return content;
}

var map_image_path = '/assets/images/map/';

var map = L.map('map', {
    center: [52.7, -1.77],
    maxBounds: [[46.5, -20.5], [62.0, 7.0]],
    zoom: 6
});
map.options.minZoom = 6;
map.options.maxZoom = 15;

// Tile layers, base layers underneath with controls
var tms_EREEDcoverage = L.tileLayer(
    'http://talus.geog.utoronto.ca/1.0.0/EREED_gis_counties_base/{z}/{x}/{-y}.png', {
        maxZoom: 15,
        attribution: '<a href="http://reed.utoronto.ca/">Records of Early English Drama</a>'
    }).addTo(map);

var tms_REEDgisrelief = L.tileLayer('http://talus.geog.utoronto.ca/1.0.0/REED_gis_relief/{z}/{x}/{-y}.png');

var OSM_Mapbox = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoicmVlZHVvZnQiLCJhIjoiY2l6aWpiODQ2MDE2NjJ4b2RwZ3MyODl6byJ9.A67HGpPtAeCayuReK1ahtA', {
    maxZoom: 15,
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    id: 'mapbox.streets'
});

// Tile layers for overlays on top

var tms_REEDroads = L.tileLayer('http://talus.geog.utoronto.ca/1.0.0/REED_gis_roads/{z}/{x}/{-y}.png').addTo(map);
var tms_EREEDallplaces = L.tileLayer('http://talus.geog.utoronto.ca/1.0.0/EREED_gis_places_points/{z}/{x}/{-y}.png').addTo(map);
var tms_EREEDplaceslabels = L.tileLayer('http://talus.geog.utoronto.ca/1.0.0/EREED_gis_places_labels/{z}/{x}/{-y}.png').addTo(map);

// Layer controls
var baselayers = {
    'EREED coverage by county': tms_EREEDcoverage,
    'REED relief map': tms_REEDgisrelief,
    'Openstreetmap (Mapbox)': OSM_Mapbox
};

var overlays = {
    'Pre-1642 roads': tms_REEDroads,
    'EREED Place symbols': tms_EREEDallplaces,
    'EREED Place labels': tms_EREEDplaceslabels
};

L.control.layers(baselayers, overlays).addTo(map);
L.control.scale({position: 'bottomleft', maxWidth: 100}).addTo(map);

var legend = L.control({position: 'bottomright'});

function showLegend() {
    var div = document.getElementById('info_legend');
    div.innerHTML = ('<br>' + '<img src="' + map_image_path +
                     'legend.png" height="341" width="150">' + '<br>');
}

function hideLegend() {
    var div = document.getElementById('info_legend')
    div.innerHTML = ('<br>' + '<img src="' + map_image_path +
                     'legendicon.png" height="50" width="50">' + '<br>');
}

legend.onAdd = function(map) {
    var div = L.DomUtil.create('div', 'info_legend');
    div.innerHTML = ('<br>' + '<img src="' + map_image_path +
                     'legendicon.png"  height="50" width="50">' + '<br>');
    div.setAttribute('onmouseenter', 'showLegend()');
    div.setAttribute('onclick', 'hideLegend()');
    div.setAttribute('onmouseleave', 'hideLegend()');
    div.id = 'info_legend';
    return div;
};
legend.addTo(map);


//  Defining an icon to use as the default icon for each RELATED point
//  when not included in a MARKERCLUSTER
//  Added below in pointToLayer statement
var related_location_Icon = L.icon({
    iconUrl: map_image_path + 'REED_circle_red_10.png',
    iconSize: [10, 10],
    iconAnchor: [5, 5],
    popupAnchor: [0, -5]
});
//  Defining an icon to use as the default icon for single SOURCE point
var source_location_Icon = L.icon({
    iconUrl: map_image_path + 'Yellow-Hollow-22.png',
    iconSize: [22, 22],
    iconAnchor: [11, 11],
    popupAnchor: [0, -11]
});

//  THIS SECTION INITIALIZES THE THREE LAYERS TO BE POPULATED BY
//  GEOJSON LATER VIA ADDDATA STATEMENTS

// This activates the Leaflet.Markercluster plugin for use with lots
// of markers (related points)
var related_markers = L.markerClusterGroup({
    maxClusterRadius: 20,
    showCoverageOnHover: true,
    zoomToBoundsOnClick: true,
    polygonOptions: {color: '#03f', weight: 2, opacity: 0.5},
    spiderfyOnMaxZoom: true,
    spiderfyDistanceMultiplier: 0.4,
    spiderLegPolylineOptions: {weight: 1.5, color: '#B3B3B3', opacity: 0.6}
});

// Used this to initialize RELATED POINTS layer without any geoJson
// data, use addData below
var related_geoJsonLayer = L.Proj.geoJson(null, {
    // ADDED pointToLayer in this form and it worked to replace
    // default icon
    pointToLayer: function(feature, latlng) {
        return L.marker(latlng, {icon: related_location_Icon})
    },
    onEachFeature: function(feature, layer) {
        layer.bindPopup(getRelatedPopupContent(feature));
    }
});

// Used this to initialize SOURCE POINT layer without any geoJson
// data, use addData below
var source_geoJsonLayer = L.Proj.geoJson(null, {
    // ADDED pointToLayer in this form and it worked to replace
    // default icon
    pointToLayer: function(feature, latlng) {
        return L.marker(latlng, {icon: source_location_Icon,
                                 zIndexOffset: 1000, interactive: false})
    },
});

// Used this to initialize SOURCE REGION layer without any geoJson
// data, use addData below
var region_geoJsonLayer = L.Proj.geoJson(null, {
    style: function(feature) {
        return {color: 'yellow', opacity: 0.7, fillColor: 'yellow',
                fillOpacity: 0.3 };
    },
    onEachFeature: function(feature, layer) {
        var popupContent;
        if (feature.properties && feature.properties.regiontype) {
            var popupContent = 'Source Region: ' + feature.properties.NAME +
                '<br>Region Type: ' + feature.properties.regiontype;
        }
        layer.bindPopup(popupContent);
    }
});

related_geoJsonLayer.addData(related_location_geojson);
related_markers.addLayer(related_geoJsonLayer);
map.addLayer(related_markers);
// This overrides initial zoom extent set at top in L.map
map.fitBounds(related_markers.getBounds(), {maxZoom: 12});

source_geoJsonLayer.addData(source_location_geojson);
map.addLayer(source_geoJsonLayer);

region_geoJsonLayer.addData(source_region_geojson);
map.addLayer(region_geoJsonLayer);

// Uncomment and this should work to zoom to selected region, if we
// want to do that
//map.fitBounds(region_geoJsonLayer.getBounds());
