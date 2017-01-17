<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove any kiln:added elements (from
       extract-referenced-content.xsl) and massage the included
       content. -->

  <xsl:template match="kiln:added">
    <xsl:apply-templates mode="addition" select="node()" />
  </xsl:template>

  <xsl:template match="tei:bibl" mode="addition">
    <xsl:copy-of select="node()" />
  </xsl:template>

  <xsl:template match="tei:index[@indexName='record_type']/tei:term/kiln:added"
                mode="addition">
    <xsl:value-of select="tei:category/@xml:id" />
  </xsl:template>

  <xsl:template match="kiln:added/tei:category">
    <xsl:copy-of select="tei:catDesc/node()" />
  </xsl:template>

  <xsl:template match="@*|node()" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
