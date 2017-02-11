<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:variable name="entity" select="/aggregation/eats:entities/eats:entity[@selected='selected']" />

  <xsl:template match="feature|geojson" mode="geojson">
    <xsl:apply-templates mode="geojson" />
  </xsl:template>

  <xsl:template match="record_title" mode="geojson">
    <xsl:param name="record-title" tunnel="yes" />
    <xsl:value-of select="$record-title" />
  </xsl:template>

  <xsl:template match="record_url" mode="geojson">
    <xsl:param name="record-id" tunnel="yes" />
    <xsl:value-of select="kiln:url-for-match('ereed-record-display-html', ($record-id), 0)" />
  </xsl:template>

  <xsl:template match="@*|node()" mode="geojson">
    <xsl:copy>
      <xsl:apply-templates mode="geojson" select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="create-related-location-variable">
    <xsl:param name="records" />
    <script>
      <xsl:text>var related_location_geojson = [</xsl:text>
      <xsl:for-each select="$records">
        <xsl:if test="position() = 1">
          <xsl:text>{"type":"FeatureCollection",
          "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::3857"}},
          "features":[</xsl:text>
        </xsl:if>
        <xsl:variable name="geojson" select="id(str[@name='record_location_id'])/geojson" />
        <xsl:apply-templates mode="geojson" select="$geojson">
          <xsl:with-param name="record-id" select="str[@name='document_id']" tunnel="yes" />
          <xsl:with-param name="record-title" select="arr[@name='document_title']/str[1]" tunnel="yes" />
        </xsl:apply-templates>
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>]}</xsl:text>
          </xsl:when>
          <!-- There may not be geoJSON data for a location, in which
               case don't include stray commas that make the mapping
               fail entirely. -->
          <xsl:when test="$geojson">
            <xsl:text>,
            </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:text>];</xsl:text>
    </script>
  </xsl:template>

  <xsl:template name="create-source-location-variable">
    <script>
      <xsl:text>var source_location_geojson = [</xsl:text>
      <xsl:if test="$entity/geojson[@type='Point']">
        <xsl:text>{"type":"FeatureCollection",
        "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::3857"}},
        "features":[</xsl:text>
        <xsl:value-of select="$entity/geojson" />
        <xsl:text>]}</xsl:text>
      </xsl:if>
      <xsl:text>];</xsl:text>
    </script>
  </xsl:template>

  <xsl:template name="create-source-region-variable">
    <xsl:choose>
      <xsl:when test="$entity/geojson[@type!='Point']">
        <script>
          <xsl:attribute name="src">
            <xsl:value-of select="$kiln:assets-path" />
            <xsl:text>/scripts/leaflet/regions/</xsl:text>
            <xsl:value-of select="$entity/geojson/@xml:id" />
            <xsl:text>.js</xsl:text>
          </xsl:attribute>
        </script>
      </xsl:when>
      <xsl:otherwise>
        <script>
          <xsl:text>var source_region_geojson = [];</xsl:text>
        </script>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-entity-primary-name">
    <xsl:param name="entity" select="$entity" />
    <xsl:value-of select="$entity/primary_name" />
  </xsl:template>

  <xsl:template name="display-entity-primary-name-plus">
    <xsl:param name="entity" select="$entity" />
    <xsl:call-template name="display-entity-primary-name">
      <xsl:with-param name="entity" select="$entity" />
    </xsl:call-template>
    <xsl:if test="$entity/name_extra">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$entity/name_extra" />
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-entity-details">
    <xsl:for-each select="$entity/*[@type='details'][normalize-space()]">
      <span style="font-size: smaller">
        <xsl:if test="position() = 1">
          <br/><xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:value-of select="." />
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>, </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="display-related-entities">
    <table class="display related-entities-table responsive" cellspacing="0" width="100%">
      <tbody class="related-content">
        <xsl:for-each select="$entity/relationships/relationship">
          <tr>
            <td class="individual-related-entity">
              <xsl:value-of select="name" />
              <xsl:text> </xsl:text>
              <a href="{entity/@url}"><xsl:value-of select="entity" /></a>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

</xsl:stylesheet>
