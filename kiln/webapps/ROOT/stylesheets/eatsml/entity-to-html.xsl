<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
      <xsl:variable name="record_data">
        <xsl:for-each select="$records">
          <xsl:variable name="geojson" select="id(str[@name='record_location_id'])/geojson[1]" />
          <xsl:apply-templates mode="geojson" select="$geojson">
            <xsl:with-param name="record-id" select="str[@name='document_id']" tunnel="yes" />
            <xsl:with-param name="record-title" select="arr[@name='document_title']/str[1]" tunnel="yes" />
          </xsl:apply-templates>
          <!-- There may not be geoJSON data for a location, in which
               case don't include stray commas that make the mapping
               fail entirely. -->
          <xsl:if test="$geojson">
            <xsl:text>,
            </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="normalize-space($record_data)">
        <xsl:text>{"type":"FeatureCollection",
        "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::4326"}},
        "features":[</xsl:text>
        <xsl:value-of select="$record_data" />
        <xsl:text>]}</xsl:text>
      </xsl:if>
      <xsl:text>];</xsl:text>
    </script>
  </xsl:template>

  <xsl:template name="create-source-location-variable">
    <script>
      <xsl:text>var source_location_geojson = [</xsl:text>
      <xsl:if test="$entity/geojson[@type='Point']">
        <xsl:text>{"type":"FeatureCollection",
        "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:EPSG::4326"}},
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
            <xsl:value-of select="$entity/geojson[1]/@idno" />
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
      <xsl:for-each select="$entity/name_extra">
        <xsl:copy-of select="node()"/>       
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
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

  <xsl:template name="display-external-data">
    <xsl:choose>
 <xsl:when test="$entity/external_data[not(contains(@href, 'ereed.library.utoronto.ca/geomap/')) and 
                                          not(contains(@href, 'ereed.org/geomap/')) and
                                          not(contains(@href, 'ereed.library.utoronto.ca/gis/'))]">
        <ul>
          <xsl:for-each select="$entity/external_data[not(contains(@href, 'ereed.library.utoronto.ca/geomap/')) and 
                                                     not(contains(@href, 'ereed.org/geomap/')) and
                                                     not(contains(@href, 'ereed.library.utoronto.ca/gis/'))]">
            <li>
              <a href="{@href}">
                <xsl:choose>
                  <xsl:when test="contains(@href, 'archive.org')">Archive.org</xsl:when>
                  <xsl:when test="contains(@href, 'britannica.com')">Britannica</xsl:when>
                  <xsl:when test="contains(@href, 'british-history.ac.uk')">British History Online</xsl:when>
                  <xsl:when test="contains(@href, 'emlot.library.utoronto.ca') or 
                                contains(@href, 'emlot.org')">Early Modern London Theatres</xsl:when>
                  <xsl:when test="contains(@href, 'historyofparliamentonline.org')">History of Parliament Online</xsl:when>
                  <xsl:when test="contains(@href, 'lostplays.folger.edu')">Lost Plays Database</xsl:when>
                  <xsl:when test="contains(@href, 'masl.library.utoronto.ca')">Mayors and Sheriffs of London</xsl:when>
                  <xsl:when test="contains(@href, 'odnb') or contains (@href, 'oxforddnb')">Oxford Dictionary of National Biography</xsl:when>
                  <xsl:when test="contains(@href, 'oed')">Oxford English Dictionary</xsl:when>
                  <xsl:when test="contains(@href, 'reed.library.utoronto.ca') or 
                                contains(@href, 'library2.utm.utoronto.ca/otra/reed/')">Patrons &amp; Performances</xsl:when>
                  <xsl:when test="contains(@href, 'poms.ac.uk')">People of Medieval Scotland</xsl:when>
                  <xsl:when test="contains(@href, 'viaf.org')">Virtual International Authority File (VIAF)</xsl:when>
                  <xsl:when test="contains(@href, 'wikidata.org')">Wikidata</xsl:when>
                  <xsl:when test="contains(@href, 'wikipedia.org')">Wikipedia</xsl:when>
                  <xsl:otherwise>Other External Source: (<xsl:value-of select="@href"/>)</xsl:otherwise>
                </xsl:choose>
              </a>

            </li>

          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <p>There are no links to external data for this entity at present.</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-related-entities">
    <table class="display related-entities-table responsive" cellspacing="0" width="100%">
      <tbody class="related-content">
        <xsl:for-each select="$entity/relationships/relationship">
          <xsl:sort select="name" />
          <tr>
            <td class="individual-related-entity">
              <xsl:value-of select="name" />
              <xsl:text> </xsl:text>
              <a href="{entity/@url}"><xsl:value-of select="entity" /></a>
              <xsl:if test="@certainty='none'">
                <xsl:text> (uncertain)</xsl:text>
              </xsl:if>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

</xsl:stylesheet>
