filter_types = {
  "time_period": "Date Range",
  "category": "Category"
}

initial_extent = {
  zoom: 14, // Start zoom level
  center: [51.505, -0.09] // Center of view
}

/**
 * Class describing an abstracted version of a point feature for
 * Leaflet which allows for zoom-dependent radii
 */
class PointFeature {
  // The zoom thresholds and radius scales are set here.
  // If the zoom level is between the (i)th and (i+1)th element
  // of the zoomThresholds list, then the radius will be the
  // (i)th element of the radiusScales list.
  zoomThresholds = [0, 10, 12, 14, 15, 16, 17];
  radiusScales = [8, 9, 10, 11, 12, 13, 14];

  // This is where you set all of the rest of the style information
  // for the default and highlighted point styles (the points are
  // symbolized by circles)
  style = {
    default: {
      weight: 3,
      opacity: 0.8,
      color: "#3ac335",
      fillOpacity: 0.2,
    },
    highlight: {
      weight: 4,
      opacity: 1,
      // color: "#fff41b",
      color: "#008281",
      fillOpacity: 0.1
    }
  }

  /**
   *
   * @param {*} map The Leaflet map object which the points are contained within
   * @param {*} id The ID of the given point
   * @param {*} latlng The location of the point given in L.LatLng format
   */
  constructor(map, id, latlng) {
    this.map = map;
    this.id = id;
    this._highlight = false;
    this.zoom = this.map.getZoom();
    this.feature = L.marker(latlng, { icon: this.icon });
    // We continually update the map zoom
    this.map.on('zoomend', () => { this.zoom = this.map.getZoom(); });

    // For some reason markers in Leaflet have a "mouseover" event
    // which is called continuously while the mouse hovers over the
    // feature, which is why we use this strange structure.
    this.feature.once('mouseover', this.mouseOver.bind(this));
    this.feature.on('mouseout', function () {
      this.mouseOut();
      this.feature.once('mouseover', this.mouseOver.bind(this));
    }.bind(this));
    this.feature.on('click', this.click.bind(this));

    // This is where we bind the events for the list items with
    // the name of a given region to the corresponding region on the map.
    $(`#${this.id}`).on('mouseenter', this.mouseOver.bind(this));
    $(`#${this.id}`).on('mouseleave', this.mouseOut.bind(this));
    $(`#${this.id}`).on('click', this.click.bind(this));
  }

  mouseOver() {
    this.highlight = true;
    $(`#${this.id}`).addClass('feature-item-hover');
  }

  mouseOut() {
    this.highlight = false;
    $(`#${this.id}`).removeClass('feature-item-hover');
  }

  click() {
    this.zoomTo();
  }

  redraw() {
    this.feature.setIcon(this.icon);
  }

  zoomTo() {
    // We wrap the marker into a group layer so that we can use
    // the flyToBounds
    const featureGroup = L.featureGroup().addLayer(this.feature);
    this.map.flyToBounds(featureGroup.getBounds());
  }

  get zoomThresholdIndex() {
    return this._zoomThresholdIndex;
  }

  set zoomThresholdIndex(val) {
    if (this._zoomThresholdIndex == null) {
      this._zoomThresholdIndex = val;
    } else if (val != this._zoomThresholdIndex) {
      this._zoomThresholdIndex = val;
      // We only update the map if the zoom threshold has changed
      this.redraw();
    }
  }

  get zoom() {
    return this._zoom;
  }

  set zoom(val) {
    this._zoom = val;
    let newThreshold = this.zoomThresholds.length - 1;
    for (var i = 0; i < this.zoomThresholds.length; i++) {
      if (val < this.zoomThresholds[i]) {
        newThreshold = i - 1;
        break;
      }
    }
    // Whenever the zoom changes, we update the zoom threshold
    this.zoomThresholdIndex = newThreshold;
  }

  get radius() {
    return this.radiusScales[this.zoomThresholdIndex];
  }

