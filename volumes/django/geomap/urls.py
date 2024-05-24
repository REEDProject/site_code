from django.conf.urls import url

from . import views


app_name = 'geomap'
urlpatterns = [
    url(r'^places/(?P<pk>\d+)/$', views.place_detail, name='place_detail'),
    url(r'^serialise/all/placeholders/$',
        views.serialise_all_with_placeholders,
        name='serialise_all_with_placeholders'),
    url(r'^serialise/points/$', views.serialise_points,
        name='serialise_points'),
    url(r'^serialise/regions/$', views.serialise_regions,
        name='serialise_regions'),
]
