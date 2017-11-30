import json

from django.core.management.base import BaseCommand, CommandError
from django.contrib.gis.geos import GEOSGeometry
from django.db import transaction

from ...models import Place, PatronsPlaceType
from ... import constants


POINTS_FILE = 'places.json'
REGIONS_FILE = 'regions.json'


class Command(BaseCommand):

    help = 'Import GeoJSON data'

    def handle(self, *args, **options):
        with transaction.atomic():
            self._city_type = self._create_place_type('city-county')
            self._county_type = self._create_place_type('county')
            self._dependency_type = self._create_place_type('crown dependency')
            self._import_regions()
            self._import_points()

    def _create_place_type(self, name):
        place_type = PatronsPlaceType(name=name)
        place_type.save()
        return place_type

    def _fix_container_name(self, feature):
        name = feature['properties']['COUNTY']
        if name == 'Bristol (city-county) in Gloucestershire':
            name = 'Bristol'
        elif name == 'Coventry (city-county) in Warwickshire':
            name = 'Coventry'
        elif name == 'Exeter (city-county) in Devon':
            name = 'Exeter'
        elif name == 'London (city-county)':
            name = 'London'
        elif name == 'Newcastle upon Tyne (city-county) in Northumberland':
            name = 'Newcastle upon Tyne'
        elif name == 'Norwich (city-county) in Norfolk':
            name = 'Norwich'
        elif name == 'Southampton (city-county) in Hampshire':
            name = 'Southampton'
        elif name == 'York (city-county) in Yorkshire':
            name = 'York'
        elif name == 'Yorkshire North Riding':
            name = 'Yorkshire: North Riding'
        elif name == 'Yorkshire West Riding':
            name = 'Yorkshire: West Riding'
        return name

    def _fix_region_name(self, feature):
        name = feature['properties']['NAME']
        if name == 'Yorkshire E Riding':
            name = 'Yorkshire: East Riding'
        elif name == 'Yorkshire N Riding':
            name = 'Yorkshire: North Riding'
        elif name == 'Yorkshire W Riding':
            name = 'Yorkshire: West Riding'
        return name

    def _get_container(self, name):
        try:
            container = Place.objects.get(
                name=name, patrons_place_type__in=(
                    self._county_type, self._city_type, self._dependency_type))
        except Place.DoesNotExist as e:
            raise CommandError(
                'Failed to find containing county "{}": {}'.format(
                    name, str(e)))
        return container

    def _get_place_type(self, feature):
        name = feature['properties']['LOC_TYPE']
        try:
            place_type = PatronsPlaceType.objects.get(name=name)
        except PatronsPlaceType.DoesNotExist:
            place_type = PatronsPlaceType(name=name)
            place_type.save()
        return place_type

    def _get_region_type(self, feature):
        # The data in regions.json is not restricted to counties,
        # but they are all specified in the GeoJSON as being a
        # county. However, the name for cities includes the term
        # "(city-county)", so use the city type in those cases.
        name = feature['properties']['NAME']
        if '(city-county)' in name:
            region_type = self._city_type
        elif name == 'London':
            region_type = self._city_type
        elif name in ('Guernsey', 'Isle of Man', 'Jersey'):
            region_type = self._dependency_type
        else:
            region_type = self._county_type
        return region_type

    def _import_point(self, feature, name):
        container = self._get_container(self._fix_container_name(feature))
        coordinates = self._make_geometry(feature)
        place_type = self._get_place_type(feature)
        place_data = {
            'container': container,
            'coordinates': coordinates,
            'name': name,
            'patrons_label_flag': feature['properties']['LABEL_FLAG'],
            'patrons_place_code': feature['properties']['PCODE'],
            'patrons_place_type': place_type,
        }
        place = Place(**place_data)
        place.save()

    def _import_point_for_region(self, region, feature):
        region.placeholder_coordinates = self._make_geometry(feature)
        region.save()

    def _import_points(self):
        self.stdout.write('Importing point data from {}'.format(POINTS_FILE))
        with open(POINTS_FILE) as fh:
            input_data = json.load(fh)
        for feature in input_data['features']:
            name = feature['properties']['LABELS']
            try:
                matching_region = Place.objects.get(name=name)
                self._import_point_for_region(matching_region, feature)
            except Place.DoesNotExist:
                self._import_point(feature, name)

    def _import_regions(self):
        self.stdout.write('Importing region data from {}'.format(REGIONS_FILE))
        with open(REGIONS_FILE) as fh:
            input_data = json.load(fh)
        for feature in input_data['features']:
            coordinates = self._make_geometry(feature)
            name = self._fix_region_name(feature)
            place_type = self._get_region_type(feature)
            place_data = {
                'coordinates': coordinates,
                'name': name,
                'patrons_place_type': place_type,
            }
            place = Place(**place_data)
            place.save()

    def _make_geometry(self, feature):
        return GEOSGeometry(json.dumps(feature['geometry']),
                            srid=constants.SRID)
