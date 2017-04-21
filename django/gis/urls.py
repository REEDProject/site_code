from django.conf.urls import url

from . import views


app_name = 'gis'
urlpatterns = [
    url(r'^$', views.fetch_geojson, name='fetch'),
]
