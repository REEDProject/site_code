import io
import json
import os.path
import zipfile

from django.core.serializers import serialize
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, render
from django.urls import reverse
from lxml import etree

from .models import Place


KILN_PLACES_FILENAME = 'geojson.xml'

XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace'
XML = '{%s}' % XML_NAMESPACE
BASE_JS = '''var source_region_geojson = [{
"type":"FeatureCollection"
,"crs":{"type":"name","properties":{"name":"EPSG:3857"}}
,"features":[
%s
]}];'''


def _assemble_xml(places, regions):
    root = etree.Element('geodata')
    features = etree.SubElement(root, 'features')
    _convert_geojson_to_xml(features, places, True)
    _convert_geojson_to_xml(features, regions, False)
    output = etree.tostring(root, encoding='unicode', pretty_print=True)
    return _tidy_xml(output)


def _convert_geojson_to_js(geo_data, zip_file):
    """Put each region in `geo_data` into a separate file within
    `zip_file`."""
    for item in geo_data['features']:
        feature_id = item['properties']['pk']
        filename = os.path.join('regions', '{}.js'.format(feature_id))
        zip_file.writestr(filename, BASE_JS % json.dumps(item))


def _convert_geojson_to_xml(element, geo_data, output):
    """Convert GeoJSON data into XML so that it can later be manipulated
    by XSLT within Kiln (which has access to the EATS data)."""
    for item in geo_data['features']:
        feature = etree.SubElement(element, 'feature')
        feature.set(XML + 'id', item['properties']['pk'])
        feature.set('type', item['geometry']['type'])
        if output:
            # Add in placeholders for material to be added during Kiln
            # processing.
            item['properties']['eats_name'] = 'EATS_NAME'
            item['properties']['eats_url'] = 'EATS_URL'
            item['properties']['record_title'] = 'RECORD_TITLE'
            item['properties']['record_url'] = 'RECORD_URL'
            feature.text = json.dumps(item)


def place_detail(request, pk):
    place = get_object_or_404(Place, pk=pk)
    return _serialise_as_geojson([place])


def _serialise_as_geojson(queryset):
    geojson = serialize('geojson', queryset)
    return HttpResponse(geojson, content_type='application/json')


def serialise_all_with_placeholders(request):
    context = {
        'places_url': reverse('geomap:serialise_points'),
        'regions_url': reverse('geomap:serialise_regions'),
    }
    if request.method == 'POST':
        try:
            points = Place.objects.extra(
                where=["GeometryType(coordinates) = 'POINT'"])
            points_geojson = json.loads(serialize('geojson', points))
            regions = Place.objects.extra(
                where=["GeometryType(coordinates) != 'POINT'"])
            regions_geojson = json.loads(serialize('geojson', regions))
            xml = _assemble_xml(points_geojson, regions_geojson)
            archive = io.BytesIO()
            with zipfile.ZipFile(archive, 'w') as zip_file:
                zip_file.writestr(KILN_PLACES_FILENAME, xml.encode('utf-8'))
                _convert_geojson_to_js(regions_geojson, zip_file)
            return HttpResponse(archive.getvalue(),
                                content_type='application/zip')
        except Exception as e:
            context['error'] = str(e)
            raise e
    return render(request, 'geomap/serialise_all_with_placeholders.html',
                  context)


def serialise_points(request):
    """Serialise all of the point places as GeoJSON."""
    # It would be extremely useful if the serialiser could allow
    # non-field attributes to be serialised, so as to allow for
    # serialising the computer co-ordinates for unlocated places. See
    # https://code.djangoproject.com/ticket/5711
    places = Place.objects.extra(where=["GeometryType(coordinates) = 'POINT'"])
    return _serialise_as_geojson(places)


def serialise_regions(request):
    """Serialise all of the regions as GeoJSON."""
    regions = Place.objects.extra(
        where=["GeometryType(coordinates) != 'POINT'"])
    return _serialise_as_geojson(regions)


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