  get icon() {
    // We create a circle icon manually using the "divIcon" object;
    // this way, we're able to set the "iconAnchor" property, which
    // stops the marker from jumping around as we zoom
    const style = this.highlight ? this.style.highlight : this.style.default;

    const divStyle = `
            width: ${this.radius * 2}px;
            height: ${this.radius * 2}px;
            border-radius: ${this.radius + style.weight * 4}px;
            background: ${style.color}${(style.fillOpacity * 255).toString(16)};
            border: ${style.weight}px solid ${style.color};
        `;
    const html = `<div style="${divStyle}"></div> `;
    const icon = new L.divIcon({ html: html, className: '', iconAnchor: [this.radius, this.radius] });
    return icon;
  }

  get highlight() {
    return this._highlight;
  }

  set highlight(val) {
    this._highlight = val;
    // If the highlight property is set to true, then we redraw
    // the icon with a highlighted icon
    this.redraw();
  }
}

/**
 * Class describing an abstracted version of a polygon feature for Leaflet
 */
class PolygonFeature {
  // This is where you set all of the rest of the style information
  // for the default and highlighted polygon styles
  style = {
    default: {
      weight: 3,
      opacity: 0.8,
      color: "#3ac335",
      fillOpacity: 0.2
    },
    highlight: {
      weight: 4,
      opacity: 1,
      color: "#008281",
      fillOpacity: 0.1
    }
  }

  /**
   *
   * @param {*} map The Leaflet map object which the polygons are contained within
   * @param {*} id The ID of the given point
   * @param {*} latlng The location of the point given in L.LatLng format
   */
  constructor(map, id, layer) {
    this.map = map;
    this.id = id;
    this._highlight = false;
    this.layer = layer;
    this.feature = layer.feature;
    this.redraw();

    this.layer.on({
      mouseover: this.mouseOver.bind(this),
      mouseout: this.mouseOut.bind(this),
      click: this.click.bind(this)
    });

    // This is where we bind the events for the list items with
    // the name of a given region to the corresponding region on the map.
    $(`#${this.id}`).on('mouseenter', this.mouseOver.bind(this));
    $(`#${this.id}`).on('mouseleave', this.mouseOut.bind(this));
    $(`#${this.id}`).on('click', this.click.bind(this));
  }

  mouseOver() {
    this.highlight = true;
    $(`#${this.id}`).addClass('feature-item-hover');
  }

  mouseOut() {
    this.highlight = false;
    $(`#${this.id}`).removeClass('feature-item-hover');
  }

  click() {
    this.zoomTo();
  }

  redraw() {
    this.layer.setStyle(this.layerStyle);
  }

  zoomTo() {
    this.map.flyToBounds(this.layer.getBounds());
  }

  get layerStyle() {
    return this.highlight ? this.style.highlight : this.style.default;
  }

  get highlight() {
    return this._highlight;
  }

  set highlight(val) {
    this._highlight = val;
    // If the highlight property is set to true, then we redraw
    // the icon with a highlighted icon
    this.redraw();
  }
}

/**
 * Creates the main map frame and loads in into a div element named "map"
 * @returns Returns the Leaflet map object
 */
