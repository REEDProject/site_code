<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to tidy tei:bibl and tei:msDesc elements. -->

  <!-- Replace tei:pb with |, to undo the effect of that
       transformation in the original parsing (that does not take into
       account the different context of these |, namely being inside a
       document description. -->
  <xsl:template match="tei:pb">
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
