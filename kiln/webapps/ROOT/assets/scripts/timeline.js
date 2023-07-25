/**
 * jQ is used in place of $, since this code requires a more recent
 * version of jQuery than the rest of the site uses.
 */

/**
 * Class describing an abstracted version of a point feature for Leaflet which allows for zoom-dependent radii
 */
class PointFeature {
    /**
     * The zoom thresholds and radius scales.
     * If the zoom level is between the (i)th and (i+1)th element of the zoomThresholds list,
     * then the radius will be the (i)th element of the radiusScales list.
     */
    zoomThresholds = [0, 10, 12, 14, 15, 16, 17];
    radiusScales = [8, 9, 10, 11, 12, 13, 14];

    /**
     * Style information for the default and highlighted point styles.
     * Points are symbolized by circles.
     */
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
            color: "#008281",
            fillOpacity: 0.1
        }
    }

    /**
     * Creates a new PointFeature instance.
     * @param {L.Map} map - The Leaflet map object which the points are contained within.
     * @param {string} id - The ID of the given point.
     * @param {L.LatLng} latlng - The location of the point given in L.LatLng format.
     */
    constructor(map, id, latlng) {
        this.map = map;
        this.id = id;
        this._highlight = false;
        this.zoom = this.map.getZoom();
        this.feature = L.marker(latlng, { icon: this.icon });
        // We continually update the map zoom property
        this.map.on('zoomend', () => {
            this.zoom = this.map.getZoom();
        });

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
        jQ(`#${this.id}`).on('mouseenter', this.mouseOver.bind(this));
        jQ(`#${this.id}`).on('mouseleave', this.mouseOut.bind(this));
        jQ(`#${this.id}`).on('click', this.click.bind(this));
    }

    /**
     * Handles the mouseover event.
     */
    mouseOver() {
        this.highlight = true;
        jQ(`#${this.id}`).addClass('feature-item-hover');
    }

    /**
     * Handles the mouseout event.
     */
    mouseOut() {
        this.highlight = false;
        jQ(`#${this.id}`).removeClass('feature-item-hover');
    }

    /**
     * Handles the click event.
     */
    click() {
        this.zoomTo();
    }


    /**
     * Redraws the feature icon.
     */
    redraw() {
        this.feature.setIcon(this.icon);
    }

    /**
     * Zooms to the feature.
     */
    zoomTo() {
        // We wrap the marker into a group layer so that we can use the flyToBounds
        const featureGroup = L.featureGroup().addLayer(this.feature);
        this.map.flyToBounds(featureGroup.getBounds());
    }

    /**
     * Returns the zoom threshold index.
     * @returns {number} - The zoom threshold index.
     */
    get zoomThresholdIndex() {
        return this._zoomThresholdIndex;
    }

    /**
     * Sets the zoom threshold index.
     * @param {number} val - The new zoom threshold index value.
     */
    set zoomThresholdIndex(val) {
        if (this._zoomThresholdIndex === undefined) {
            this._zoomThresholdIndex = val;
        } else if (val !== this._zoomThresholdIndex) {
            this._zoomThresholdIndex = val;
            this.redraw();
        }
    }

    /**
     * Returns the current zoom level.
     * @returns {number} - The current zoom level.
     */
    get zoom() {
        return this._zoom;
    }

    /**
     * Sets the current zoom level.
     * @param {number} val - The new zoom level value.
     */
    set zoom(val) {
        this._zoom = val;
        let newThreshold = this.zoomThresholds.length - 1;
        for (let i = 0; i < this.zoomThresholds.length; i++) {
            if (val < this.zoomThresholds[i]) {
                newThreshold = i - 1;
                break;
            }
        }
        this.zoomThresholdIndex = newThreshold;
    }

    /**
     * Returns the radius based on the current zoom threshold index.
     * @returns {number} - The radius value.
     */
    get radius() {
        return this.radiusScales[this.zoomThresholdIndex];
    }

    /**
     * Returns the icon for the feature.
     * @returns {L.DivIcon} - The feature icon.
     */
    get icon() {
        /**
         * We create a circle icon manually using the "divIcon" object;
         * this way, we're able to set the "iconAnchor" property, which
         * stops the marker from jumping around as we zoom 
         */
        const style = this.highlight ? this.style.highlight : this.style.default;
        const divStyle = `
            width: ${this.radius * 2}px;
            height: ${this.radius * 2}px;
            border-radius: ${this.radius + style.weight * 4}px;
            background: ${style.color}${(style.fillOpacity * 255).toString(16)};
            border: ${style.weight}px solid ${style.color};
        `;
        const html = `<div style="${divStyle}"></div> `;
        return new L.divIcon({ html: html, className: "", iconAnchor: [this.radius, this.radius] });
    }

    /**
     * Returns the highlight state of the feature.
     * @returns {boolean} - The highlight state.
     */
    get highlight() {
        return this._highlight;
    }

    /**
     * Sets the highlight state of the feature.
     * @param {boolean} val - The new highlight state value.
     */
    set highlight(val) {
        this._highlight = val;
        this.redraw();
    }
}

