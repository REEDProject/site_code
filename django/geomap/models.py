from django.contrib.gis.db import models
from django.contrib.sites.models import Site
from django.urls import reverse

from . import constants


class PlaceType(models.Model):

    """Mode representing the place type."""

    name = models.CharField(max_length=50, unique=True)
    tile_order = models.PositiveSmallIntegerField(default=1)

    class Meta:
        ordering = ['name']
        verbose_name = 'Place Type'

    def natural_key(self):
        return self.name

    def __str__(self):
        return self.name


class Place(models.Model):

    """Model representing a place.

    name: Descriptive, for use of editors only. The name
    that will be displayed outside this system is taken from EATS.

    place_type: Descriptive, for use of editors only. The type
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
    places. This is primarily to cope with city-counties that have
    areal co-ordinates; their contained unlocated places need to use
    point co-ordinates, which this field will contain.

    container: Optional reference to a containing place. Unlocated
    places use the co-ordinates of their container.

    patrons_label_flag: Specification of at which zoom levels a label
    should be displayed for the place. The name of this field is
    legacy, but the data is not.

    notes: Editorial notes on sources and such.

    """

    name = models.CharField(max_length=50, help_text=constants.NAME_FIELD_HELP)
    place_type = models.ForeignKey(PlaceType, blank=True, null=True,
                                   related_name='places')
    coordinates = models.GeometryField(blank=True, null=True,
                                       srid=constants.SRID)
    is_approximate = models.BooleanField(
        default=False, help_text=constants.IS_APPROXIMATE_FIELD_HELP)
    placeholder_coordinates = models.GeometryField(
        blank=True, help_text=constants.PLACEHOLDER_COORDINATES_FIELD_HELP,
        null=True, srid=constants.SRID)
    container = models.ForeignKey('Place', blank=True, null=True,
                                  related_name='contained_places')
    patrons_label_flag = models.IntegerField(
        'label flag', blank=True, choices=constants.LABEL_FLAG_CHOICES,
        null=True)
    symbol_flag = models.IntegerField(
        blank=True, choices=constants.SYMBOL_FLAG_CHOICES, null=True)
    notes = models.TextField(blank=True)

    def get_actual_coordinates(self, include_placeholder=False):
        """Returns the actual co-ordinates for this place.

        This handles the case when a place is 'unlocated' except
        generally within another place; in which case the containing
        place's placeholder co-ordinates (or co-ordinates if there are
        no placeholder co-ordinates) are used.

        This method recurses up the containment hierarchy.

        """
        if include_placeholder and self.placeholder_coordinates:
            coordinates = self.placeholder_coordinates
        else:
            coordinates = self.coordinates
        if coordinates is None and self.container:
            coordinates = self.container.get_actual_coordinates(True)
        return coordinates

    def canonical_url(self):
        return 'https://{}{}'.format(Site.objects.get_current().domain,
                                     self.get_absolute_url())

    def get_absolute_url(self):
        return reverse('geomap:place_detail', args=[str(self.id)])

    def __str__(self):
        return self.name
