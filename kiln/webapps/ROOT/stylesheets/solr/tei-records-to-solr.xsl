<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert a TEI document containing eREED records into a
       Solr index document. -->

  <xsl:param name="file-path" />

  <xsl:template match="/">
    <add>
      <!-- Treat each eREED record as its own Solr document. -->
      <xsl:apply-templates select="/tei:TEI/tei:text/tei:group/tei:text[@type='record']" />
    </add>
  </xsl:template>

  <xsl:template match="tei:text[@type='record']">
    <xsl:variable name="free-text">
      <xsl:apply-templates mode="free-text" select="." />
    </xsl:variable>
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <field name="file_path">
          <xsl:value-of select="$file-path" />
        </field>
        <field name="document_id">
          <xsl:value-of select="@xml:id" />
        </field>
        <field name="document_title">
          <xsl:value-of select="normalize-space(tei:body/tei:head)" />
        </field>
        <field name="text">
          <xsl:value-of select="normalize-space($free-text)" />
        </field>
        <xsl:apply-templates mode="entity-mention"
                             select=".//tei:*[local-name()=('name', 'rs')]
                                     [@ref]" />
      </doc>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:*[@ref]" mode="entity-mention">
    <xsl:for-each select="tokenize(@ref, '\p{Z}+')">
      <field name="mentioned_entities">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()" mode="free-text">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>