/**
 * Class describing an abstracted version of a polygon feature for Leaflet.
 */
class PolygonFeature {
    /**
     * Style information for the default and highlighted polygon styles.
     */
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
            color: "#008281",
            fillOpacity: 0.1,
        },
    };

    /**
     * Creates a new PolygonFeature instance.
     * @param {L.Map} map - The Leaflet map object which the polygons are contained within.
     * @param {string} id - The ID of the given polygon.
     * @param {L.Layer} layer - The polygon layer.
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
            click: this.click.bind(this),
        });

        jQ(`#${this.id}`).on("mouseenter", this.mouseOver.bind(this));
        jQ(`#${this.id}`).on("mouseleave", this.mouseOut.bind(this));
        jQ(`#${this.id}`).on("click", this.click.bind(this));
    }

    /**
     * Handles the mouseover event.
     */
    mouseOver() {
        this.highlight = true;
        jQ(`#${this.id}`).addClass("feature-item-hover");
    }

    /**
     * Handles the mouseout event.
     */
    mouseOut() {
        this.highlight = false;
        jQ(`#${this.id}`).removeClass("feature-item-hover");
    }

    /**
     * Handles the click event.
     */
    click() {
        this.zoomTo();
    }

    /**
     * Redraws the polygon layer with the appropriate style.
     */
    redraw() {
        this.layer.setStyle(this.layerStyle);
    }

    /**
     * Zooms to the polygon feature.
     */
    zoomTo() {
        this.map.flyToBounds(this.layer.getBounds());
    }

    /**
     * Returns the style for the polygon layer based on the highlight state.
     * @returns {Object} - The style object.
     */
    get layerStyle() {
        return this.highlight ? this.style.highlight : this.style.default;
    }

    /**
     * Returns the highlight state of the polygon feature.
     * @returns {boolean} - The highlight state.
     */
    get highlight() {
        return this._highlight;
    }

    /**
     * Sets the highlight state of the polygon feature.
     * @param {boolean} val - The new highlight state value.
     */
    set highlight(val) {
        this._highlight = val;
        this.redraw();
    }
}

/**
 * Creates the main map frame and loads it into a div element named "map".
 * @param {object} metadata - The metadata object containing configuration data.
 * @returns {L.map} The Leaflet map object.
 */
function loadMap(metadata) {
    // Extract basemap layers from metadata
    const basemapLayers = metadata['basemap_layers'];

    // Initialize objects to store base layers, overlay layers, and start layers
    const baseLayers = {};
    const overlayLayers = {};
    const startLayers = [];

    // Iterate over basemapLayers and extract layer information
    for (const [key, layer] of Object.entries(basemapLayers)) {
        const { url, options, is_base_layer, is_overlay_layer, is_start_layer } = layer;

        // Create a tile layer based on layer information
        const tileLayer = L.tileLayer(url, options);

        // Assign the tile layer to the corresponding layer category
        if (is_base_layer) {
            baseLayers[layer.label] = tileLayer;
        }

        if (is_overlay_layer) {
            overlayLayers[layer.label] = tileLayer;
        }

        if (is_start_layer) {
            startLayers.push(tileLayer);
        }
    }

    // Set up options for initializing the map
    const mapSetupOptions = {
        center: [metadata['initial_center_lat'], metadata['initial_center_long']],
        layers: startLayers,
        maxBounds: [
            [metadata['max_bound_lower_left_lat'], metadata['max_bound_lower_left_long']],
            [metadata['max_bound_upper_right_lat'], metadata['max_bound_upper_right_long']]
        ],
        zoom: metadata['initial_zoom'],
        zoomSnap: 0.25,
        zoomDelta: 0.25,
        wheelPxPerZoomLevel: 16,
        minZoom: metadata['min_zoom'],
        maxZoom: metadata['max_zoom']
    };

    // Create the Leaflet map object with the specified options
    const map = L.map('map', mapSetupOptions);

    // Add layer control for base and overlay layers
    L.control.layers(baseLayers, overlayLayers).addTo(map);

    // Bring start layers to the front
    startLayers.forEach((layer) => {
        layer.bringToFront();
    });

    // Add legend control to the bottom-right corner
    const legend = L.control({ position: 'bottomright' });
    const legendDiv = generateLegend(); // Custom function to generate the legend HTML
    legend.onAdd = () => legendDiv;
    legend.addTo(map);

    return map;
}

