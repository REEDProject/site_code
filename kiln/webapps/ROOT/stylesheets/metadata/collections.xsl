<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create a list of collections. -->

  <xsl:template match="/">
    <collections>
      <xsl:apply-templates select="files/file[starts-with(@xml_path, 'records/')]" />
    </collections>
  </xsl:template>

  <xsl:template match="file">
    <collection>
      <xsl:copy-of select="@id" />
      <xsl:value-of select="@title" />
    </collection>
  </xsl:template>

</xsl:stylesheet>
