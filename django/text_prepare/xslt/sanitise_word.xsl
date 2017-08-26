<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Sanitise the awful XML of docx content. -->

  <xsl:template match="w:noBreakHyphen">
    <!-- Convert non-breakings hyphens from empty elements to text, so
         that they are included in the text output of the python docx
         package. -->
    <w:t>
      <xsl:text>-</xsl:text>
    </w:t>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
