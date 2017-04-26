from django.conf.urls import url

from . import views


app_name = 'git_update'
urlpatterns = [
    url(r'^$', views.pull, name='pull'),
]
