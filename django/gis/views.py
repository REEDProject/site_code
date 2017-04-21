"""Fetches GIS data from the OTRA GeoJson server, converts it into the
forms and files required by the REED Online site, and returns a ZIP
file containing those files."""


import io
import json
import os.path
import zipfile

from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render

from lxml import etree
import requests


PLACES_GEOJSON_URL = 'http://otrageojson.library.utoronto.ca/index.php/GeoJSON/places'
REGIONS_GEOJSON_URL = 'http://otrageojson.library.utoronto.ca/index.php/GeoJSON/county_mapcodes'

KILN_PLACES_FILENAME = 'geojson.xml'

XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace'
XML = '{%s}' % XML_NAMESPACE
BASE_JS = '''var source_region_geojson = [{
"type":"FeatureCollection"
,"crs":{"type":"name","properties":{"name":"EPSG:3857"}}
,"features":[
%s
]}];'''


@login_required
def fetch_geojson(request):
    """Fetch GeoJSON data and convert it to a Kiln-usable form."""
    context = {'places_url': PLACES_GEOJSON_URL,
               'regions_url': REGIONS_GEOJSON_URL}
    if request.method == 'POST':
        try:
            places_geo_data = _get_geo_data(PLACES_GEOJSON_URL)
            regions_geo_data = _get_geo_data(REGIONS_GEOJSON_URL)
            xml = _assemble_xml(places_geo_data, regions_geo_data)
            archive = io.BytesIO()
            with zipfile.ZipFile(archive, 'w') as zip_file:
                zip_file.writestr(KILN_PLACES_FILENAME, xml.encode('utf-8'))
                _convert_geojson_to_js(regions_geo_data, zip_file)
            return HttpResponse(archive.getvalue(),
                                content_type='application/zip')
        except Exception as e:
            context['error'] = str(e)
    return render(request, 'gis/fetch_geojson.html', context)


def _assemble_xml(places_geo_data, regions_geo_data):
    root = etree.Element('geodata')
    features = etree.SubElement(root, 'features')
    _convert_geojson_to_xml(features, places_geo_data, True)
    _convert_geojson_to_xml(features, regions_geo_data, False)
    output = etree.tostring(root, encoding='unicode', pretty_print=True)
    return _tidy_xml(output)


def _convert_geojson_to_js(geo_data, zip_file):
    """Put each region in `geo_data` into a separate file within
    `zip_file`."""
    for item in geo_data['features']:
        feature_id = item['properties']['Mapcode_Ar']
        filename = os.path.join('regions', '{}.js'.format(feature_id))
        zip_file.writestr(filename, BASE_JS % json.dumps(item))


def _convert_geojson_to_xml(element, geo_data, output):
    """Convert GeoJSON data into XML so that it can later be manipulated
    by XSLT within Kiln (which has access to the EATS data)."""
    for item in geo_data['features']:
        feature = etree.SubElement(element, 'feature')
        # Every feature should have a Mapcode_Ar, but for points that
        # is the ID of the containing region, not the feature itself.
        if 'Mapcode_pt' in item['properties']:
            feature.set(XML + 'id', item['properties']['Mapcode_pt'])
        else:
            feature.set(XML + 'id', item['properties']['Mapcode_Ar'])
        feature.set('type', item['geometry']['type'])
        if output:
            # Add in placeholders for material to be added during Kiln
            # processing.
            item['properties']['eats_name'] = 'EATS_NAME'
            item['properties']['eats_url'] = 'EATS_URL'
            item['properties']['record_title'] = 'RECORD_TITLE'
            item['properties']['record_url'] = 'RECORD_URL'
            feature.text = json.dumps(item)


def _get_geo_data(url):
    """Fetch data from `url` and return it as a JSON object."""
    r = requests.get(url, params={'dataset': 'reed'})
    return json.loads(r.text)


def _tidy_xml(xml_string):
    """Return `xml_string` with placeholder strings replaced with empty
    elements, for later XSLT processing.

    This is ugly but safe, and much simpler than trying to insert
    these empty elements during the lxml processing.

    """
    output = xml_string.replace('EATS_NAME', '<eats_name/>')
    output = output.replace('EATS_URL', '<eats_url/>')
    output = output.replace('RECORD_TITLE', '<record_title/>')
    output = output.replace('RECORD_URL', '<record_url/>')
    return output
