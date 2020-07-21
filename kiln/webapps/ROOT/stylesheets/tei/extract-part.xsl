<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract the TEI header and the identified part, wrapped in a
       tei:TEI/tei:text element.

       This is very similar to extract-record.xsl, but is for use with
       front and back divs, hence the slightly different wrapping.

       Records that are within a part are moved into an entirely new
       section (tei:TEI/records), leaving an element pointing to the
       new location. This is to avoid any footnotes, collation notes,
       etc in the records being displayed at the end of the part as
       well as at the end of each record. -->

  <xsl:param name="part-id" />

  <xsl:template match="tei:TEI">
    <xsl:variable name="part" select="id($part-id)" />
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="tei:teiHeader" />
      <tei:text>
        <xsl:apply-templates select="$part" />
      </tei:text>
      <records>
        <xsl:copy-of select="$part//tei:text[@type='record']" />
      </records>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:text[@type='record']">
    <record corresp="#{@xml:id}" />
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
