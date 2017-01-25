<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="entity" select="/aggregation/eats:entities/eats:entity[@selected='selected']" />

  <xsl:template name="create-related-location-variable">
    <xsl:param name="records" />
    <xsl:text>var related_location_geojson = [</xsl:text>
    <xsl:for-each select="$records">
      <xsl:if test="position() = 1">
        <xsl:text>{"type":"FeatureCollection",
        "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::3857"}},
        "features":[</xsl:text>
      </xsl:if>
      <xsl:variable name="geojson" select="id(str[@name='record_location_id'])/geojson" />
      <xsl:value-of select="$geojson" />
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
    <xsl:text>];
    </xsl:text>
  </xsl:template>

  <xsl:template name="create-source-location-variable">
    <xsl:text>var source_location_geojson = [</xsl:text>
    <xsl:if test="$entity/geojson[@type='Point']">
      <xsl:text>{"type":"FeatureCollection",
      "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::3857"}},
      "features":[</xsl:text>
      <xsl:value-of select="$entity/geojson" />
      <xsl:text>]}</xsl:text>
    </xsl:if>
    <xsl:text>];
    </xsl:text>
  </xsl:template>

  <xsl:template name="create-source-region-variable">
    <xsl:text>var source_region_geojson = [</xsl:text>
    <xsl:if test="$entity/geojson[@type!='Point']">
      <xsl:text>{"type":"FeatureCollection"
      ,"crs":{"type":"name","properties":{"name":"EPSG:3857"}}
      ,"features":[</xsl:text>
      <xsl:value-of select="$entity/geojson" />
      <xsl:text>]}</xsl:text>
    </xsl:if>
    <xsl:text>];
    </xsl:text>
  </xsl:template>

  <xsl:template name="display-entity-primary-name">
    <xsl:value-of select="$entity/primary_name" />
  </xsl:template>

  <xsl:template name="display-entity-title">
    <xsl:value-of select="$entity/title" />
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
