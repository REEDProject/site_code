<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove all non-teiHeader material that is not part of the
       record specified by the supplied record ID. -->

  <xsl:param name="record-id" />

  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="tei:teiHeader" />
      <xsl:copy-of select="tei:text/tei:group/tei:text[@xml:id=$record-id]" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
