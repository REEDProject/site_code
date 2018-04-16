"""ereed URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.8/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Add an import:  from blog import urls as blog_urls
    2. Add a URL to urlpatterns:  url(r'^blog/', include(blog_urls))
"""
from django.conf.urls import include, url
from django.contrib import admin

from eats import urls as eats_urls
from geomap import urls as geomap_urls
from git_update import urls as git_urls
from records import urls as records_urls
from text_prepare import urls as text_prepare_urls


urlpatterns = [
    url(r'^accounts/', include('account.urls')),
    url(r'^prepare/', include(text_prepare_urls)),
    url(r'^geomap/', include(geomap_urls)),
    url(r'^git/', include(git_urls)),
    url(r'^djadmin/', include(admin.site.urls)),
    url(r'^selectable/', include('selectable.urls')),
    url(r'^eats/', include(eats_urls)),
    url(r'^', include(records_urls)),
]