/**
 * Creates the legend element.
 * @returns {HTMLElement} The HTML element object containing the legend.
 */
function generateLegend() {
    const legend = jQ('<div id="legend">');
    const collapsedLegend = jQ('<img>').attr('src', '../images/map/legendIcon.png').css('width', '50px');
    const expandedLegend = jQ('<img>').attr('src', '../images/timeline-legend.png').css('width', '150px');
    legend.html(collapsedLegend);

    legend.on('mouseenter', function () {
        legend.html(expandedLegend);
    });

    legend.on('mouseleave', function () {
        legend.html(collapsedLegend);
    });

    return legend.get(0);
}

/**
 * Generates event records and adds them to the events container.
 * @param {Object} events - The event data.
 * @param {L.FeatureGroup} regionsGroupLayer - The layer group for event regions on the map.
 * @param {L.Map} map - The Leaflet map object.
 * @param {string|null} jsonFilter - The JSON filter key.
 * @param {string|null} jsonFilterValue - The JSON filter value.
 */
function generateEvents(events, regionsGroupLayer, map, jsonFilter = null, jsonFilterValue = null) {
    // Clear the events container
    jQ('.events').empty();

    // Apply JSON filter if provided
    if (jsonFilter !== null) {
        events = Object.values(events).filter(event => event[jsonFilter] == jsonFilterValue);
    }

    // Generate event records and append them to the events container
    for (const eventID in events) {
        const $eventRecord = getEventRecord(events, eventID);
        jQ('.events').append($eventRecord);
    }

    // Event handler for clicking a collapsed event record
    jQ(document).off('click.event');
    jQ(document).on('click.event', '.event-collapsed', function () {
        // Expand the clicked event record and collapse others
        const eventID = jQ(this).attr('id');
        collapseAllEventRecords(events);
        expandEventRecord(events, eventID);

        // Display event regions on the map
        displayEventRegions(regionsGroupLayer, events, eventID, map);
    });
}

/**
 * Creates a list group element in collapsed form for a specific event.
 * @param {Object} events - The JSON object containing all of the events.
 * @param {string} eventID - The ID of the particular event.
 * @returns {jQuery} - The jQuery object representing the event record.
 */
function getEventRecord(events, eventID) {
    const event = events[eventID];

    const $eventRecord = jQ('<li>', {
        id: eventID,
        class: 'event-collapsed',
    });

    const $eventLink = jQ('<a>', {
        class: 'event',
    }).appendTo($eventRecord);

    jQ('<div>', {
        class: 'date',
        text: event.date.display,
    }).appendTo($eventLink);

    jQ('<div>', {
        class: 'description',
        text: event.description,
    }).appendTo($eventLink);

    return $eventRecord;
}

/**
 * Collapses all event records
 * @param {Object} events - The JSON object containing all of the events
 */
function collapseAllEventRecords(events) {
    jQ('.event-expanded').each(function () {
        const eventID = jQ(this).attr('id');
        const eventRecord = getEventRecord(events, eventID);
        jQ(this).replaceWith(eventRecord);
    });
}

/**
 * Expands the given event record
 * @param {Object} events - The JSON object containing all of the events
 * @param {string} eventID - The particular event ID we want to expand
 */
function expandEventRecord(events, eventID) {
    const expandedEventRecord = getExpandedEventRecord(events, eventID);
    jQ(`#${eventID}`).replaceWith(expandedEventRecord);
}

/**
 * Creates a list group element which has id "eventID" and is in "expanded form"
 * @param {Object} events - The JSON object containing all of the events
 * @param {string} eventID - The particular event ID
 * @returns {jQuery} - The jQuery object representing the expanded event record
 */
