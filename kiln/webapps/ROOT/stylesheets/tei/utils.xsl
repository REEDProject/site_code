<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Utility templates. -->

  <xsl:template name="get-entity-id-from-url">
    <xsl:param name="eats-url" />
    <xsl:value-of select="substring-before(substring-after($eats-url, '/entity/'), '/')" />
  </xsl:template>

</xsl:stylesheet>
