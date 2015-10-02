from django.conf.urls import url

from . import views


urlpatterns = [
    url(r'^convert/$', views.convert, name='text_prepare-convert'),
    url(r'^validate/$', views.validate, name='text_prepare-validate'),
]