function getExpandedEventRecord(events, eventID) {
    const event = events[eventID];

    const $eventExpanded = jQ('<li>', {
        class: 'event-expanded',
        id: eventID,
    });

    const $eventActive = jQ('<div>', {
        class: 'event active',
    }).appendTo($eventExpanded);

    jQ('<div>', {
        class: 'date',
        text: event.date.display,
    }).appendTo($eventActive);

    jQ('<div>', {
        class: 'description',
        text: event.description,
    }).appendTo($eventActive);

    const $features = jQ('<ul>', {
        class: 'features',
    }).appendTo($eventActive);

    for (const feature of event.regions.features) {
        jQ('<li>').append(
            jQ('<a>', {
                class: 'feature',
                id: feature.properties.pk,
                text: feature.properties.name,
            })
        ).appendTo($features);
    }

    if (Object.keys(event.regions.features).length > 1) {
        jQ('<a>', {
            class: 'event-extent',
            text: 'Zoom to full extent.',
        }).appendTo($eventActive);
        $eventActive.append('<br>'); // Add line break
    }

    if (event.record_url) {
        jQ('<a>', {
            target: '_blank',
            href: event.record_url,
            text: 'See associated record.',
        }).appendTo($eventActive);
        $eventActive.append('<br>'); // Add line break
    }

    if (event.ereed_url) {
        jQ('<a>', {
            target: '_blank',
            href: event.ereed_url,
            text: 'See event entity page.',
        }).appendTo($eventActive);
        $eventActive.append('<br>'); // Add line break
    }

    return $eventExpanded;
}

/**
 * Displays all of the requested event regions on the given map
 * @param {L.LayerGroup} regionsGroupLayer - A group layer which will contain the polygons/points associated with the given event
 * @param {Object} events - The JSON object containing all of the events
 * @param {string} eventID - The ID of the event
 * @param {L.Map} map - The Leaflet map object
 */
function displayEventRegions(regionsGroupLayer, events, eventID, map) {
    regionsGroupLayer.clearLayers();
    const regions = events[eventID].regions;

    const displayedRegions = L.geoJSON(regions, {
        pointToLayer: function (feature, latlng) {
            const pointFeature = new PointFeature(map, feature.properties.pk, latlng);
            return pointFeature.feature;
        },
        onEachFeature: function (feature, layer) {
            if (feature.geometry.type !== 'Point') {
                new PolygonFeature(map, feature.properties.pk, layer);
            }
        }
    });

    displayedRegions.addTo(regionsGroupLayer);
    map.flyToBounds(displayedRegions.getBounds());
}

/**
 * Creates a filter button element.
 * @param {string} filterID - The ID of the filter button.
 * @param {string} filterTitle - The title of the filter button.
 * @returns {jQuery} - The jQuery object representing the filter button element.
 */
function getFilterButton(filterID, filterTitle) {
    return jQ('<li>', {
        class: 'filter_button',
        id: filterID,
    }).append(
        jQ('<a>', {
            text: filterTitle,
        })
    );
}

/**
 * Activates the filter button and sets up event tabs.
 * @param {Object} events - The JSON object containing all of the events.
 * @param {L.LayerGroup} regionsGroupLayer - A group layer which contains the polygons/points associated with the events.
 * @param {L.Map} map - The Leaflet map object.
 * @param {string} filterID - The ID of the filter button.
 * @param {Object} filterTypes - An object mapping filter IDs to their types.
 * @param {{ zoom: number, center: [number, number] }} initialExtent - The initial map extent.
 */
function activateFilterButton(events, regionsGroupLayer, map, filterID, filterTypes, initialExtent) {
    // Reset the map and generate events
    resetMap(regionsGroupLayer, map, initialExtent);
    generateEvents(events, regionsGroupLayer, map);

    // Replace the clicked filter button with an active filter button
    jQ(`#${filterID}`).replaceWith(getActiveFilterButton(filterID, filterTypes[filterID]));

    // Get event categories and set up event tabs
    const eventCategories = getEventCategories(filterID, events);
    const $eventTabsContainer = jQ('.event_tabs');
    $eventTabsContainer.empty();
    $eventTabsContainer.append(getActiveEventTab('All Events'));

    for (const eventName of eventCategories) {
        $eventTabsContainer.append(getEventTab(eventName));
    }

    // Add click events to event tabs
    jQ(document).off('click.tab');
    jQ(document).on('click.tab', '.event_tab:not(.active):not(:first-child)', function () {
        // Reset the map, collapse event tabs, and generate events for the selected tab
        resetMap(regionsGroupLayer, map, initialExtent);
        collapseAllEventTabs();
        const eventTabText = jQ(this).children().first().text();
        jQ(this).replaceWith(getActiveEventTab(eventTabText));
        generateEvents(events, regionsGroupLayer, map, filterID, eventTabText);
    });

    jQ(document).off('click.cancel');
    jQ(document).on('click.cancel', '.event_tab:first-child', function () {
        // Collapse all event tabs, generate all events, and reset the map
        resetMap(regionsGroupLayer, map, initialExtent);
        collapseAllEventTabs();
        const eventTabText = jQ(this).children().first().text();
        jQ(this).replaceWith(getActiveEventTab(eventTabText));
        generateEvents(events, regionsGroupLayer, map);
    });
}

