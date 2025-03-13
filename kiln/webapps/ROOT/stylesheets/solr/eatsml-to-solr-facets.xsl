<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to generate facet field(s) for each EATSML entity. Each
       entity, frequently based on its type, will be used as a facet
       value in zero or more facets. Create the Solr field XML here,
       once for each entity, so that they can be copied into the index
       document for one or more TEI files whenever a reference to an
       entity is encountered. -->

  <!-- The following variables specify the xml:id (based derivably
       from the EATS ID of the entity types and relationships that are
       used to determine which facet(s) an entity belongs to. -->
  <!-- Entity types -->
  <xsl:variable name="calendar_liturgical" select="'entity_type-4857'" />
  <xsl:variable name="calendar_secular" select="'entity_type-4855'" />
  <xsl:variable name="collective_clergy" select="'entity_type-9104'" />
  <xsl:variable name="collective_guild_occupational"
                select="'entity_type-48092'" />
  <xsl:variable name="collective_guild_religious"
                select="'entity_type-48094'" />
  <xsl:variable name="collective_occupation" select="'entity_type-519'" />
  <xsl:variable name="collective_office" select="'entity_type-25986'" />
  <xsl:variable name="collective_title" select="'entity_type-555'" />
  <xsl:variable name="collective_troupe" select="'entity_type-12619'" />
  <xsl:variable name="crimes_misdemeanour" select="'entity_type-21297'" />
  <xsl:variable name="drama_character" select="'entity_type-21227'" />
  <xsl:variable name="drama_type" select="'entity_type-21223'" />
  <xsl:variable name="drama_work" select="'entity_type-21225'" />
  <xsl:variable name="entertainer_type" select="'entity_type-521'" />
  <xsl:variable name="entertainment_animal" select="'entity_type-4867'" />
  <xsl:variable name="entertainment_custom" select="'entity_type-4941'" />
  <xsl:variable name="entertainment_type" select="'entity_type-21440'" />
  <xsl:variable name="person_family" select="'entity_type-23416'" />
  <xsl:variable name="person_clergy" select="'entity_type-523'" />
  <xsl:variable name="person_commoner" select="'entity_type-525'" />
  <xsl:variable name="person_female" select="'entity_type-537'" />
  <xsl:variable name="person_unknown" select="'entity_type-527'" />
  <xsl:variable name="person_gentry" select="'entity_type-529'" />
  <xsl:variable name="person_male" select="'entity_type-531'" />
  <xsl:variable name="person_nobility" select="'entity_type-533'" />
  <xsl:variable name="person_royalty" select="'entity_type-535'" />
  <xsl:variable name="location_country" select="'entity_type-541'" />
  <xsl:variable name="location_county" select="'entity_type-543'" />
  <xsl:variable name="location_duchy" select="'entity_type-259881'" />
  <xsl:variable name="location_ea_archdeaconry" select="'entity_type-249050'" />
  <xsl:variable name="location_ea_diocese" select="'entity_type-249052'" />
  <xsl:variable name="location_ea_province" select="'entity_type-249054'" />
  <xsl:variable name="location_feature" select="'entity_type-21368'" />
  <xsl:variable name="location_feature_arena" select="'entity_type-4831'" />
  <xsl:variable name="location_feature_bridge" select="'entity_type-247662'" />
  <xsl:variable name="location_feature_church" select="'entity_type-4833'" />
  <xsl:variable name="location_feature_church_house"
                select="'entity_type-4835'" />
  <xsl:variable name="location_feature_gate" select="'entity_type-247664'" />
  <xsl:variable name="location_feature_guild_hall"
                select="'entity_type-4839'" />
  <xsl:variable name="location_feature_hospital"
                select="'entity_type-247666'" />
  <xsl:variable name="location_feature_inn_of_court"
                select="'entity_type-4843'" />
  <xsl:variable name="location_feature_open_area"
                select="'entity_type-4845'" />
  <xsl:variable name="location_feature_place_of_punishment"
                select="'entity_type-247670'" />
  <xsl:variable name="location_feature_playhouse"
                select="'entity_type-4851'" />
  <xsl:variable name="location_feature_property"
                select="'entity_type-247674'" />
  <xsl:variable name="location_feature_religious_house"
                select="'entity_type-551'" />
  <xsl:variable name="location_feature_residence"
                select="'entity_type-247672'" />
  <xsl:variable name="location_feature_school" select="'entity_type-4847'" />
  <xsl:variable name="location_feature_street" select="'entity_type-247676'" />
  <xsl:variable name="location_feature_town_hall"
                select="'entity_type-4853'" />
  <xsl:variable name="location_feature_victualling_house"
                select="'entity_type-4841'" />
  <xsl:variable name="location_feature_water_feature"
                select="'entity_type-247678'" />
  <xsl:variable name="location_pa_liberty" select="'entity_type-248915'" />
  <xsl:variable name="location_pa_manor" select="'entity_type-248917'" />
  <xsl:variable name="location_pa_settlement" select="'entity_type-248913'" />
  <xsl:variable name="location_pa_ward" select="'entity_type-248919'" />
  <xsl:variable name="material_book" select="'entity_type-4951'" />
  <xsl:variable name="material_cloth" select="'entity_type-4959'" />
  <xsl:variable name="material_costume" select="'entity_type-4961'" />
  <xsl:variable name="material_food" select="'entity_type-4965'" />
  <xsl:variable name="material_instrument" select="'entity_type-553'" />
  <xsl:variable name="material_property" select="'entity_type-4953'" />
  <xsl:variable name="material_regalia" select="'entity_type-4963'" />
  <xsl:variable name="material_set" select="'entity_type-4957'" />
  <xsl:variable name="material_wagon" select="'entity_type-4955'" />
  <!-- Entity relationship types -->
  <xsl:variable name="contains" select="'entity_relationship_type-502'" />
  <xsl:variable name="holds_title" select="'entity_relationship_type-494'" />
  <xsl:variable name="is_a" select="'entity_relationship_type-22042'" />
  <xsl:variable name="is_subset_of" select="'entity_relationship_type-499'" />
  <xsl:variable name="had_occupation"
                select="'entity_relationship_type-21008'" />
  <xsl:variable name="patronized" select="'entity_relationship_type-12724'" />
  <!-- Collections of types -->
  <xsl:variable name="location_ecclesiastical_areas"
                select="($location_ea_archdeaconry, $location_ea_diocese, $location_ea_province)" />
  <xsl:variable name="location_features"
                select="($location_feature_arena, $location_feature_bridge, $location_feature_church, $location_feature_church_house, $location_feature_gate, $location_feature_guild_hall, $location_feature_hospital, $location_feature_inn_of_court, $location_feature_open_area, $location_feature_place_of_punishment, $location_feature_playhouse, $location_feature_property, $location_feature_religious_house, $location_feature_residence, $location_feature_school, $location_feature_street, $location_feature_town_hall, $location_feature_victualling_house, $location_feature_water_feature)" />
  <xsl:variable name="location_populated_areas"
                select="($location_pa_liberty, $location_pa_manor, $location_pa_settlement, $location_pa_ward)" />
  <xsl:variable name="locations"
                select="($location_country, $location_county, $location_duchy, $location_ecclesiastical_areas, $location_populated_areas, $location_features)" />

  <xsl:template match="/">
    <entities>
      <xsl:apply-templates select="eats:collection/eats:entities/eats:entity" />
    </entities>
  </xsl:template>

  <xsl:template match="eats:entity">
    <entity url="{@url}">
      <xsl:apply-templates select="eats:entity_types/eats:entity_type/@entity_type">
        <xsl:with-param name="entity_eats_id" select="@eats_id" />
        <xsl:with-param name="entity_id" select="@xml:id" />
      </xsl:apply-templates>
      <xsl:apply-templates select="eats:entity_relationships/eats:entity_relationship">
        <xsl:with-param name="entity_id" select="@xml:id" />
      </xsl:apply-templates>
    </entity>
  </xsl:template>

  <xsl:template match="eats:entity_relationship">
    <xsl:param name="entity_id" />
    <xsl:variable name="range_entity" select="id(@range_entity)" />
    <!-- Location containment relationships, so that each place adds
         the appropriate facet value for each containing place. -->
    <xsl:if test="@entity_relationship_type=$contains and @domain_entity=$entity_id and ../../eats:entity_types/eats:entity_type[@entity_type=$locations]">    
      <xsl:apply-templates select="$range_entity/eats:entity_types/eats:entity_type[@entity_type=$locations]/@entity_type">
        <xsl:with-param name="entity_eats_id" select="$range_entity/@eats_id" />
        <xsl:with-param name="entity_id" select="$range_entity/@xml:id" />
      </xsl:apply-templates>
    </xsl:if>
    <!-- Entertainers: type and status. -->
    <xsl:if test="@entity_relationship_type=$is_a and $range_entity/eats:entity_types/eats:entity_type/@entity_type=$entertainer_type">
      <field name="facet_entertainers_type">
        <xsl:value-of select="$range_entity/@eats_id" />
      </field>
      <!-- Unpatronised entertainers. These are any entity that has an
           $is_a relationship with an entity with the
           $entertainer_type type but does not have a $patronised
           relationship. -->
      <xsl:if test="not(../eats:entity_relationship[@entity_relationship_type=$patronized][@range_entity=$entity_id])">
        <field name="facet_entertainers_status">
          <xsl:text>unknown</xsl:text>
        </field>
      </xsl:if>
    </xsl:if>
    <!-- Patronised entertainers. These are any entity that has a
         $patronised relationship. -->
    <xsl:if test="@entity_relationship_type=$patronized and @range_entity=$entity_id">
      <field name="facet_entertainers_status">
        <xsl:text>patronized</xsl:text>
      </field>
    </xsl:if>
    <!-- Drama type: a $drama_work entity has the type of the
         $drama_type it is related to via an "is a" relationship. -->
    <xsl:if test="../../eats:entity_types/eats:entity_type/@entity_type=$drama_work and @entity_relationship_type=$is_a and $range_entity/eats:entity_types/eats_entity_type/@entity_type=$drama_type">
      <field name="facet_drama_type">
        <xsl:value-of select="$range_entity/@eats_id" />
      </field>
    </xsl:if>
    <!-- Person: occupation. -->
    <xsl:if test="@entity_relationship_type=$had_occupation and
                  @domain_entity=$entity_id">
      <xsl:apply-templates select="$range_entity/eats:entity_types/eats:entity_type/@entity_type">
        <xsl:with-param name="entity_eats_id" select="$range_entity/@eats_id" />
        <xsl:with-param name="entity_id" select="$range_entity/@xml:id" />
      </xsl:apply-templates>
    </xsl:if>
    <!-- Person: title. -->
    <xsl:if test="@entity_relationship_type=$holds_title and
                  @domain_entity=$entity_id">
      <xsl:apply-templates select="$range_entity/eats:entity_types/eats:entity_type/@entity_type">
        <xsl:with-param name="entity_eats_id" select="$range_entity/@eats_id" />
        <xsl:with-param name="entity_id" select="$range_entity/@xml:id" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eats:entity/eats:entity_types/eats:entity_type/@entity_type">
    <xsl:param name="entity_eats_id" />
    <xsl:param name="entity_id" />
    <!-- Create and assign values to zero or more facet fields based
         on the entity type. -->
    <!-- Calendar Days -->
    <xsl:if test=". = $calendar_liturgical">
      <field name="facet_days_liturgical">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $calendar_secular">
      <field name="facet_days_secular">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Collectives -->
    <xsl:if test=". = $collective_guild_occupational">
      <field name="facet_collectives_guild_occupational">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $collective_guild_religious">
      <field name="facet_collectives_guild_religious">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $collective_occupation">
      <field name="facet_collectives_occupation">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $collective_clergy">
      <field name="facet_collectives_clergy">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $collective_office">
      <xsl:choose>
        <xsl:when test="../../../eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$is_subset_of][@range_entity=$entity_id]">
          <field name="facet_collectives_office_type">
            <xsl:value-of select="$entity_eats_id" />
          </field>
        </xsl:when>
        <xsl:otherwise>
          <field name="facet_collectives_office_specific">
            <xsl:value-of select="$entity_eats_id" />
          </field>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="../../../eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$is_subset_of][@domain_entity=$entity_id]">
        <field name="facet_collectives_office_type">
          <xsl:value-of select="id(@range_entity)/@eats_id" />
        </field>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test=". = $collective_title">
      <field name="facet_collectives_title">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Crimes and Misdemeanours -->
    <xsl:if test=". = $crimes_misdemeanour">
      <field name="facet_crimes_crime">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Drama -->
    <xsl:if test=". = $drama_type">
      <field name="facet_drama_type">
        <xsl:value-of select="$entity_eats_id" />
      </field>
      <field name="facet_drama_status">
        <xsl:text>unknown</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $drama_work">
      <field name="facet_drama_work">
        <xsl:value-of select="$entity_eats_id" />
      </field>
      <field name="facet_drama_status">
        <xsl:text>titled</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $drama_character">
      <field name="facet_drama_character">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Entertainers -->
    <xsl:if test=". = $entertainer_type">
      <field name="facet_entertainers_type">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Troupes: are unpatronised if they do not have a patronised
         relationship. -->
    <xsl:if test=". = $collective_troupe">
      <field name="facet_entertainers_troupe">
        <xsl:value-of select="$entity_eats_id" />
      </field>
      <xsl:if test="not(../../eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$patronized][@range_entity=concat('entity-', $entity_eats_id)])">
        <field name="facet_entertainers_status">
          <xsl:text>unknown</xsl:text>
        </field>
      </xsl:if>
    </xsl:if>
    <!-- Entertainments -->
    <xsl:if test=". = $entertainment_type">
      <field name="facet_entertainments_type">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $entertainment_custom">
      <field name="facet_entertainments_custom">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $entertainment_animal">
      <field name="facet_entertainments_animal">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Locations -->
    <xsl:if test=". = $location_country">
      <field name="facet_locations_country">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $location_ecclesiastical_areas">
      <xsl:variable name="field">
        <xsl:choose>
          <xsl:when test=". = $location_ea_archdeaconry">
            <xsl:text>archdeaconry</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test=". = $location_ea_diocese">
            <xsl:text>diocese</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test=". = $location_ea_province">
            <xsl:text>province</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <field name="facet_locations_{$field}">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $location_county">
      <field name="facet_locations_county">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $location_duchy">
      <field name="facet_locations_duchy">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $location_populated_areas">
      <xsl:variable name="field">
        <xsl:choose>
          <xsl:when test=". = $location_pa_liberty">
            <xsl:text>liberty</xsl:text>
          </xsl:when>
          <xsl:when test=". = $location_pa_manor">
            <xsl:text>manor</xsl:text>
          </xsl:when>
          <xsl:when test=". = $location_pa_settlement">
            <xsl:variable name="name-initial" select="lower-case(substring(normalize-unicode(ancestor::eats:entity/eats:names/eats:name[@is_preferred='true'][1]/eats:assembled_form, 'NFD'), 1, 1))" />
            <xsl:text>settlement_</xsl:text>
            <xsl:choose>
              <xsl:when test="matches($name-initial, '[a-z]')">
                <xsl:value-of select="$name-initial" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>other</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test=". = $location_pa_ward">
            <xsl:text>ward</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <field name="facet_locations_{$field}">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- Feature locations. -->
    <xsl:if test=". = $location_features">
      <xsl:choose>
        <xsl:when test=". = $location_feature_arena">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Arena'" />
            <xsl:with-param name="type" select="'arena'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_bridge">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Bridge'" />
            <xsl:with-param name="type" select="'bridge'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_church">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Church'" />
            <xsl:with-param name="type" select="'church'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_church_house">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Church House'" />
            <xsl:with-param name="type" select="'church_house'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_gate">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Gate'" />
            <xsl:with-param name="type" select="'gate'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_guild_hall">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Guild Hall'" />
            <xsl:with-param name="type" select="'guild_hall'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_hospital">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Hospital'" />
            <xsl:with-param name="type" select="'hospital'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_inn_of_court">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Inn of Court'" />
            <xsl:with-param name="type" select="'inn_of_court'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_open_area">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Open Area'" />
            <xsl:with-param name="type" select="'open_area'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_place_of_punishment">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Place of Punishment'" />
            <xsl:with-param name="type" select="'place_of_punishment'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_playhouse">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Playhouse'" />
            <xsl:with-param name="type" select="'playhouse'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_property">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Property'" />
            <xsl:with-param name="type" select="'property'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_religious_house">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Religious House'" />
            <xsl:with-param name="type" select="'religious_house'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_residence">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Residence'" />
            <xsl:with-param name="type" select="'residence'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_school">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'School'" />
            <xsl:with-param name="type" select="'school'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_street">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Street'" />
            <xsl:with-param name="type" select="'street'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_town_hall">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Town Hall'" />
            <xsl:with-param name="type" select="'town_hall'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_victualling_house">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Victualling House'" />
            <xsl:with-param name="type" select="'victualling_house'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test=". = $location_feature_water_feature">
          <xsl:call-template name="add_location_feature_fields">
            <xsl:with-param name="entity_eats_id" select="$entity_eats_id" />
            <xsl:with-param name="name" select="'Water Feature'" />
            <xsl:with-param name="type" select="'water_feature'" />
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <!-- Material Objects -->
    <xsl:if test=". = $material_instrument">
      <field name="facet_materials_instrument">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_book">
      <field name="facet_materials_book">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_property">
      <field name="facet_materials_property">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_set">
      <field name="facet_materials_set">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_wagon">
      <field name="facet_materials_wagon">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_cloth">
      <field name="facet_materials_cloth">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_costume">
      <field name="facet_materials_costume">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_regalia">
      <field name="facet_materials_regalia">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $material_food">
      <field name="facet_materials_food">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <!-- People -->
    <xsl:if test=". = ($person_clergy, $person_commoner, $person_female,
                  $person_gentry, $person_unknown, $person_male,
                  $person_nobility, $person_royalty)">
      <xsl:variable name="name-initial" select="lower-case(substring(normalize-unicode(ancestor::eats:entity/eats:names/eats:name[@is_preferred='true'][1]/eats:assembled_form, 'NFD'), 1, 1))" />
      <xsl:variable name="initial-field">
        <xsl:choose>
          <xsl:when test="$name-initial = 'æ'">
            <xsl:text>a</xsl:text>
          </xsl:when>
          <xsl:when test="matches($name-initial, '[a-z]')">
            <xsl:value-of select="$name-initial" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>other</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <field name="facet_people_named_{$initial-field}">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
    <xsl:if test=". = $person_female">
      <field name="facet_people_gender">
        <xsl:text>female</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_male">
      <field name="facet_people_gender">
        <xsl:text>male</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_unknown">
      <field name="facet_people_gender">
        <xsl:text>unknown</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_royalty">
      <field name="facet_people_status">
        <xsl:text>royalty</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_nobility">
      <field name="facet_people_status">
        <xsl:text>nobility</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_gentry">
      <field name="facet_people_status">
        <xsl:text>gentry</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_clergy">
      <field name="facet_people_status">
        <xsl:text>clergy</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_commoner">
      <field name="facet_people_status">
        <xsl:text>commoners</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test=". = $person_family">
      <field name="facet_people_family">
        <xsl:value-of select="$entity_eats_id" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add_location_feature_fields">
    <xsl:param name="entity_eats_id"/>
    <xsl:param name="name"/>
    <xsl:param name="type"/>
    <field name="facet_locations_feature_{$type}">
      <xsl:value-of select="$entity_eats_id" />
    </field>
    <field name="facet_locations_feature_type">
      <xsl:value-of select="$name" />
    </field>
  </xsl:template>

</xsl:stylesheet>
