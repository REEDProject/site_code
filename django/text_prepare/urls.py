from django.conf.urls import url

from . import views

app_name = 'text_prepare'
urlpatterns = [
    url(r'^convert/$', views.convert, name='convert'),
    url(r'^update/$', views.update, name='update'),
    url(r'^validate/$', views.validate, name='validate'),
]
