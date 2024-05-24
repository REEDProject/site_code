<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Identify a single entity among all entities, by setting the
       "selected" attribute on it. The other entities remain. -->

  <xsl:param name="entity_eats_id" />

  <xsl:template match="eats:entities">
    <xsl:copy>
      <xsl:apply-templates select="eats:entity" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eats:entity[@eats_id=$entity_eats_id]">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:attribute name="selected" select="'selected'" />
      <xsl:copy-of select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="eats:entity">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
