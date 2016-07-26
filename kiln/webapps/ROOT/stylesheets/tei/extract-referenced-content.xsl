<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract the content referenced by the id parameter (but not the
       identified element itself), or the entire document if no id is
       supplied.

       Wraps partial content in a kiln:added element, which should be
       removed subsequently using the tidy-expanded-references.xsl
       XSLT. -->

  <xsl:param name="id" />

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$id">
        <kiln:added>
          <xsl:apply-templates select="id($id)/node()" />
        </kiln:added>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
