<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to remove unnecessary tei:ab elements. -->

  <!-- tei:gap as the only child of tei:ab should stand alone.

       It's likely that this could just be "if
       not(normalize-space(tei:ab))", but who knows what changes to
       the input XML may come. -->
  <xsl:template match="tei:ab[tei:gap]">
    <xsl:choose>
      <xsl:when test="count(node()) = 1">
        <xsl:apply-templates select="node()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>
