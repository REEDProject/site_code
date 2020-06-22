<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to add automatically generated xml:id attributes to
       various elements, and to fix up references and anchors created
       during earlier processing. -->

  <!-- Supplied base xml:id used both for the TEI document as a whole
       and as a prefix for all other xml:ids to ensure uniqueness
       across the entire collection. -->
  <xsl:param name="base_id" />

  <xsl:template match="tei:text[@type='record']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:variable name="id_prefix">
        <xsl:value-of select="$base_id" />
        <xsl:text>-r</xsl:text>
        <xsl:value-of select="generate-id()" />
      </xsl:variable>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$id_prefix" />
      </xsl:attribute>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="id_prefix" select="$id_prefix" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[@type='transcription']">
    <xsl:param name="id_prefix" />
    <xsl:call-template name="copy-element-add-id">
      <xsl:with-param name="id_prefix" select="$id_prefix" />
      <xsl:with-param name="id" select="concat($id_prefix, '-transcription')" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:call-template name="copy-element-add-id">
      <xsl:with-param name="id" select="$base_id" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:param name="id_prefix" />
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="id_prefix" select="$id_prefix" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="copy-element-add-id">
    <xsl:param name="id" />
    <xsl:param name="id_prefix" />
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$id" />
      </xsl:attribute>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="id_prefix" select="$id_prefix" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
