<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract a single entity (and its related entities) from
       EATSML. -->

  <xsl:param name="entity_eats_id" />

  <xsl:template match="entities">
    <entities>
      <xsl:apply-templates select="eats:entity[@eats_id=$entity_eats_id]" />
    </entities>
  </xsl:template>

  <xsl:template match="eats:entity">
    <xsl:copy-of select="." />
    <related_entities>
      <!--<xsl:apply-templates mode="related" select="" />-->
    </related_entities>
  </xsl:template>

  <xsl:template match="eats:entity" mode="related">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
