<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Sort records by place and date. -->

  <xsl:template match="tei:group">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="tei:text">
        <xsl:sort select="tei:body/tei:head/tei:rs[2]" />
        <xsl:sort select="tei:body/tei:head/tei:date/@when-iso |
                          tei:body/tei:head/tei:date/@from-iso" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
