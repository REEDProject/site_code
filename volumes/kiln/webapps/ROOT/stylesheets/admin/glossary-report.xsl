<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Generate an HTML report noting problems in the glossary. -->

  <xsl:import href="../tei/to-html.xsl" />

  <xsl:template match="tei:sense">
    <xsl:variable name="issues">
      <xsl:apply-templates select="preceding-sibling::tei:form[1]" />
    </xsl:variable>
    <xsl:if test="normalize-space($issues)">
      <tr>
        <td>
          <p><xsl:value-of select="@xml:id" /></p>
        </td>
        <td>
          <ul>
            <xsl:copy-of select="$issues" />
          </ul>
        </td>
        <td>
          <p>
            <xsl:apply-templates mode="group" select="." />
          </p>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:form">
    <xsl:if test="not(tei:orth)">
      <li>
        <p><xsl:text>Missing tei:orth</xsl:text></p>
      </li>
    </xsl:if>
    <xsl:if test="not(tei:gram)">
      <li>
        <p><xsl:text>Missing tei:gram</xsl:text></p>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
