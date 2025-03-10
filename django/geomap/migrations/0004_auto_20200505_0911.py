# -*- coding: utf-8 -*-
# Generated by Django 1.11.17 on 2020-05-04 21:11
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('geomap', '0003_auto_20191018_0940'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='placetype',
            options={'ordering': ['name'], 'verbose_name': 'Place Type'},
        ),
        migrations.AlterField(
            model_name='place',
            name='container',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='contained_places', to='geomap.Place'),
        ),
    ]
