<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Transform EATSML into a more condensed form suitable for use in
       RDF harvesting, annotating search facet results, etc.

       Output:

       <eats:entities>
         <eats:entity xml:id="" eats_id="" url="EATS URL">
           <primary_name>...</primary_name>
           <name_extra>...</name_extra>
           <singular>...</singular>
           <date type="details">...</date>
           <name_extra type="details">...</name_extra>
           <occupation type="details">...</occupation>
           <container type="details">...</container>
           <relationships>
             <relationship>
               <name>...</name>
               <entity url="HTML representation URL">...</entity>
             </relationship>
           </relationships>
           <geojson>...</geojson
         </eats:entity>
         ...
       </eats:entities>

       Elements with @type="details" are used as extra information
       when displaying an entity name in its fullest form. The
       name_extra elements contain extra information to include when
       displaying just the name.

       A name_extra[@type='details'] element contains information that
       should be displayed under both circumstances.

  -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <!-- QAZ: Refactor with variables in solr/eatsml-to-solr-facets.xsl. -->
  <xsl:variable name="floruit_date_period" select="'date_period-484'" />
  <xsl:variable name="circa_date_type" select="'date_type-489'" />
  <xsl:variable name="singular_name_type" select="'name_type-18607'" />
  <xsl:variable name="has_occupation_relationship_type"
                select="'entity_relationship_type-21008'" />
  <xsl:variable name="contains_relationship_type"
                select="'entity_relationship_type-502'" />
  <xsl:variable name="occupational_guild_entity_type"
                select="'entity_type-48092'" />
  <xsl:variable name="religious_guild_entity_type"
                select="'entity_type-48094'" />
  <xsl:variable name="location_county_entity_type" select="'entity_type-543'" />
  <xsl:variable name="location_duchy_entity_type"
                select="'entity_type-259881'" />
  <xsl:variable name="location_ea_archdeaconry_entity_type"
                select="'entity_type-249050'" />
  <xsl:variable name="location_ea_diocese_entity_type" select="'entity_type-249052'" />
  <xsl:variable name="location_ea_province_entity_type" select="'entity_type-249054'" />
  <xsl:variable name="location_feature_entity_type" select="'entity_type-21368'" />
  <xsl:variable name="location_feature_arena_entity_type" select="'entity_type-4831'" />
  <xsl:variable name="location_feature_bridge_entity_type" select="'entity_type-247662'" />
  <xsl:variable name="location_feature_church_entity_type" select="'entity_type-4833'" />
  <xsl:variable name="location_feature_church_house_entity_type"
                select="'entity_type-4835'" />
  <xsl:variable name="location_feature_gate_entity_type" select="'entity_type-247664'" />
  <xsl:variable name="location_feature_guild_hall_entity_type"
                select="'entity_type-4839'" />
  <xsl:variable name="location_feature_hospital_entity_type"
                select="'entity_type-247666'" />
  <xsl:variable name="location_feature_inn_of_court_entity_type"
                select="'entity_type-4843'" />
  <xsl:variable name="location_feature_open_area_entity_type"
                select="'entity_type-4845'" />
  <xsl:variable name="location_feature_place_of_punishment_entity_type"
                select="'entity_type-247670'" />
  <xsl:variable name="location_feature_playhouse_entity_type"
                select="'entity_type-4851'" />
  <xsl:variable name="location_feature_property_entity_type"
                select="'entity_type-247674'" />
  <xsl:variable name="location_feature_religious_house_entity_type"
                select="'entity_type-551'" />
  <xsl:variable name="location_feature_residence_entity_type"
                select="'entity_type-247672'" />
  <xsl:variable name="location_feature_school_entity_type" select="'entity_type-4847'" />
  <xsl:variable name="location_feature_street_entity_type"
                select="'entity_type-247676'" />
  <xsl:variable name="location_feature_town_hall_entity_type"
                select="'entity_type-4853'" />
  <xsl:variable name="location_feature_victualling_house_entity_type"
                select="'entity_type-4841'" />
  <xsl:variable name="location_feature_water_feature_entity_type"
                select="'entity_type-247678'" />
  <xsl:variable name="location_pa_liberty_entity_type" select="'entity_type-248915'" />
  <xsl:variable name="location_pa_manor_entity_type" select="'entity_type-248917'" />
  <xsl:variable name="location_pa_settlement_entity_type" select="'entity_type-248913'" />
  <xsl:variable name="location_pa_ward_entity_type" select="'entity_type-248919'" />
  <xsl:variable name="container_location_entity_types"
                select="($location_county_entity_type, $location_duchy_entity_type, $location_ea_archdeaconry_entity_type, $location_ea_diocese_entity_type, $location_ea_province_entity_type, $location_feature_entity_type, $location_feature_arena_entity_type, $location_feature_bridge_entity_type, $location_feature_church_entity_type, $location_feature_church_house_entity_type, $location_feature_gate_entity_type, $location_feature_guild_hall_entity_type, $location_feature_hospital_entity_type, $location_feature_inn_of_court_entity_type, $location_feature_open_area_entity_type, $location_feature_place_of_punishment_entity_type, $location_feature_playhouse_entity_type, $location_feature_property_entity_type, $location_feature_religious_house_entity_type, $location_feature_residence_entity_type, $location_feature_school_entity_type, $location_feature_street_entity_type, $location_feature_town_hall_entity_type, $location_feature_victualling_house_entity_type, $location_feature_water_feature_entity_type, $location_pa_liberty_entity_type, $location_pa_manor_entity_type, $location_pa_settlement_entity_type, $location_pa_ward_entity_type)" />
  <xsl:variable name="troupe_entity_type" select="'entity_type-12619'" />
  <xsl:variable name="gis_base_url" select="'https://ereed.org/geomap/places/'" />
  <xsl:variable name="show_containing" select="($occupational_guild_entity_type, $religious_guild_entity_type, $container_location_entity_types)" />
  <xsl:variable name="calendar_entity_types" select="('entity_type-4857', 'entity_type-4855')" />
  <xsl:variable name="no_occupation_in_name_types"
                select="($troupe_entity_type, $occupational_guild_entity_type)" />

  <xsl:template match="aggregation">
    <eats:entities>
      <xsl:apply-templates select="eats:collection/eats:entities/eats:entity" />
    </eats:entities>
  </xsl:template>

  <xsl:template match="eats:date" mode="title">
    <!-- Must handle circa and floruit dates, so the assembled form is
         sadly insufficient. -->
    <xsl:if test="@date_period=$floruit_date_period">
      <xsl:text>fl. </xsl:text>
    </xsl:if>
    <xsl:variable name="point">
      <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='point']" />
    </xsl:variable>
    <xsl:variable name="point_tpq">
      <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='point_tpq']" />
    </xsl:variable>
    <xsl:variable name="point_taq">
      <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='point_taq']" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($point) or normalize-space($point_tpq) or normalize-space($point_taq)">
        <xsl:call-template name="assemble-date">
          <xsl:with-param name="date" select="$point" />
          <xsl:with-param name="tpq" select="$point_tpq" />
          <xsl:with-param name="taq" select="$point_taq" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="start">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='start']" />
        </xsl:variable>
        <xsl:variable name="start_tpq">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='start_tpq']" />
        </xsl:variable>
        <xsl:variable name="start_taq">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='start_taq']" />
        </xsl:variable>
        <xsl:variable name="end">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='end']" />
        </xsl:variable>
        <xsl:variable name="end_tpq">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='end_tpq']" />
        </xsl:variable>
        <xsl:variable name="end_taq">
          <xsl:apply-templates select="eats:date_parts/eats:date_part[@type='end_taq']" />
        </xsl:variable>
        <xsl:variable name="start_date">
          <xsl:call-template name="assemble-date">
            <xsl:with-param name="date" select="$start" />
            <xsl:with-param name="tpq" select="$start_tpq" />
            <xsl:with-param name="taq" select="$start_taq" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="end_date">
          <xsl:call-template name="assemble-date">
            <xsl:with-param name="date" select="$end" />
            <xsl:with-param name="tpq" select="$end_tpq" />
            <xsl:with-param name="taq" select="$end_taq" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="date">
          <xsl:value-of select="$start_date" />
          <xsl:text> – </xsl:text>
          <xsl:value-of select="$end_date" />
        </xsl:variable>
        <xsl:value-of select="normalize-space($date)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eats:date_part">
    <xsl:choose>
      <xsl:when test="@type = ('point_tpq', 'start_tpq', 'end_tpq')">
        <xsl:text>at or after </xsl:text>
      </xsl:when>
      <xsl:when test="@type = ('point_taq', 'start_taq', 'end_taq')">
        <xsl:text>at or before </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@date_type=$circa_date_type">
      <xsl:text><i>c</i> </xsl:text>
    </xsl:if>
    <xsl:value-of select="eats:raw" />
    <xsl:if test="@certainty != 'full'">
      <xsl:text>?</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eats:entity">
    <xsl:variable name="entity_id" select="@xml:id" />
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:variable name="name">
        <xsl:apply-templates mode="name" select="." />
      </xsl:variable>
      <primary_name>
        <xsl:value-of select="$name" />
      </primary_name>
      <xsl:if test="eats:entity_types/eats:entity_type/@entity_type=$show_containing">
        <name_extra>
          <xsl:apply-templates mode="containing" select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_relationship_type][@domain_entity=$entity_id]" />
        </name_extra>
      </xsl:if>
      <xsl:if test="not(eats:entity_types/eats:entity_type/@entity_type=$no_occupation_in_name_types)">
        <xsl:for-each select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$has_occupation_relationship_type][@domain_entity=$entity_id]">
          <name_extra>
            <xsl:apply-templates mode="title" select="." />
          </name_extra>
        </xsl:for-each>
      </xsl:if>
      <!-- Provide dates for calendar days in short name. -->
      <xsl:if test="eats:entity_types/eats:entity_type/@entity_type=$calendar_entity_types">
        <name_extra>
        <xsl:apply-templates mode="title" select="eats:existences/eats:existence/eats:dates/eats:date" />
        </name_extra>
      </xsl:if>
      <xsl:apply-templates mode="singular" select="eats:names/eats:name[@name_type=$singular_name_type]" />
      <date type="details">
        <!-- QAZ: Handle multiple dates. -->
        <xsl:apply-templates mode="title" select="eats:existences/eats:existence/eats:dates/eats:date" />
      </date>
      <!-- An entity may have multiple occupations. -->
      <xsl:for-each select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$has_occupation_relationship_type][@domain_entity=$entity_id]">
        <occupation>
          <xsl:if test="not(../../eats:entity_types/eats:entity_type/@entity_type=$occupational_guild_entity_type)">
            <xsl:attribute name="type" select="'details'"/>
          </xsl:if>
          <xsl:apply-templates mode="title" select="." />
        </occupation>
      </xsl:for-each>
      <container type="details">
        <xsl:apply-templates mode="containing" select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_relationship_type][@domain_entity=$entity_id]" />
      </container>
      <relationships>
        <xsl:apply-templates select="eats:entity_relationships/eats:entity_relationship">
          <xsl:with-param name="entity_id" select="$entity_id" />
        </xsl:apply-templates>
      </relationships>
      <xsl:apply-templates select="eats:subject_identifiers/eats:subject_identifier">
        <xsl:with-param name="name" select="$name" tunnel="yes" />
        <xsl:with-param name="eats-id" select="@eats_id" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eats:entity" mode="name">
    <xsl:variable name="name">
      <xsl:apply-templates select="eats:names/eats:name[@is_preferred='true'][1]" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($name)">
        <xsl:value-of select="$name" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="eats:names/eats:name[1]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eats:entity_relationship">
    <xsl:param name="entity_id" />
    <xsl:variable name="relationship" select="id(@entity_relationship_type)" />
    <relationship>
      <xsl:copy-of select="@certainty" />
      <name>
        <xsl:choose>
          <xsl:when test="@domain_entity = $entity_id">
            <xsl:value-of select="$relationship/eats:name" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$relationship/eats:reverse_name" />
          </xsl:otherwise>
        </xsl:choose>
      </name>
      <entity>
        <xsl:choose>
          <xsl:when test="@domain_entity = $entity_id">
            <xsl:variable name="related_entity" select="id(@range_entity)" />
            <xsl:call-template name="process-related-entity">
              <xsl:with-param name="entity" select="$related_entity" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="related_entity" select="id(@domain_entity)" />
            <xsl:call-template name="process-related-entity">
              <xsl:with-param name="entity" select="$related_entity" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </entity>
    </relationship>
  </xsl:template>

  <xsl:template match="eats:entity_relationship" mode="containing">
    <xsl:apply-templates mode="name" select="id(@range_entity)" />
  </xsl:template>

  <xsl:template match="eats:entity_relationship" mode="title">
    <xsl:apply-templates mode="singular" select="id(@range_entity)/eats:names/eats:name[@name_type=$singular_name_type]" />
  </xsl:template>

  <xsl:template match="eats:name">
    <xsl:choose>
      <xsl:when test="normalize-space(eats:display_form)">
        <xsl:value-of select="eats:display_form" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="eats:assembled_form" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eats:name" mode="singular">
    <singular>
      <xsl:apply-templates select="." />
    </singular>
  </xsl:template>

  <xsl:template match="eats:subject_identifier">
    <external_data href="{.}"/>
  </xsl:template>

  <xsl:template match="eats:subject_identifier[starts-with(., $gis_base_url)]">
    <xsl:variable name="id" select="substring-before(substring-after(., $gis_base_url), '/')" />
    <xsl:variable name="geojson" select="id(concat('id-', $id))" />
    <xsl:choose>
      <xsl:when test="$geojson">
        <geojson idno="{$id}">
          <xsl:copy-of select="$geojson/@type" />
          <xsl:apply-templates mode="geojson" select="$geojson" />
        </geojson>
      </xsl:when>
      <xsl:otherwise>
        <ERROR>
          <xsl:text>Missing GIS data for URL: </xsl:text>
          <xsl:value-of select="." />
        </ERROR>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eats_name" mode="geojson">
    <xsl:param name="name" tunnel="yes" />
    <xsl:value-of select="$name" />
  </xsl:template>

  <xsl:template match="eats_url" mode="geojson">
    <xsl:param name="eats-id" tunnel="yes" />
    <xsl:value-of select="kiln:url-for-match('ereed-entity-display-html', ($eats-id), 0)" />
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@*|node()" mode="geojson">
    <xsl:copy>
      <xsl:apply-templates mode="geojson" select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="assemble-date">
    <xsl:param name="date" />
    <xsl:param name="tpq" />
    <xsl:param name="taq" />
    <xsl:choose>
      <xsl:when test="normalize-space($date)">
        <xsl:value-of select="$date" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="normalize-space($tpq)">
          <xsl:value-of select="$tpq" />
          <xsl:if test="normalize-space($taq)">
            <xsl:text> and </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="normalize-space($taq)">
          <xsl:value-of select="$taq" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process-related-entity">
    <xsl:param name="entity" />
    <xsl:attribute name="url">
      <xsl:value-of select="kiln:url-for-match('ereed-entity-display-html', ($entity/@eats_id), 0)" />
    </xsl:attribute>
    <xsl:choose>
      <xsl:when test="@entity_relationship_type=$has_occupation_relationship_type and @range_entity=$entity/@xml:id">
        <xsl:apply-templates mode="singular" select="$entity/eats:names/eats:name[@name_type=$singular_name_type]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="name" select="$entity" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
