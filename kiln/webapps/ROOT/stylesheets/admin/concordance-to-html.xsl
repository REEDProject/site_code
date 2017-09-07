<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="cit">
    <li>
      <xsl:apply-templates />
      <xsl:text> [</xsl:text>
      <xsl:value-of select="@record" />
      <xsl:text>]</xsl:text>
    </li>
  </xsl:template>

  <xsl:template match="cits">
    <ul>
      <xsl:apply-templates select="cit">
        <xsl:sort select="@date" />
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <xsl:template match="concordance">
    <table class="tablesorter" id="concordance">
      <thead>
        <tr>
          <th scope="col">Word</th>
          <th scope="col">Language</th>
          <th scope="col">Count</th>
          <th scope="col">Citations</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="entry" />
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="entry">
    <tr>
      <td style="vertical-align: top;"><xsl:apply-templates select="w" /></td>
      <td style="vertical-align: top;"><xsl:apply-templates select="lang" /></td>
      <td style="vertical-align: top;"><xsl:apply-templates select="count" /></td>
      <td style="vertical-align: top;"><xsl:apply-templates select="cits" /></td>
    </tr>
  </xsl:template>

  <xsl:template match="term">
    <strong>
      <xsl:apply-templates />
    </strong>
  </xsl:template>

</xsl:stylesheet>
