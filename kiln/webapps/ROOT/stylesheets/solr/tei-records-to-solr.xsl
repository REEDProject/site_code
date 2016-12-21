<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert a TEI document containing eREED records and
       full EATSML into a Solr index document. -->

  <xsl:param name="file-path" />

  <xsl:key name="entities-by-url" match="/aggregation/eatsml/entities/entity"
           use="@url" />

  <xsl:template match="/">
    <add>
      <!-- Treat each eREED record as its own Solr document. -->
      <xsl:apply-templates select="/aggregation/tei/tei:TEI/tei:text/tei:group/tei:text[@type='record']" />
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
        <field name="collection_id">
          <xsl:value-of select="/aggregation/tei/tei:TEI/@xml:id" />
        </field>
        <field name="record_title">
          <xsl:value-of select="normalize-space(tei:body/tei:head/tei:bibl/tei:title)" />
        </field>
        <field name="record_location">
        </field>
        <field name="record_shelfmark">
        </field>
        <field name="record_date">
          <!-- QAZ: handle date ranges by supplying a date for each
               year in the range. -->
          <xsl:value-of select="tei:body/tei:head/tei:date" />
        </field>
        <!-- QAZ: support having a display date and a date for
             indexing. Ties in to need to have the results table
             sortable on index date in attribute. -->
        <field name="text">
          <xsl:value-of select="normalize-space($free-text)" />
        </field>
        <xsl:apply-templates mode="record_type"
                             select="tei:index[@indexName='record_type']/tei:term" />
        <xsl:apply-templates mode="entity-mention"
                             select=".//tei:*[local-name()=('name', 'rs')]
                                     [@ref]" />
        <xsl:apply-templates mode="entity-facet"
                             select=".//tei:*[local-name()=('name', 'rs')]
                                     [@ref]" />
      </doc>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:term" mode="record_type">
    <field name="facet_record_type">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <!-- Used for the entity reference tool in the Oxygen EATS plugin. -->
  <xsl:template match="tei:*[@ref]" mode="entity-mention">
    <xsl:for-each select="tokenize(@ref, '\p{Z}+')">
      <field name="mentioned_entities">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:*[@ref]" mode="entity-facet">
    <!-- Copy the fields already defined for this entity in the
         EATS-derived data. -->
    <xsl:variable name="node" select="." />
    <!-- This is a kludge to provide a context node when calling
         key(), which is required. -->
    <xsl:for-each select="tokenize(@ref, '\s+')">
      <xsl:variable name="url" select="." />
      <xsl:for-each select="$node">
        <xsl:copy-of select="key('entities-by-url', $url)/field" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()" mode="free-text">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>
