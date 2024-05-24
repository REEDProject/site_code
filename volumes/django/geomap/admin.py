from django.contrib import admin
from django.contrib.gis import admin as gis_admin
from django.core.serializers import serialize

from leaflet.admin import LeafletGeoAdmin

from .models import Place, PlaceType


class ContainingPlaceListFilter(admin.SimpleListFilter):

    title = 'containing place'
    parameter_name = 'containing'

    def lookups(self, request, model_admin):
        return Place.objects.filter(
            contained_places__isnull=False).distinct().order_by(
                'name').values_list('pk', 'name')

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(container=self.value())
        else:
            return queryset


class PlaceTypeAdmin(admin.ModelAdmin):

    ordering = ('name',)


class PlaceAdmin(LeafletGeoAdmin):

    list_display = ('name', 'place_type', 'container', 'canonical_url')
    list_filter = ('place_type', ContainingPlaceListFilter)
    ordering = ('name',)
    search_fields = ['name', 'container__name', 'container__container__name']

    def _add_places_to_context(self, places, context):
        context = context or {}
        geodata = places.extra(where=["GeometryType(coordinates) = 'POINT'"])
        context['geodata'] = serialize('geojson', geodata)
        return context

    def add_view(self, request, form_url='', extra_context=None):
        places = Place.objects.all()
        extra_context = self._add_places_to_context(places, extra_context)
        return super().add_view(request, form_url, extra_context=extra_context)

    def change_view(self, request, object_id, form_url='', extra_context=None):
        places = Place.objects.exclude(pk=object_id)
        extra_context = self._add_places_to_context(places, extra_context)
        return super().change_view(request, object_id, form_url,
                                   extra_context=extra_context)


gis_admin.site.register(PlaceType, PlaceTypeAdmin)
gis_admin.site.register(Place, PlaceAdmin)
