<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

  <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl" />

  <xsl:variable name="record_title" select="/aggregation/tei:TEI/tei:text/tei:body/tei:head/tei:bibl/tei:title" />

  <xsl:template match="tei:add[@place='above']">
    <xsl:text>⸢</xsl:text>
    <xsl:apply-templates />
    <xsl:text>⸣</xsl:text>
  </xsl:template>

  <xsl:template match="tei:add[@place='below']">
    <xsl:text>⸤</xsl:text>
    <xsl:apply-templates />
    <xsl:text>⸥</xsl:text>
  </xsl:template>

  <xsl:template match="tei:damage">
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates />
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:ex">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:gap[@extent]">
    <xsl:for-each select="1 to @extent">
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:gap[@reason='omitted']">
    <xsl:text>...</xsl:text>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:note[@type='foot']">
    <span class="footnote tag" note="{generate-id()}"></span>
  </xsl:template>

  <xsl:template match="tei:note[@type='foot']" mode="group">
    <li note="{generate-id()}">
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="tei:space">
    <i>(blank)</i>
  </xsl:template>

</xsl:stylesheet>
