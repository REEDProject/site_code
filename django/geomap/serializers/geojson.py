from django.contrib.gis.serializers.geojson import Serializer \
    as GeoJSONSerializer


class Serializer(GeoJSONSerializer):

    def handle_field(self, obj, field):
        if field.name == self.geometry_field:
            self._geometry = obj.get_actual_coordinates()
        else:
            super(Serializer, self).handle_field(obj, field)
