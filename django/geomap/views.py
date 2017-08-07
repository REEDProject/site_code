from django.core.serializers import serialize
from django.http import HttpResponse

from .models import Place


def _serialise_as_geojson(queryset):
    geojson = serialize('geojson', queryset)
    return HttpResponse(geojson, content_type='application/json')


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
