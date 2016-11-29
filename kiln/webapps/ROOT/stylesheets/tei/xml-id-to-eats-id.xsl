<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Add an @eats_id with the value of the @xml_id. This allows for
       lookups in search results on facet values (which are
       identifiers) to not distinguish between those which are EATS
       entities and those which come from the code list. -->

  <xsl:template match="tei:*[@xml:id]">
    <xsl:copy>
      <xsl:attribute name="eats_id" select="@xml:id" />
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
