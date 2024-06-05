import json

from django.contrib.gis.geos import GEOSGeometry
from django.test import TestCase
from django.urls import reverse

from .models import Place


class PlaceModelTests(TestCase):

    def _create_place(self, name, coordinates, container=None, placeholder=None):
        place = Place(
            name=name,
            coordinates=coordinates,
            container=container,
            placeholder_coordinates=placeholder,
        )
        place.save()
        return place

    def test_get_actual_coordinates_with_coords(self):
        """get_actual_coordinates() returns Place's co-ordinates when not
        None."""
        expected_coordinates = GEOSGeometry("POINT(3 4)")
        container = self._create_place("Container", coordinates="POINT(2 3)")
        place = self._create_place("Place", expected_coordinates, container)
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, expected_coordinates)

    def test_get_actual_coordinates_with_placeholder_coords(self):
        """get_actual_coordinates() returns Place's co-ordinates when not
        None, even if placeholder_coordinates is also not None."""
        expected_coordinates = GEOSGeometry("POINT(3 4)")
        place = self._create_place("Place", expected_coordinates, None, "POINT(4 5)")
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, expected_coordinates)

    def test_get_actual_coordinates_with_container_placeholder_coords(self):
        """get_actual_coordinates() returns Place's container's placeholder
        co-ordinates when co-ordinates are None and container's placeholder
        co-ordinates are not None."""
        expected_coordinates = GEOSGeometry("POINT(3 4)")
        container = self._create_place(
            "Container", "POINT(2 3)", None, expected_coordinates
        )
        place = self._create_place("Place", None, container=container)
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, expected_coordinates)

    def test_get_actual_coordinates_with_container_coords(self):
        """get_actual_coordinates() return Place's container's co-ordinates
        when co-ordinates are None and container's placeholder co-ordinates
        are None."""
        expected_coordinates = GEOSGeometry("POINT(3 4)")
        container = self._create_place("Container", expected_coordinates)
        place = self._create_place("Place", None, container)
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, expected_coordinates)

    def test_get_actual_coordinates_with_container_container_coords(self):
        """get_actual_coordinates() returns container's container's
        placeholder co-ordinates when co-ordinates are None and container's
        placeholder co-ordinates and co-ordinates are None."""
        expected_coordinates = GEOSGeometry("POINT(3 4)")
        gp_container = self._create_place(
            "Grandparent Container", None, None, expected_coordinates
        )
        container = self._create_place("Container", None, gp_container)
        place = self._create_place("Place", None, container)
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, expected_coordinates)

    def test_get_actual_coordinates_none(self):
        """get_actual_coordinates() may return None when neither it nor any of
        its ancestor containers have co-ordinates. This should not
        happen, editorially, but nothing in the model prevents it.

        """
        container = self._create_place("Container", None)
        place = self._create_place("Place", None, container)
        actual_coordinates = place.get_actual_coordinates()
        self.assertEqual(actual_coordinates, None)


class PlaceDetailViewTests(TestCase):

    def _compare_json(self, response, expected):
        actual = json.loads(response.content.decode("utf-8"))
        # Add in base GeoJSON material.
        expected["crs"] = {"properties": {"name": "EPSG:4326"}, "type": "name"}
        expected["type"] = "FeatureCollection"
        self.assertEqual(actual, expected)

    def _create_place_json(self, place):
        container = None
        if place.container is not None:
            container = place.container.id
        geojson = {
            "geometry": {"coordinates": [0.0, 0.0], "type": "Point"},
            "properties": {
                "container": container,
                "is_approximate": place.is_approximate,
                "name": place.name,
                "patrons_label_flag": place.patrons_label_flag,
                "place_type": place.place_type,
                "pk": str(place.id),
                "placeholder_coordinates": place.placeholder_coordinates,
                "notes": place.notes,
                "symbol_flag": place.symbol_flag,
            },
            "type": "Feature",
        }
        return geojson

    def test_has_coordinates(self):
        place = Place(name="Place", coordinates="POINT(0 0)")
        place.save()
        url = reverse("geomap:place_detail", args=(place.id,))
        response = self.client.get(url)
        expected_content = {"features": [self._create_place_json(place)]}
        self.assertEqual(response.status_code, 200)
        self._compare_json(response, expected_content)

    def test_has_no_coordinates(self):
        pass

    def test_container_has_coordinates(self):
        container = Place(name="Container", coordinates="POINT(0 0)")
        container.save()
        place = Place(name="Place", coordinates=None, container=container)
        place.save()
        url = reverse("geomap:place_detail", args=(place.id,))
        response = self.client.get(url)
        expected_content = {"features": [self._create_place_json(place)]}
        self.assertEqual(response.status_code, 200)
        self.maxDiff = None
        self._compare_json(response, expected_content)
