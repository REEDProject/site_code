<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="entity" select="/aggregation/eats:entities/eats:entity" />

  <xsl:template name="display-entity-primary-name">
    <xsl:value-of select="$entity/primary_name" />
  </xsl:template>

  <xsl:template name="display-entity-title">
    <xsl:value-of select="$entity/title" />
  </xsl:template>

</xsl:stylesheet>
