from django.conf import settings

if "django_cache_manager" in settings.INSTALLED_APPS:
    from django_cache_manager.cache_manager import CacheManager, CachingQuerySet

    class Manager(CacheManager):
        def get_queryset(self):
            class_name = "ModelCachingQuerySet"
            return type(class_name, (CachingQuerySet, self._queryset_class), {})(
                model=self.model, using=self._db
            )

else:
    from django.db.models import Manager


class BaseManager(Manager):

    @property
    def eats_topic_map(self):
        if not hasattr(self, "_eats_topic_map"):
            from .eats_topic_map import EATSTopicMap

            self._eats_topic_map = EATSTopicMap.objects.get(iri=settings.EATS_TOPIC_MAP)
        return self._eats_topic_map

    def get_by_identifier(self, identifier):
        return self.get(identifier__pk=identifier)
