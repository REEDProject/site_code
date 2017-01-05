<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Normalise the markup of a TEI document to ease later
       processing.
  -->

  <!-- Convert a tei:floatingText into tei:text. -->
  <xsl:template match="tei:floatingText">
    <tei:text>
      <xsl:apply-templates select="@*|node()" />
    </tei:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
