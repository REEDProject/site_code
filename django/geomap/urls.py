from django.conf.urls import url

from . import views


app_name = 'geomap'
urlpatterns = [
    url(r'^serialise/points/$', views.serialise_points,
        name='serialise_points'),
    url(r'^serialise/regions/$', views.serialise_regions,
        name='serialise_regions'),
]