function loadMap() {
  function getURL(name) {
    var urlRoot = 'http://talus.geog.utoronto.ca/1.0.0/';
    var urlSuffix = '/{z}/{x}/{-y}.png';
    return urlRoot + name + urlSuffix;
  }

  var grayscale = L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    id: 'mapbox/light-v9',
    tileSize: 512,
    zoomOffset: -1,
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ' +
      'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    accessToken: 'pk.eyJ1IjoicmVlZHVvZnQiLCJhIjoiY2l6aWpiODQ2MDE2NjJ4b2RwZ3MyODl6byJ9.A67HGpPtAeCayuReK1ahtA'
  });
  var counties = L.tileLayer(getURL('EREED_gis_counties_base_Z8-18'), {
    attribution: '<a href="http://reed.utoronto.ca/">REED Records of Early English Drama </a>'
  });

  var sewers = L.tileLayer(getURL('EREED_gis_Rose_sewersonly'));
  var liberties = L.tileLayer(getURL('EREED_gis_Rose_Liberties_purple'));
  var parishes = L.tileLayer(getURL('EREED_gis_Rose_Parishes_wlabels'));
  var roads = L.tileLayer(getURL('EREED_gis_roads_wlabels_Z8-18'));
  var points = L.tileLayer(getURL('EREED_places_geojson_points_Z8-18'));
  var labels = L.tileLayer(getURL('EREED_places_geojson_labels_Z8-18'));

  var baseLayers = {
    'EREED coverage by county': counties,
    'OpenStreetMap (Mapbox)': grayscale
  };

  var overlayLayers = {
    'Rose Collection place labels': labels,
    'Sewers near Rose Playhouse': sewers,
    'Southwark Manors and Liberties': liberties,
    'London area parishes': parishes,
    'Roads': roads,
  };

  var startLayers = [counties, parishes, labels, roads, points, sewers];

  var map = L.map('map', {
    center: initial_extent.center, // Center of view
    layers: startLayers, // Which layer we start on
    maxBounds: [
      [46.5, -20.5], // Longitude
      [62.0, 7.0] // Latitude
    ],
    zoom: initial_extent.zoom, // Start zoom level
    zoomSnap: 0.25, // What the zoom level snaps to on the map
    zoomDelta: 0.25, // How much the zoom button controls modify zoom
    wheelPxPerZoomLevel: 16 // How many wheel turns to change one zoom level
  });
  map.options.minZoom = 8; // Min zoom level
  map.options.maxZoom = 18; // Max zoom level

  // Add layer control
  L.control.layers(baseLayers, overlayLayers).addTo(map);

  // Individual layers which are not overlay layers need to be forced to the front
  points.bringToFront();

  // Add legend
  let legend = L.control({ position: 'bottomright' });
  let legendDiv = generateLegend();
  legend.onAdd = function () { return legendDiv; };
  legend.addTo(map);

  return map;
}

/**
 * Creates the legend element
 * @returns Returns an HTML element object containing the legend
 */
function generateLegend() {
  let legend = $('<div id="legend">');
  let collapsedLegend = $(`<img src="./images/map/legendicon.png" id="collapsedLegend" style="width: 50px;">`);
  let expandedLegend = $(`<img src="./images/map/legend.png" id="expandedLegend" style="width: 150px;">`);
  legend.html(collapsedLegend);

  legend.on('mouseenter', function () {
    legend.html(expandedLegend);
  });

  legend.on('mouseleave', function () {
    legend.html(collapsedLegend);
  });

  return legend.get(0);
}

function resetMap(regionsGroupLayer, map) {
  regionsGroupLayer.clearLayers();
  map.flyTo(initial_extent.center, initial_extent.zoom)
}

/**
 * Displays all of the requested event regions on the given map
 * @param {*} regionsGroupLayer A group layer which will contain the polygons/points associated with the given event
 * @param {*} regions The JSON object containing all of the regions
 * @param {*} regionIDs A list of the IDs for the regions we want to display
 * @param {*} map The Leaflet map object
 */
function displayEventRegions(regionsGroupLayer, events, eventID, map) {
  // Clear the old features
  regionsGroupLayer.clearLayers();
  regions = events[eventID].regions;

  var displayedRegions = L.geoJSON(regions, {
    // Points
    // This function will run once for every point it finds in the geoJSON
    pointToLayer: function (feature, latlng) {
      let pointFeature = new PointFeature(map, feature.properties.pk, latlng);
      return pointFeature.feature;
    },
    // Polygons
    // This function will run once _for every feature_ in the geoJSON
    onEachFeature: function (feature, layer) {
      if (feature.geometry.type != 'Point') { // We have to make sure the feature isn't a point
        let polygonFeature = new PolygonFeature(map, feature.properties.pk, layer);
      }
    }
  });
  displayedRegions.addTo(regionsGroupLayer);
  map.flyToBounds(displayedRegions.getBounds());
}

