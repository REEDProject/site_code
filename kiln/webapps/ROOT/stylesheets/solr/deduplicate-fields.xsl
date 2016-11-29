<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove duplicate values for the same field. -->

  <xsl:template match="doc">
    <xsl:copy>
      <xsl:for-each-group select="field" group-by="@name">
        <xsl:for-each-group select="current-group()" group-by=".">
          <field name="{@name}">
            <xsl:value-of select="." />
          </field>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
