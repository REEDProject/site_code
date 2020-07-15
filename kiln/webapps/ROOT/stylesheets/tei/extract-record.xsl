<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract the TEI header and the identified part, wrapped in a
       tei:TEI element. -->

  <xsl:param name="record-id" />

  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="tei:teiHeader" />
      <xsl:copy-of select="tei:facsimile" />
      <xsl:copy-of select="id($record-id)" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
