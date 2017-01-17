<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Expand @sameAs references in the code list.

       The TEI is not proper here; we want to replace the contents of
       a tei:repository with the contents of the element pointed to by
       @sameAs. This is actually a @copyOf - except that even then,
       tei:repository does not allow the markup included in the
       referenced element. -->

  <xsl:template match="tei:*[@sameAs]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="id(substring-after(@sameAs, '#'))/tei:catDesc/node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@sameAs" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
