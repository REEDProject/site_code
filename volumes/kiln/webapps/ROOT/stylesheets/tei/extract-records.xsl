<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create XIncludes to extract the identified records, each
       wrapped in a tei:TEI element, and all grouped in a
       tei:TEICorpus element. -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:param name="record-ids" />

  <xsl:template match="TEICorpus/tei:TEI">
    <xsl:variable name="id-start">
      <xsl:value-of select="@xml:id" />
      <xsl:text>-</xsl:text>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="tei:teiHeader" />
      <xsl:for-each select="/aggregation/h:request/h:requestParameters/h:parameter[@name='ids']/h:value[starts-with(., $id-start)]">
        <xsl:copy-of select="id(.)" />
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
