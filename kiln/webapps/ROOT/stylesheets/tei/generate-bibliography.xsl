<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Generate a TEI XML file of the bibliography organised into
       sections, based on the categories in the taxonomy. -->

  <xsl:template match="/">
    <xsl:apply-templates select="aggregation/bibliography/tei:TEI" />
  </xsl:template>

  <!-- The sole tei:div in bibliography.xml, to be converted into one
       div for each bibliography section. -->
  <xsl:template match="tei:div">
    <xsl:variable name="context" select="." />
    <!-- QAZ: This is rather backwards. Should expand the references
         in earlier pipeline, then group. -->
    <xsl:variable name="prefix" select="ancestor::tei:TEI/tei:teiHeader/tei:encodingDesc/tei:listPrefixDef/tei:prefixDef[starts-with(@replacementPattern, 'taxonomy.xml')]/@ident" />
    <xsl:for-each select="id('bibliography_sections')/tei:category">
      <xsl:variable name="category" select="concat(' ', $prefix, ':', @xml:id, ' ')" />
      <xsl:variable name="items">
        <listBibl>
          <xsl:apply-templates select="$context/tei:listBibl/tei:bibl[contains(concat(' ', @ana, ' '), $category)]" />
        </listBibl>
      </xsl:variable>
      <xsl:if test="normalize-space($items)">
        <div xml:id="{@xml:id}">
          <head>
            <xsl:value-of select="tei:catDesc" />
          </head>
          <xsl:copy-of select="$items" />
        </div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
