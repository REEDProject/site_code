<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Transform EATSML into a more condensed form suitable for use in
       RDF harvesting, annotating search facet results, etc. -->

  <xsl:template match="/">
    <eats:entities>
      <xsl:apply-templates select="eats:collection/eats:entities/eats:entity" />
    </eats:entities>
  </xsl:template>

  <xsl:template match="eats:entity">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:variable name="name">
        <xsl:apply-templates select="eats:names/eats:name[@is_preferred='true'][1]" />
      </xsl:variable>
      <xsl:variable name="primary-name">
        <xsl:choose>
          <xsl:when test="normalize-space($name)">
            <xsl:value-of select="$name" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="eats:names/eats:name[1]" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <primary_name>
        <plain>
          <xsl:value-of select="$primary-name" />
        </plain>
        <facet>
          <xsl:value-of select="$primary-name" />
          <!-- QAZ: Add date, etc. -->
        </facet>
      </primary_name>
    </xsl:copy>
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

  <xsl:template match="eats:existence/eats:dates">
    <dates>
      <xsl:apply-templates select="eats:date" />
    </dates>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
