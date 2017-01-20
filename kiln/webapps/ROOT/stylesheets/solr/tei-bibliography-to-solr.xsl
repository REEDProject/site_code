<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert the TEI bibliography into a Solr index document. -->

  <xsl:param name="file-path" />

  <xsl:template match="/">
    <add>
      <!-- Treat each tei:bibl as its own Solr document. -->
      <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div/tei:listBibl/tei:bibl" />
    </add>
  </xsl:template>

  <xsl:template match="tei:bibl">
    <doc>
      <field name="file_path">
        <xsl:value-of select="$file-path" />
      </field>
      <field name="document_id">
        <xsl:value-of select="@xml:id" />
      </field>
      <field name="document_type">
        <xsl:text>bibl</xsl:text>
      </field>
      <field name="collection_id">
        <xsl:value-of select="ancestor::tei:div/@xml:id" />
      </field>
      <xsl:apply-templates select="tei:title" />
      <xsl:apply-templates select="tei:author" />
      <xsl:apply-templates select="tei:editor" />
    </doc>
  </xsl:template>

  <xsl:template match="tei:author | tei:editor">
    <field name="bibl_author">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="tei:title">
    <field name="bibl_title">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

</xsl:stylesheet>
