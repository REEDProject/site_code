<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="utf-8" />

  <xsl:template match="concordance">
    <xsl:text>word,language,count,date,record,context</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="entry" />
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="entry" select="." />
    <xsl:for-each select="cits/cit">
      <xsl:value-of select="$entry/w" />
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$entry/lang" />
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$entry/count" />
      <xsl:text>,</xsl:text>
      <xsl:value-of select="@date" />
      <xsl:text>,</xsl:text>
      <xsl:value-of select="@record" />
      <xsl:text>,"</xsl:text>
      <xsl:value-of select="replace(normalize-space(.), '&quot;', '&quot;&quot;')" />
      <xsl:text>"
</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
