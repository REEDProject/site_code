<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <TEICorpus>
      <xsl:apply-templates select="tei:TEI/tei:text/tei:group/tei:text" />
    </TEICorpus>
  </xsl:template>

  <xsl:template match="tei:text">
    <tei:TEI>
      <xsl:copy-of select="/tei:TEI/tei:teiHeader" />
      <xsl:copy-of select="." />
    </tei:TEI>
  </xsl:template>

</xsl:stylesheet>
