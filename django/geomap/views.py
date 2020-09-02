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
,"crs":{"type":"name","properties":{"name":"EPSG:4326"}}
,"features":[
%s
]}];'''


def _assemble_xml(places, regions):
    root = etree.Element('geodata')
    features = etree.SubElement(root, 'features')
    _convert_geojson_to_xml(features, places, 'Point')
    _convert_geojson_to_xml(features, regions, 'Region')
    output = etree.tostring(root, encoding='unicode', pretty_print=True)
    return _tidy_xml(output)


def _convert_geojson_to_js(geo_data, zip_file):
    """Put each region in `geo_data` into a separate file within
    `zip_file`."""
    for item in geo_data['features']:
        feature_id = item['properties']['pk']
        filename = os.path.join('regions', '{}.js'.format(feature_id))
        zip_file.writestr(filename, BASE_JS % json.dumps(item))


def _convert_geojson_to_xml(element, geo_data, place_type):
    """Convert GeoJSON data into XML so that it can later be manipulated
    by XSLT within Kiln (which has access to the EATS data)."""
    for item in geo_data['features']:
        if item.get('geometry') is None:
            continue
        feature = etree.SubElement(element, 'feature')
        feature.set(XML + 'id', 'id-{}'.format(item['properties']['pk']))
        feature.set('type', place_type)
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
    geojson = serialize('geojson_reed', queryset,
                        use_natural_foreign_keys=True)
    return HttpResponse(geojson, content_type='application/json')


def serialise_all_with_placeholders(request):
    context = {
        'places_url': reverse('geomap:serialise_points'),
        'regions_url': reverse('geomap:serialise_regions'),
    }
    try:
        points = Place.objects.extra(
            where=["GeometryType(coordinates) = 'POINT'"])
        points_geojson = json.loads(serialize(
            'geojson_reed', points, use_natural_foreign_keys=True))
        regions = Place.objects.extra(
            where=["GeometryType(coordinates) != 'POINT'"])
        # We need to include regions with point placeholder
        # coordinates in the generated geojson/XML file.
        fields = ('name', 'place_type', 'container', 'placeholder_coordinates',
                  'patrons_label_flag', 'symbol_flag', 'is_approximate',
                  'notes', 'pk')
        regions_as_points_geojson = json.loads(
            serialize('geojson', regions,
                      fields=fields, geometry_field='placeholder_coordinates',
                      use_natural_foreign_keys=True))
        regions_geojson = json.loads(serialize('geojson', regions,
                                               use_natural_foreign_keys=True))
        xml = _assemble_xml(points_geojson, regions_as_points_geojson)
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
    places = Place.objects.extra(
        where=["GeometryType(coordinates) = 'POINT'"]).order_by(
            'patrons_label_flag', 'place_type__tile_order')
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