/**
 * Resets the map to the initial extent by clearing the regions group layer and flying to the initial center and zoom level.
 * @param {L.LayerGroup} regionsGroupLayer - The group layer containing the regions
 * @param {L.Map} map - The Leaflet map object
 * @param {{ zoom: number, center: [number, number] }} initialExtent - The initial map extent.
 */
function resetMap(regionsGroupLayer, map, initialExtent) {
    regionsGroupLayer.clearLayers();
    map.flyTo(initialExtent.center, initialExtent.zoom);
}

/**
 * Creates an active filter button element with the specified ID and title.
 * @param {string} filterID - The ID of the filter button
 * @param {string} filterTitle - The title of the filter button
 * @returns {jQuery} - The jQuery object representing the active filter button element
 */
function getActiveFilterButton(filterID, filterTitle) {
    return jQ('<li>', {
        class: 'filter_button active',
        id: filterID,
    }).append(jQ('<div>').text(filterTitle));
}

/**
 * Creates an event tab element with the specified event category.
 * @param {string} eventCategory - The event category for the tab
 * @returns {jQuery} - The jQuery object representing the event tab element
 */
function getEventTab(eventCategory) {
    return jQ('<li>', {
        class: 'event_tab',
    }).append(jQ('<a>').text(eventCategory));
}

/**
 * Creates an active event tab element with the specified event category.
 * @param {string} eventCategory - The event category for the tab
 * @returns {jQuery} - The jQuery object representing the active event tab element
 */
function getActiveEventTab(eventCategory) {
    return jQ('<li>', {
        class: 'event_tab active',
    }).append(jQ('<div>').text(eventCategory));
}

/**
 * Collapses all filter buttons by replacing active buttons with inactive buttons.
 * @param {Object} filterTypes - The filter types object
 */
function collapseAllFilterButtons(filterTypes) {
    jQ('.filter_button.active').each(function () {
        const filterID = jQ(this).attr('id');
        jQ(this).replaceWith(getFilterButton(filterID, filterTypes[filterID]));
    });
}

/**
 * Collapses all event tabs by replacing active tabs with inactive tabs.
 */
function collapseAllEventTabs() {
    jQ('.event_tab.active').each(function () {
        const eventTabText = jQ(this).children().first().text();
        jQ(this).replaceWith(getEventTab(eventTabText));
    });
}

/**
 * Retrieves unique event categories based on the specified filter type from the events object.
 * @param {string} filterType - The filter type
 * @param {Object} events - The events object
 * @returns {string[]} - An array of unique event categories
 */
function getEventCategories(filterType, events) {
    const eventCategories = [];
    for (const eventID in events) {
        const eventCategory = events[eventID][filterType];
        if (eventCategory && !eventCategories.includes(eventCategory)) {
            eventCategories.push(eventCategory);
        }
    }
    return eventCategories;
}

/**
 * The main function which runs when the page loads.
 * It retrieves timeline events and metadata asynchronously,
 * initializes the map, loads events into the table,
 * generates filter buttons, generates event tabs
 * and sets the page title.
 */
async function main() {
    // Retrieve timeline events asynchronously
    const events = await $.getJSON(timelineEventsPath);

    // Retrieve timeline metadata asynchronously
    const metadata = await $.getJSON(timelineMetadataPath);

    const { filters, initial_zoom, initial_center_lat, initial_center_long, title } = metadata;
    const initialExtent = {
        zoom: initial_zoom,
        center: [initial_center_lat, initial_center_long],
    };

    // Initialize the map
    const map = loadMap(metadata);
    const regionsGroupLayer = L.featureGroup().addTo(map);

    // Load events into the table and generate event records on the map
    generateEvents(events, regionsGroupLayer, map);

    // Event listener for clicking on "Zoom to Full Extent" button
    jQ(document).on('click', '.event-extent', function () {
        map.flyToBounds(regionsGroupLayer.getBounds());
    });

    // Generate filter buttons based on metadata
    jQ('.filter_buttons').empty();
    for (const [filterID, filterType] of Object.entries(filters)) {
        const $filterButton = getFilterButton(filterID, filterType);
        jQ('.filter_buttons').append($filterButton);
    }

    // Activate the initial filter button and handle filter button clicks
    activateFilterButton(events, regionsGroupLayer, map, Object.keys(filters)[0], filters, initialExtent);

    jQ(document).on('click', '.filter_button:not(.active)', function () {
        const filterID = jQ(this).attr('id');
        collapseAllFilterButtons(filters);
        activateFilterButton(events, regionsGroupLayer, map, filterID, filters, initialExtent);
    });

    // Update the title of the page
    jQ('.event_title').text(title);
    document.title = title;
}

// Run the "main" function when page is loaded
jQ(document).ready(main);
