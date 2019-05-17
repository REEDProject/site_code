# -*- coding: utf-8 -*-
import datetime

from eats.models import Authority, Calendar, DatePeriod, DateType, Entity, EntityRelationshipType, EntityType, Language, NameType, Script
from eats.tests.models.model_test_case import ModelTestCase


class EATSTopicMapTestCase (ModelTestCase):

    def test_create_authority (self):
        self.assertEqual(Authority.objects.count(), 1)
        authority1 = self.tm.create_authority('Test1')
        self.assertEqual(Authority.objects.count(), 2)
        self.assertTrue(authority1 in Authority.objects.all())
        self.assertRaises(Exception, self.tm.create_authority, 'Test1')

    def test_create_calendar (self):
        self.assertEqual(Calendar.objects.count(), 0)
        calendar = self.tm.create_calendar('Test')
        self.assertEqual(Calendar.objects.count(), 1)
        self.assertTrue(calendar in Calendar.objects.all())
        self.assertRaises(Exception, self.tm.create_calendar, 'Test')
        self.assertEqual(Calendar.objects.count(), 1)
        self.assertTrue(calendar in Calendar.objects.all())

    def test_create_date_period (self):
        self.assertEqual(DatePeriod.objects.count(), 0)
        date_period = self.tm.create_date_period('Test')
        self.assertEqual(DatePeriod.objects.count(), 1)
        self.assertTrue(date_period in DatePeriod.objects.all())
        self.assertRaises(Exception, self.tm.create_date_period, 'Test')
        self.assertEqual(DatePeriod.objects.count(), 1)
        self.assertTrue(date_period in DatePeriod.objects.all())

    def test_create_date_type (self):
        self.assertEqual(DateType.objects.count(), 0)
        date_type = self.tm.create_date_type('Test')
        self.assertEqual(DateType.objects.count(), 1)
        self.assertTrue(date_type in DateType.objects.all())
        self.assertRaises(Exception, self.tm.create_date_type, 'Test')
        self.assertEqual(DateType.objects.count(), 1)
        self.assertTrue(date_type in DateType.objects.all())

    def test_create_entity (self):
        self.assertEqual(Entity.objects.count(), 0)
        entity_1 = self.tm.create_entity()
        self.assertEqual(Entity.objects.count(), 1)
        self.assertEqual(entity_1.get_existences().count(), 0)
        entity_2 = self.tm.create_entity(authority=self.authority)
        self.assertEqual(Entity.objects.count(), 2)
        self.assertEqual(entity_2.get_existences().count(), 1)
        self.assertEqual(entity_2.get_existences()[0].authority,
                         self.authority)
        user = self.create_django_user('clara', 'clara@foo.org', 'cfo#1')
        entity_3 = self.tm.create_entity(user=user)
        self.assertEqual(Entity.objects.count(), 3)
        self.assertEqual(entity_3.get_existences().count(), 0)
        self.assertEqual(entity_3.creator, user)

    def test_create_entity_relationship_type (self):
        self.assertEqual(EntityRelationshipType.objects.count(), 0)
        er_type = self.tm.create_entity_relationship_type('Forward', 'Reverse')
        self.assertEqual(EntityRelationshipType.objects.count(), 1)
        self.assertTrue(er_type in EntityRelationshipType.objects.all())
        self.assertRaises(Exception, self.tm.create_entity_relationship_type,
                          'Forward', 'Reverse')
        self.assertEqual(EntityRelationshipType.objects.count(), 1)
        self.assertTrue(er_type in EntityRelationshipType.objects.all())
        er_type2 = self.tm.create_entity_relationship_type(
            'Forward', 'Reverse2')
        self.assertEqual(EntityRelationshipType.objects.count(), 2)
        self.assertTrue(er_type in EntityRelationshipType.objects.all())
        self.assertTrue(er_type2 in EntityRelationshipType.objects.all())
        er_type3 = self.tm.create_entity_relationship_type(
            'Forward2', 'Reverse')
        self.assertEqual(EntityRelationshipType.objects.count(), 3)
        self.assertTrue(er_type in EntityRelationshipType.objects.all())
        self.assertTrue(er_type2 in EntityRelationshipType.objects.all())
        self.assertTrue(er_type3 in EntityRelationshipType.objects.all())

    def test_create_entity_type (self):
        self.assertEqual(EntityType.objects.count(), 0)
        entity_type = self.tm.create_entity_type('Test')
        self.assertEqual(EntityType.objects.count(), 1)
        self.assertTrue(entity_type in EntityType.objects.all())
        self.assertRaises(Exception, self.tm.create_entity_type, 'Test')
        self.assertEqual(EntityType.objects.count(), 1)
        self.assertTrue(entity_type in EntityType.objects.all())

    def test_create_language (self):
        self.assertEqual(Language.objects.count(), 0)
        language = self.tm.create_language('English', 'en')
        self.assertEqual(Language.objects.count(), 1)
        self.assertTrue(language in Language.objects.all())
        self.assertRaises(Exception, self.tm.create_language, 'English', 'fr')
        self.assertEqual(Language.objects.count(), 1)
        self.assertTrue(language in Language.objects.all())
        self.assertEqual(language.get_code(), 'en')
        self.assertRaises(Exception, self.tm.create_language, 'French', 'en')
        self.assertEqual(Language.objects.count(), 1)
        self.assertTrue(language in Language.objects.all())
        self.assertEqual(language.get_admin_name(), 'English')

    def test_create_name_type (self):
        self.assertEqual(NameType.objects.count(), 0)
        name_type = self.tm.create_name_type('Test')
        self.assertEqual(NameType.objects.count(), 1)
        self.assertTrue(name_type in NameType.objects.all())
        self.assertRaises(Exception, self.tm.create_name_type, 'Test')
        self.assertEqual(NameType.objects.count(), 1)
        self.assertTrue(name_type in NameType.objects.all())

    def test_create_script (self):
        self.assertEqual(Script.objects.count(), 0)
        script = self.tm.create_script('Latin', 'Latn', ' ')
        self.assertEqual(Script.objects.count(), 1)
        self.assertTrue(script in Script.objects.all())
        self.assertRaises(Exception, self.tm.create_script, 'Latin', 'Arab', '')
        self.assertEqual(Script.objects.count(), 1)
        self.assertTrue(script in Script.objects.all())
        self.assertEqual(script.get_code(), 'Latn')
        self.assertRaises(Exception, self.tm.create_script, 'Arabic', 'Latn',
                          ' ')
        self.assertEqual(Script.objects.count(), 1)
        self.assertTrue(script in Script.objects.all())
        self.assertEqual(script.get_admin_name(), 'Latin')

    def test_get_unnamed_entities (self):
        self.assertEqual(Entity.objects.count(), 0)
        self.assertEqual(self.tm.get_unnamed_entities().count(), 0)
        language = self.create_language('English', 'en')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        self.authority.set_languages([language])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        entity1 = self.tm.create_entity(self.authority)
        self.assertEqual(Entity.objects.count(), 1)
        self.assertEqual(self.tm.get_unnamed_entities().count(), 1)
        self.assertEqual(self.tm.get_unnamed_entities()[0], entity1)
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Duns Scotus')
        self.assertEqual(Entity.objects.count(), 2)
        self.assertEqual(self.tm.get_unnamed_entities().count(), 1)
        self.assertEqual(self.tm.get_unnamed_entities()[0], entity1)

    def test_lookup_entities (self):
        self.assertEqual(Entity.objects.count(), 0)
        self.assertEqual(list(self.tm.lookup_entities('Johann')), [])
        language = self.create_language('English', 'en')
        name_part_type1 = self.create_name_part_type('given')
        name_part_type2 = self.create_name_part_type('family')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        self.authority.set_languages([language])
        self.authority.set_name_part_types([name_part_type1, name_part_type2])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        entity1 = self.tm.create_entity(self.authority)
        entity1_name1 = entity1.create_name_property_assertion(
            self.authority, name_type, language, script,
            'Johann Sebastian Bach')
        self.assertEqual(list(self.tm.lookup_entities('Johann')), [entity1])
        # Partial (initial) matches are allowed.
        self.assertEqual(list(self.tm.lookup_entities('Seb')), [entity1])
        # Case does not matter.
        self.assertEqual(list(self.tm.lookup_entities('ba')), [entity1])
        # Order of search terms need not match order in name.
        self.assertEqual(list(self.tm.lookup_entities('B J')), [entity1])
        # Searching over name parts should be the same as searching
        # over a name's display form.
        entity1_name1.name.create_name_part(name_part_type1, language, script,
                                           'Johann', 1)
        entity1_name1.name.create_name_part(name_part_type1, language, script,
                                           'Sebastian', 2)
        entity1_name1.name.create_name_part(name_part_type2, language, script,
                                           'Bach', 1)
        entity1_name1.name.update(name_type, language, script, '')
        self.assertEqual(list(self.tm.lookup_entities('Johann')), [entity1])
        # Partial (initial) matches are allowed.
        self.assertEqual(list(self.tm.lookup_entities('Seb')), [entity1])
        # Punctuation does not matter.
        self.assertEqual(list(self.tm.lookup_entities('J. Sebastian Bach')),
                         [entity1])
        # Case does not matter.
        self.assertEqual(list(self.tm.lookup_entities('ba')), [entity1])
        # Order of search terms need not match order in name.
        self.assertEqual(list(self.tm.lookup_entities('B J')), [entity1])
        entity1.create_name_property_assertion(
            self.authority, name_type, language, script, 'Alfred')
        self.assertEqual(list(self.tm.lookup_entities('Alf')), [entity1])
        # Individual query elements need not refer to the same name.
        self.assertEqual(list(self.tm.lookup_entities('Al B')), [entity1])
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Duns Scotus')
        self.assertEqual(set(self.tm.lookup_entities('S')),
                         set([entity1, entity2]))
        self.assertEqual(list(self.tm.lookup_entities('B s')), [entity1])
        self.assertEqual(list(self.tm.lookup_entities('u')), [])

    def test_lookup_entities_alternate (self):
        self.assertEqual(Entity.objects.count(), 0)
        self.assertEqual(list(self.tm.lookup_entities('Maori')), [])
        language = self.create_language('English', 'en')
        name_part_type1 = self.create_name_part_type('given')
        name_part_type2 = self.create_name_part_type('family')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        self.authority.set_languages([language])
        self.authority.set_name_part_types([name_part_type1, name_part_type2])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        entity1 = self.tm.create_entity(self.authority)
        entity1.create_name_property_assertion(
            self.authority, name_type, language, script,
            'Māori')
        self.assertEqual(list(self.tm.lookup_entities('Māori')), [entity1])
        self.assertEqual(list(self.tm.lookup_entities('Maori')), [entity1])
        self.assertEqual(list(self.tm.lookup_entities('Maaori')), [entity1])
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Maori')
        self.assertEqual(set(self.tm.lookup_entities('Māori')),
                         set([entity1, entity2]))
        self.assertEqual(set(self.tm.lookup_entities('Maori')),
                         set([entity1, entity2]))
        self.assertEqual(list(self.tm.lookup_entities('Maaori')), [entity1])

    def test_lookup_entities_entity_type (self):
        # Test lookups with an entity type specified.
        language = self.create_language('English', 'en')
        name_part_type1 = self.create_name_part_type('given')
        name_part_type2 = self.create_name_part_type('family')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        entity_type1 = self.create_entity_type('person')
        entity_type2 = self.create_entity_type('place')
        self.authority.set_languages([language])
        self.authority.set_name_part_types([name_part_type1, name_part_type2])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        self.authority.set_entity_types([entity_type1, entity_type2])
        entity1 = self.tm.create_entity(self.authority)
        entity1.create_entity_type_property_assertion(
            self.authority, entity_type1)
        entity1.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_entity_type_property_assertion(
            self.authority, entity_type2)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        self.assertEqual(set(self.tm.lookup_entities('Paris')),
                         set([entity1, entity2]))
        self.assertEqual(list(self.tm.lookup_entities('Paris', [entity_type1])),
                         [entity1])
        self.assertEqual(list(self.tm.lookup_entities('Paris', [entity_type2])),
                         [entity2])
        self.assertEqual(set(self.tm.lookup_entities(
            'Paris', [entity_type1, entity_type2])), set([entity1, entity2]))

    def test_lookup_entities_entity_relationship_type (self):
        # Test lookups with an entity relationship type specified.
        language = self.create_language('English', 'en')
        name_part_type1 = self.create_name_part_type('given')
        name_part_type2 = self.create_name_part_type('family')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        entity_relationship_type1 = self.create_entity_relationship_type(
            'is child of', 'is parent of')
        entity_relationship_type2 = self.create_entity_relationship_type(
            'is friend of', 'is friend of')
        self.authority.set_languages([language])
        self.authority.set_name_part_types([name_part_type1, name_part_type2])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        self.authority.set_entity_relationship_types(
            [entity_relationship_type1, entity_relationship_type2])
        entity1 = self.tm.create_entity(self.authority)
        entity1.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity3 = self.tm.create_entity(self.authority)
        entity3.create_name_property_assertion(
            self.authority, name_type, language, script, 'Priam')
        entity1.create_entity_relationship_property_assertion(
            self.authority, entity_relationship_type1, entity1, entity3,
            self.tm.property_assertion_full_certainty)
        entity2.create_entity_relationship_property_assertion(
            self.authority, entity_relationship_type2, entity3, entity2,
            self.tm.property_assertion_full_certainty)
        self.assertEqual(set(self.tm.lookup_entities('Paris')),
                         set([entity1, entity2]))
        self.assertEqual(set(self.tm.lookup_entities(
            'Paris', entity_relationship_types=[entity_relationship_type1])),
                         set([entity1]))
        self.assertEqual(set(self.tm.lookup_entities(
            '*', entity_relationship_types=[entity_relationship_type2])),
                         set([entity2, entity3]))

    def test_lookup_entities_date (self):
        self.assertEqual(Entity.objects.count(), 0)
        self.assertEqual(list(self.tm.lookup_entities('Johann')), [])
        language = self.create_language('English', 'en')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        self.authority.set_languages([language])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        entity1 = self.tm.create_entity(self.authority)
        entity1_name1 = entity1.create_name_property_assertion(
            self.authority, name_type, language, script,
            'Johann Sebastian Bach')
        past = datetime.date(1000, 1, 1)
        future = datetime.date(3000, 1, 1)
        actual = self.tm.lookup_entities('Bach', creation_start_date=past)
        expected = [entity1]
        self.assertEqual(list(actual), expected)
        actual = self.tm.lookup_entities('Bach', creation_end_date=future)
        expected = [entity1]
        self.assertEqual(list(actual), expected)
        actual = self.tm.lookup_entities('Bach', creation_start_date=past,
                                         creation_end_date=future)
        expected = [entity1]
        self.assertEqual(list(actual), expected)
        actual = self.tm.lookup_entities('Bach', creation_start_date=future)
        expected = []
        self.assertEqual(list(actual), expected)
        actual = self.tm.lookup_entities('Wibble', creation_start_date=past)
        expected = []
        self.assertEqual(list(actual), expected)

    def test_lookup_entities_all (self):
        # Test lookups with entity relationship type and entity type
        # specified.
        language = self.create_language('English', 'en')
        name_part_type1 = self.create_name_part_type('given')
        name_part_type2 = self.create_name_part_type('family')
        name_type = self.create_name_type('regular')
        script = self.create_script('Latin', 'Latn', ' ')
        entity_type1 = self.create_entity_type('person')
        entity_type2 = self.create_entity_type('place')
        entity_relationship_type1 = self.create_entity_relationship_type(
            'is child of', 'is parent of')
        entity_relationship_type2 = self.create_entity_relationship_type(
            'is friend of', 'is friend of')
        self.authority.set_languages([language])
        self.authority.set_name_part_types([name_part_type1, name_part_type2])
        self.authority.set_name_types([name_type])
        self.authority.set_scripts([script])
        self.authority.set_entity_types([entity_type1, entity_type2])
        self.authority.set_entity_relationship_types(
            [entity_relationship_type1, entity_relationship_type2])
        entity1 = self.tm.create_entity(self.authority)
        entity1.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity1.create_entity_type_property_assertion(
            self.authority, entity_type1)
        entity2 = self.tm.create_entity(self.authority)
        entity2.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity2.create_entity_type_property_assertion(
            self.authority, entity_type2)
        entity3 = self.tm.create_entity(self.authority)
        entity3.create_name_property_assertion(
            self.authority, name_type, language, script, 'Paris')
        entity3.create_entity_type_property_assertion(
            self.authority, entity_type1)
        entity1.create_entity_relationship_property_assertion(
            self.authority, entity_relationship_type1, entity1, entity2,
            self.tm.property_assertion_full_certainty)
        entity2.create_entity_relationship_property_assertion(
            self.authority, entity_relationship_type2, entity2, entity3,
            self.tm.property_assertion_full_certainty)
        self.assertEqual(set(self.tm.lookup_entities('Paris')),
                         set([entity1, entity2, entity3]))
        self.assertEqual(set(self.tm.lookup_entities(
            'Paris', entity_types=[entity_type1],
            entity_relationship_types=[entity_relationship_type1])),
                         set([entity1]))
