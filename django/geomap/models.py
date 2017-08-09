from django.contrib.gis.db import models
from django.contrib.sites.models import Site
from django.urls import reverse

from . import constants


class PatronsPlaceType(models.Model):

    """Mode representing the Patrons and Performances place type."""

    name = models.CharField(max_length=50, unique=True)

    class Meta:
        verbose_name = 'P&P Place Type'

    def __str__(self):
        return self.name


class Place(models.Model):

    """Model representing a place.

    name: Descriptive, for use of editors only. The name
    that will be displayed outside this system is taken from EATS.

    patrons_place_type: Descriptive, for use of editors only. The type
    that is displayed outside this system is taken from EATS.

    coordinates: Optional co-ordinates of the place. If null, the
    place is considered unlocated, and the co-ordinates of its
    containing place are used (its placeholder_coordinates if not
    null, co-ordinates otherwise).

    is_approximate: Boolean flag, true if the co-ordinates are
    approximate only.

    placeholder_coordinates: Optional co-ordinates for unlocated
    places contained within this place. These co-ordinates are used,
    if not null, in preference to co-ordinates for those contained
    places.  This is primarily to cope with city-counties that have
    areal co-ordinates; their contained unlocated places need to use
    point co-ordinates, which this field will contain.

    container: Optional reference to a containing place. Unlocated
    places use the coordinates of their container.

    patrons_place_code: Legacy P&P data.

    patrons_label_flag: Legacy P&P data.

    """

    name = models.CharField(max_length=50, help_text=constants.NAME_FIELD_HELP)
    patrons_place_type = models.ForeignKey(PatronsPlaceType,
                                           related_name='places')
    coordinates = models.GeometryField(blank=True, null=True,
                                       srid=constants.SRID)
    is_approximate = models.BooleanField(
        default=False, help_text=constants.IS_APPROXIMATE_FIELD_HELP)
    placeholder_coordinates = models.GeometryField(
        blank=True, help_text=constants.PLACEHOLDER_COORDINATES_FIELD_HELP,
        null=True, srid=constants.SRID)
    container = models.ForeignKey('Place', null=True,
                                  related_name='contained_places')
    patrons_place_code = models.IntegerField(
        choices=constants.PATRONS_PLACE_CODE_CHOICES, null=True,
        verbose_name=constants.PATRONS_PLACE_CODE_FIELD_NAME)
    patrons_label_flag = models.IntegerField(
        choices=constants.PATRONS_LABEL_FLAG_CHOICES, null=True,
        verbose_name=constants.PATRONS_LABEL_FLAG_FIELD_NAME)

    def canonical_url(self):
        return 'https://{}{}'.format(Site.objects.get_current().domain,
                                     self.get_absolute_url())

    def get_absolute_url(self):
        return reverse('geomap:place_detail', args=[str(self.id)])

    def __str__(self):
        return self.name
