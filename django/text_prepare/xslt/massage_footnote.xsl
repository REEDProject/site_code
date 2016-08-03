<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert footnote markup into a more desirable form.

       Due to the duplication involved in having a different recursive
       token content model for footnotes, various bits of @-code
       markup that the grammar permits within footnotes are not
       correctly interpreted. Fix those up here. -->

  <!-- Deletions should be converted back to enclosing square
       parentheses. -->
  <xsl:template match="tei:note[@type='foot']//tei:del">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates />
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
