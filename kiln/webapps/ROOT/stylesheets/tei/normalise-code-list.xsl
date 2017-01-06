<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="tei:catDesc[tei:abbr]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <tei:choice>
        <xsl:apply-templates select="tei:abbr" />
        <tei:expan>
          <xsl:apply-templates select="tei:name" />
        </tei:expan>
      </tei:choice>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
