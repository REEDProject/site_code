import csv
import json

from django.core.management.base import BaseCommand, CommandError
from django.contrib.gis.geos import GEOSGeometry
from django.db import transaction

from ...models import PatronsPlaceType, Place
from ... import constants


EXTRA_CSV_FILE = 'extra_places.csv'


class Command(BaseCommand):

    help = 'Import CSV geodata'

    def handle(self, *args, **options):
        with transaction.atomic():
            with open(EXTRA_CSV_FILE, newline='') as fh:
                reader = csv.DictReader(fh)
                for row in reader:
                    coordinates = self._make_geometry(row)
                    place_data = {
                        'container': self._get_container(row['Container']),
                        'coordinates': coordinates,
                        'name': row['Name'],
                    }
                    place = Place(**place_data)
                    place.save()

    def _get_container(self, name):
        try:
            container = Place.objects.get(name=name)
        except Place.DoesNotExist as e:
            raise CommandError(
                'Failed to find containing county "{}": {}'.format(
                    name, str(e)))
        return container

    def _make_geometry(self, row):
        data = {
            'geometry': {
                'coordinates': [
                    float(row['Longitude']), float(row['Latitude'])
                ],
                'type': 'Point',
            }
        }
        return GEOSGeometry(json.dumps(data['geometry']), srid=4326)
