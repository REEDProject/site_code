# -*- coding: utf-8 -*-
# Generated by Django 1.11.29 on 2020-07-08 05:31
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('geomap', '0004_auto_20200505_0911'),
    ]

    operations = [
        migrations.AddField(
            model_name='place',
            name='symbol_flag',
            field=models.IntegerField(blank=True, choices=[(0, 'Places not expected to be shown'), (1, 'Places to be shown at all zoom levels (eg, major towns)'), (2, 'Places to be shown at intermediate zoom levels (eg, minor towns)'), (3, 'Places to be shown at highest zoom levels (eg, buildings)')], null=True),
        ),
    ]