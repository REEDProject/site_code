var geojsonMarkerOptions = {
    radius: 4,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

function onEachFeature(feature, layer) {
    layer.bindTooltip(feature.properties.name).openTooltip();
}

var initialisedMaps = [];

django.jQuery(window).on('map:init', function (e) {
    var detail = e.originalEvent ? e.originalEvent.detail : e.detail;
    var map = detail.map;
    // map:init is sent multiple times for each map (perhaps as many
    // times for each as there are maps?), so to avoid both having
    // multiple co-ordinate display boxes and also doing extra work,
    // keep track of which maps have already been initialised.
    if (initialisedMaps.indexOf(map._containerId) < 0) {
        L.geoJson(geoData, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerOptions);
            },
            onEachFeature: onEachFeature
        }).addTo(map);
        L.control.mouseCoordinate({gpsLong:false}).addTo(map);
        initialisedMaps.push(map._containerId);
    }
});
