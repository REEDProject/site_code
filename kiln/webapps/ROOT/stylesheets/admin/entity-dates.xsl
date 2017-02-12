<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../tei/utils.xsl" />
  <xsl:import href="../eatsml/entity-to-html.xsl" />

  <xsl:template match="collections">
    <xsl:for-each-group select=".//tei:rs[@ref]" group-by="@ref">
      <xsl:variable name="eats-id">
        <xsl:call-template name="get-entity-id-from-url">
          <xsl:with-param name="eats-url" select="@ref" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="entity-id">
        <xsl:text>entity-</xsl:text>
        <xsl:value-of select="$eats-id" />
      </xsl:variable>
      <tr>
        <td>
          <a href="{@ref}">
            <xsl:call-template name="display-entity-primary-name">
              <xsl:with-param name="entity" select="id($entity-id)" />
            </xsl:call-template>
          </a>
        </td>
        <td>
          <xsl:value-of select="$eats-id" />
        </td>
        <td>
          <ul>
            <xsl:variable name="record-dates" select="current-group()/ancestor::tei:text[@type='record']/tei:body/tei:head/tei:date" />
            <xsl:for-each select="distinct-values($record-dates)">
              <xsl:sort />
              <li>
                <xsl:value-of select="." />
              </li>
            </xsl:for-each>
          </ul>
        </td>
      </tr>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