/**
 * Creates a list group element which has id "eventID" and is in "collapsed form"
 * @param {*} events The JSON object containing all of the events
 * @param {*} eventID The particular event ID
 * @returns
 */
function getEventRecord(events, eventID) {
  var event = events[eventID];
  let head;

  if (event.description) {
    head = event.description;
  } else {
    head = event.title;
  }

  return $(`
            <li id="${eventID}" class="event-collapsed">
                <a class="event">
                    <div class="date">${event.date.display}</div>
                    <div class="description">${head}</div>
                </a>
            </li>
        `);
}

/**
 * Creates a list group element which has id "eventID" and is in "expanded form"
 * @param {*} events The JSON object containing all of the events
 * @param {*} eventID The particular event ID
 * @returns
 */
function getExpandedEventRecord(events, eventID) {
  var event = events[eventID];
  var eventActive = $(`<div class="event active">`);

  // This determines the header and the subheader, respectively
  let head = event.description;

  eventActive.append(`
        <div class="date">${event.date.display}</div>
        <div class="description">${head}</div>
    `);

  // This element contains the map region list items which you can click to zoom to the given region
  var features = $(`<ul class="features">`);
  for (var feature of event.regions.features) {
    features.append(
      `<li>
                <a class="feature" id="${feature.properties.pk}">
                    ${feature.properties.name}
                </a>
            </li>`
    );
  }
  eventActive.append(features);

  // Zoom to full extent
  if (Object.keys(event.regions.features).length > 1) {
    eventActive.append('<a class="event-extent">Zoom to full extent.</a><br>');
  }

  // Event record
  if (event.record_id) {
    eventActive.append(
      `<a target="_blank" href="https://ereed.library.utoronto.ca/records/${event.record_id}/">
                See associated record.
            </a><br>`
    );
  }

  if (event.ereed_url) {
    eventActive.append(
      `<a target="_blank" href="${event.ereed_url}">
                See event entity page.
            </a><br>`
    );
  }

  eventExpanded = $(`<li class="event-expanded" id="${eventID}">`).append(eventActive);
  return eventExpanded;
}

/**
 * Collapses all event records
 * @param {*} events The JSON object containing all of the events
 */
function collapseAllEventRecords(events) {
  $('.event-expanded').each(function () {
    var eventID = $(this).attr('id');
    $(this).replaceWith(getEventRecord(events, eventID));
  });
}

/**
 * Expands the given event record
 * @param {*} events The JSON object containing all of the events
 * @param {*} eventID The particular event ID we want to expand
 */
function expandEventRecord(events, eventID) {
  $(`#${eventID} `).replaceWith(getExpandedEventRecord(events, eventID));
}

function collapseAllFilterButtons() {
  $('.filter_button.active').each(function () {
    const filterID = $(this).attr('id');
    $(this).replaceWith(getFilterButton(filterID, filter_types[filterID]));
  });
}

function getFilterButton(filterID, filterTitle) {
  return `<li class="filter_button" id="${filterID}"><a>${filterTitle}</a></li>`;
}

function getActiveFilterButton(filterID, filterTitle) {
  return `<li class="filter_button active" id="${filterID}"><div>${filterTitle}</div></li>`;
}

function getEventTab(eventCategory) {
  return `<li class="event_tab"><a>${eventCategory}</a></li>`;
}

function getActiveEventTab(eventCategory) {
  return `<li class="event_tab active"><div>${eventCategory}</div></li>`;
}

function collapseAllEventTabs() {
  $('.event_tab.active').each(function () {
    const eventTabText = $(this).children().first().text();
    $(this).replaceWith(getEventTab(eventTabText));
  });
}

