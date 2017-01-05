<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove any kiln:added elements (from
       extract-referenced-content.xsl) and massage the included
       content. -->

  <xsl:template match="kiln:added">
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="tei:index[@indexName='record_type']/tei:term/kiln:added">
    <xsl:value-of select="tei:category/@xml:id" />
  </xsl:template>

  <xsl:template match="kiln:added/tei:category">
    <xsl:copy-of select="tei:catDesc/node()" />
  </xsl:template>

  <!-- Normalise the markup for document descriptions (which differ
       between MSS and printed sources) into a single format. -->

  <!-- QAZ: Handle printed sources. -->

  <xsl:template match="tei:msDesc">
    <xsl:apply-templates select="tei:msIdentifier" />
    <xsl:copy-of select="tei:p" />
  </xsl:template>

  <xsl:template match="tei:msIdentifier">
    <tei:title>
      <xsl:value-of select="tei:msName" />
    </tei:title>
    <tei:span type="shelfmark">
      <xsl:apply-templates select="tei:repository" />
      <xsl:text>: </xsl:text>
      <xsl:value-of select="tei:idno[@type='shelfmark']" />
    </tei:span>
  </xsl:template>

  <xsl:template match="tei:repository">
    <xsl:choose>
      <xsl:when test="tei:abbr">
        <tei:choice>
          <tei:expan>
            <xsl:value-of select="tei:name" />
          </tei:expan>
          <xsl:copy-of select="tei:abbr" />
        </tei:choice>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="tei:name" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
