"""Django management command to export entities."""

import os
import datetime

from django.conf import settings
from django.core.management.base import BaseCommand

from lxml import etree

from eats.lib.eatsml_exporter import EATSMLExporter
from eats.models import Entity, EATSTopicMap


class Command(BaseCommand):

    help = "Exports `entities` as EATSML."

    def handle(self, *args, **options):
        print("Exporting entities.")
        topic_map = EATSTopicMap.objects.get(iri=settings.EATS_TOPIC_MAP)

        entities = Entity.objects.all()
        tree = EATSMLExporter(topic_map).export_entities(entities)
        xml = etree.tostring(tree, encoding="utf-8", pretty_print=True)

        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"entities_{timestamp}.xml"

        file_path = os.path.join(settings.EATS_EXPORT_PATH, filename)

        with open(file_path, "w") as file:
            file.write(xml.decode("utf-8"))

        self.stdout.write(self.style.SUCCESS(f"Entities exported to {file_path}"))
