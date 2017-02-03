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
           <singular>...</singular>
           <title>...</title>
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

  -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:variable name="floruit_date_period" select="'date_period-484'" />
  <xsl:variable name="circa_date_type" select="'date_type-489'" />
  <xsl:variable name="singular_name_type" select="'name_type-18607'" />
  <xsl:variable name="has_occupation_relationship_type" select="'entity_relationship_type-21008'" />
  <xsl:variable name="contains_relationship_type" select="'entity_relationship_type-502'" />
  <xsl:variable name="feature_entity_type" select="'entity_type-21368'" />
  <xsl:variable name="gis_base_url" select="'https://ereed.library.utoronto.ca/gis/place/'" />

  <xsl:template match="aggregation">
    <eats:entities>
      <xsl:apply-templates select="eats:collection/eats:entities/eats:entity" />
    </eats:entities>
  </xsl:template>

  <xsl:template match="eats:date" mode="title">
    <!-- Must handle circa and floruit dates, so the assembled form is
         sadly insufficient. -->
    <xsl:text>, </xsl:text>
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
      <xsl:text>c.</xsl:text>
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
        <xsl:if test="eats:entity_types/eats:entity_type/@entity_type=$feature_entity_type">
          <xsl:apply-templates mode="containing" select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_relationship_type][@domain_entity=$entity_id]" />
        </xsl:if>
      </primary_name>
      <xsl:apply-templates mode="singular" select="eats:names/eats:name[@name_type=$singular_name_type]" />
      <title>
        <xsl:value-of select="$name" />
        <!-- QAZ: Handle multiple dates. -->
        <xsl:apply-templates mode="title" select="eats:existences/eats:existence/eats:dates/eats:date" />
        <xsl:apply-templates mode="title" select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$has_occupation_relationship_type][@domain_entity=$entity_id]" />
        <xsl:if test="eats:entity_types/eats:entity_type/@entity_type=$feature_entity_type">
          <xsl:apply-templates mode="containing" select="eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_relationship_type][@domain_entity=$entity_id]" />
        </xsl:if>
      </title>
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
    <xsl:text>, </xsl:text>
    <xsl:apply-templates mode="name" select="id(@range_entity)" />
  </xsl:template>

  <xsl:template match="eats:entity_relationship" mode="title">
    <xsl:text>, </xsl:text>
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

  <xsl:template match="eats:subject_identifier" />

  <xsl:template match="eats:subject_identifier[starts-with(., $gis_base_url)]">
    <xsl:variable name="id" select="substring-before(substring-after(., $gis_base_url), '/')" />
    <xsl:variable name="geojson" select="id($id)" />
    <xsl:choose>
      <xsl:when test="$geojson">
        <geojson xml:id="{$id}">
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
      <xsl:when test="$date">
        <xsl:value-of select="$date" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$tpq">
          <xsl:value-of select="$tpq" />
          <xsl:if test="$taq">
            <xsl:text> and </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="$taq">
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
