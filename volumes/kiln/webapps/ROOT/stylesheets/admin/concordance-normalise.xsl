<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove inline markup and unwanted text from a TEI document,
       prior to generating a word list. Markup may interrupt words,
       and therefore needs to go. -->

  <xsl:template match="tei:ex">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:head[@type='sub']" />

  <xsl:template match="tei:note[not(@type='marginal')]" />

  <xsl:template match="tei:teiHeader" />

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
