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

//django.jQuery.getJSON(geoJsonUrl, function (json) {
//    geoData = json;
//});

django.jQuery(window).on('map:init', function (e) {
    var detail = e.originalEvent ? e.originalEvent.detail : e.detail;
    L.geoJson(geoData, {
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng, geojsonMarkerOptions);
        },
        onEachFeature: onEachFeature
    }).addTo(detail.map);
});