function activateFilterButton(events, regionsGroupLayer, map, filterID) {
  resetMap(regionsGroupLayer, map);
  generateEvents(events, regionsGroupLayer, map);
  $(`#${filterID}`).replaceWith(getActiveFilterButton(filterID, filter_types[filterID]));
  eventCategories = getEventCategories(filterID);
  $('.event_tabs').empty();
  $('.event_tabs').append(getActiveEventTab('All Events'));
  for (eventName of eventCategories) {
    $('.event_tabs').append(getEventTab(eventName));
  }

  // Add click events to filter buttons
  $(document).off('click.tab');
  $(document).on('click.tab', '.event_tab:not(.active):not(:first-child)', function () {
    resetMap(regionsGroupLayer, map);
    collapseAllEventTabs();
    const eventTabText = $(this).children().first().text();
    $(this).replaceWith(getActiveEventTab(eventTabText));
    generateEvents(events, regionsGroupLayer, map, filterID, eventTabText);
  });
  $(document).off('click.cancel');
  $(document).on('click.cancel', '.event_tab:first-child', function () {
    collapseAllEventTabs();
    const eventTabText = $(this).children().first().text();
    $(this).replaceWith(getActiveEventTab(eventTabText));
    generateEvents(events, regionsGroupLayer, map);
    resetMap(regionsGroupLayer, map);
  });
}

function generateEvents(events, regionsGroupLayer, map, jsonFilter=null, jsonFilterValue=null) {
  // Add event records as list items using event database
  $('.events').empty();

  if (jsonFilter !== null) {
    events = Object.values(events).filter(event => event[jsonFilter] == jsonFilterValue);
  }

  for (eventID in events) {
    eventRecord = getEventRecord(events, eventID);
    $('.events').append(eventRecord);
  }

  // Add click events for each collapsed event record in list
  $(document).off('click.event');
  $(document).on('click.event', '.event-collapsed', function () {
    // Expand event record after collapsing old ones
    eventID = $(this).attr('id');
    collapseAllEventRecords(events);
    expandEventRecord(events, eventID);

    // Display regions on map
    displayEventRegions(regionsGroupLayer, events, eventID, map); // TODO
  });
}

function getEventCategories(filter_type) {
  event_categories = [];
  for (eventID in events) {
    event_category = events[eventID][filter_type];
    if (!event_categories.includes(event_category) && event_category != null) {
      event_categories.push(event_category);
    }
  }
  return event_categories;
}

/**
 * The main function which is ran when the page loads
 */
function main() {
  // We do not need AJAX in this setting as it doesn't speed things up
  // and makes it needlessly complicated
  $.ajaxSetup({ async: false });
  // Loads the base map and all of the respective layers
  const map = loadMap();

  // Load the event database as a JSON object
  // let events;
  $.getJSON(timelineJsonPath, function (root) { events = root; });
  // $.getJSON('data/ref/events-old_2.json', function (root) { events = root; });

  // Layer group that will contain the given event regions
  let regionsGroupLayer = L.featureGroup().addTo(map);

  // Load the events into the table
  generateEvents(events, regionsGroupLayer, map);

  // If there is more than one region in the given event,
  // then we add the .event-extent class to the title text
  // to allow us to zoom back to the extent of all the regions
  $(document).on('click', '.event-extent', function () {
    // Zoom to full extent of regions on map
    map.flyToBounds(regionsGroupLayer.getBounds());
  });

  // Generate filter buttons
  $('.filter_buttons').empty();
  for (filterID in filter_types) {
    filter_button = getFilterButton(filterID, filter_types[filterID]);
    $('.filter_buttons').append(filter_button);
  }
  activateFilterButton(events, regionsGroupLayer, map, Object.keys(filter_types)[0]);

  // Add click events to filter buttons
  $(document).on('click', '.filter_button:not(.active)', function () {
    filterID = $(this).attr('id');
    collapseAllFilterButtons();
    activateFilterButton(events, regionsGroupLayer, map, filterID);
  });


  // $('.filter_buttons').append(getFilterButton('filter_cancel', '&#10005;'))
  $('.event-expanded').each(function () {
    var eventID = $(this).attr('id');
    $(this).replaceWith(getEventRecord(events, eventID));
  });
}

// Run the "main" function when page is loaded
$(document).ready(main);
