<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Normalise the markup of a TEI document to ease later
       processing. -->

  <xsl:variable name="prefix_defs" select="/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:listPrefixDef" />
  <!-- Create regexp for checking whether a URL starts with a prefix. -->
  <xsl:variable name="prefixes">
    <xsl:text>^(</xsl:text>
    <xsl:for-each select="$prefix_defs/tei:prefixDef/@ident">
      <xsl:value-of select="." />
      <xsl:if test="not(position() = last())">
        <xsl:text>|</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>):</xsl:text>
  </xsl:variable>

  <!-- Convert a tei:floatingText into tei:text. -->
  <xsl:template match="tei:floatingText">
    <tei:text>
      <xsl:apply-templates select="@*|node()" />
    </tei:text>
  </xsl:template>

  <!-- Expand URLs with a prefix into a full URL. -->
  <xsl:template match="@ana|@ref|@sameAs|@target">
    <xsl:variable name="context" select="parent::*" />
    <xsl:attribute name="{local-name()}">
      <xsl:for-each select="tokenize(., '\s+')">
        <xsl:choose>
          <xsl:when test="matches(., $prefixes)">
            <xsl:variable name="prefix" select="substring-before(., ':')" />
            <xsl:variable name="id" select="substring-after(., ':')" />
            <xsl:call-template name="expand-url">
              <xsl:with-param name="context" select="$context" />
              <xsl:with-param name="prefixDef" select="$prefix_defs/tei:prefixDef[@ident=$prefix]" />
              <xsl:with-param name="url" select="$id" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="expand-url">
    <xsl:param name="context" />
    <xsl:param name="prefixDef" />
    <xsl:param name="url" />
    <xsl:variable name="expanded-url"
                  select="replace($url, $prefixDef/@matchPattern,
                          $prefixDef/@replacementPattern)" />
    <xsl:variable name="base"
                  select="$context/ancestor::*[@xml:base][1]/@xml:base" />
    <xsl:choose>
      <xsl:when test="$base">
        <xsl:value-of select="substring-after(resolve-uri($expanded-url, concat('file://', $base)), 'file://')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$expanded-url" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
