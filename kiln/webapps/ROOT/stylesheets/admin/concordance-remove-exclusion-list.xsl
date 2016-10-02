<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove the words from the exclusion words list; Kathy wants to
       retain them because they contain proper nouns that are useful
       to her. -->

  <xsl:template match="exclusions/words[@type='exclusion']" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
