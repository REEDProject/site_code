<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract the content referenced by the id parameter, or the
       entire document if no id is supplied.

       Wraps partial content in a kiln:added element, which should be
       removed subsequently using the tidy-expanded-references.xsl
       XSLT. -->

  <xsl:param name="id" />

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$id">
        <kiln:added>
          <xsl:copy-of select="id($id)" />
        </kiln:added>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
