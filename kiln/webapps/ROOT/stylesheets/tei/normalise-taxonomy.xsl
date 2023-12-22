<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="#all"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Transform taxonomy.xml's markup into a standard form that
       eliminates differences between printed sources and
       manuscripts. -->

  <xsl:template match="tei:ab">
    <tei:p>
      <xsl:apply-templates select="@*|node()" />
    </tei:p>
  </xsl:template>

  <xsl:template match="tei:bibl">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
      <xsl:choose>
        <xsl:when test="tei:idno[@type='pubNumber']">
          <tei:span type="shelfmark" subtype="text">
            <xsl:apply-templates mode="shelfmark-text" select="tei:idno[@type='publication']" />
            <xsl:text>: </xsl:text>
            <xsl:value-of select="tei:idno[@type='pubNumber']" />
          </tei:span>
          <tei:span type="shelfmark" subtype="html">
            <xsl:apply-templates mode="shelfmark-html" select="tei:idno[@type='publication']" />
            <xsl:text>: </xsl:text>
            <xsl:value-of select="tei:idno[@type='pubNumber']" />
          </tei:span>
        </xsl:when>
        <xsl:when test="tei:idno[@type='authorSurname']">
          <tei:span type="shelfmark" subtype="text">
            <xsl:value-of select="tei:idno[@type='authorSurname']" />
            <xsl:text>: </xsl:text>
            <xsl:value-of select="tei:idno[@type='shortTitle']" />
          </tei:span>
          <tei:span type="shelfmark" subtype="html">
            <xsl:value-of select="tei:idno[@type='authorSurname']" />
            <xsl:text>: </xsl:text>
            <xsl:value-of select="tei:idno[@type='shortTitle']" />
          </tei:span>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno | tei:repository" mode="shelfmark-html">
    <xsl:choose>
      <xsl:when test="tei:choice">
        <abbr title="{tei:choice/tei:expan}">
          <xsl:choose>
            <xsl:when test="normalize-space()='STC Pollard and Redgrave (eds), Short-Title Catalogue'">
              <i><xsl:value-of select="tei:choice/tei:abbr" /></i>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tei:choice/tei:abbr" />    
            </xsl:otherwise>
          </xsl:choose>
        </abbr>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:idno | tei:repository" mode="shelfmark-text">
    <xsl:choose>
      <xsl:when test="tei:choice">
        <xsl:value-of select="tei:choice/tei:abbr" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:msDesc">
    <tei:bibl>
      <xsl:apply-templates select="@*|node()" />
    </tei:bibl>
  </xsl:template>

  <xsl:template match="tei:msIdentifier">
    <tei:span type="shelfmark" subtype="text">
      <xsl:apply-templates mode="shelfmark-text" select="tei:repository" />
      <xsl:text>: </xsl:text>
      <xsl:value-of select="tei:idno[@type='shelfmark']" />
    </tei:span>
    <tei:span type="shelfmark" subtype="html">
      <xsl:apply-templates mode="shelfmark-html" select="tei:repository" />
      <xsl:text>: </xsl:text>
      <xsl:value-of select="tei:idno[@type='shelfmark']" />
    </tei:span>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:msName">
    <tei:title>
      <xsl:apply-templates />
    </tei:title>
  </xsl:template>

  <xsl:template match="tei:bibl/tei:note">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:note/tei:p">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:if test="../@type">
        <xsl:attribute name="type" select="../@type" />
      </xsl:if>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:title/@type[. = 'edName']" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
