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

  <xsl:template match="tei:index[@indexName='record_type']/tei:term/kiln:added"
                mode="addition">
    <xsl:value-of select="tei:category/@xml:id" />
  </xsl:template>

  <xsl:template match="kiln:added/tei:category">
    <xsl:copy-of select="tei:catDesc/node()" />
  </xsl:template>

  <!-- Normalise the markup for document descriptions (which differ
       between MSS and printed sources) into a single format. -->

  <!-- QAZ: Handle printed sources. -->

  <xsl:template match="tei:bibl" mode="addition">
    <xsl:copy-of select="tei:title" />
    <tei:span type="shelfmark">
      <xsl:choose>
        <xsl:when test="tei:idno[@type='STC_number']">
          <xsl:apply-templates mode="addition" select="tei:idno[@type='publication']" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="tei:idno[@type='STC_number']" />
        </xsl:when>
        <xsl:when test="tei:idno[@type='author_surname']">
          <xsl:value-of select="tei:idno[@type='author_surname']" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="tei:idno[@type='short_title']" />
        </xsl:when>
      </xsl:choose>
    </tei:span>
    <!-- QAZ: typed notes. -->
    <xsl:copy-of select="tei:note/tei:p" />
  </xsl:template>

  <xsl:template match="tei:idno[@type='publication']" mode="addition">
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="tei:msDesc" mode="addition">
    <xsl:apply-templates mode="addition" select="tei:msIdentifier" />
    <xsl:copy-of select="tei:p" />
  </xsl:template>

  <xsl:template match="tei:msIdentifier" mode="addition">
    <tei:title>
      <xsl:value-of select="tei:msName" />
    </tei:title>
    <tei:span type="shelfmark">
      <xsl:apply-templates mode="addition" select="tei:repository" />
      <xsl:text>: </xsl:text>
      <xsl:value-of select="tei:idno[@type='shelfmark']" />
    </tei:span>
  </xsl:template>

  <xsl:template match="tei:repository" mode="addition">
    <xsl:apply-templates mode="addition" select="node()" />
  </xsl:template>

  <xsl:template match="@*|node()" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
