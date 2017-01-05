<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="#all"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Expand @sameAs and @ana references. These typically replace the
       element carrying the referencing attribute with the content of
       the referenced element.

       The pipeline calling this must be following by an XInclude
       transformation to effect the actual inclusion. -->

  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:variable name="tei" select="/tei:TEI" />

  <xsl:template match="tei:text[@ana]" priority="10">
    <!-- The record types that are attached to the tei:text should not
         replace the content of the element. -->
    <xsl:variable name="context" select="." />
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <index indexName="record_type">
        <xsl:for-each select="tokenize(@ana, '\s+')">
          <tei:term>
            <xsl:call-template name="make-xinclude">
              <xsl:with-param name="context" select="$context" />
              <xsl:with-param name="url" select="." />
            </xsl:call-template>
          </tei:term>
        </xsl:for-each>
      </index>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:*[@ana]">
    <xsl:variable name="context" select="." />
    <xsl:for-each select="tokenize(@ana, '\s+')">
      <xsl:call-template name="make-xinclude">
        <xsl:with-param name="context" select="$context" />
        <xsl:with-param name="url" select="." />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:*[@sameAs]">
    <xsl:call-template name="make-xinclude">
      <xsl:with-param name="context" select="." />
      <xsl:with-param name="url" select="@sameAs" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@ana" />
  <xsl:template match="@sameAs" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="make-xinclude">
    <xsl:param name="context" />
    <xsl:param name="url" />
    <xsl:variable name="full-url">
      <xsl:choose>
        <xsl:when test="contains($url, ':')">
          <xsl:call-template name="expand-url">
            <xsl:with-param name="context" select="$context" />
            <xsl:with-param name="prefixDef" select="$tei/tei:teiHeader/tei:encodingDesc/tei:listPrefixDef/tei:prefixDef[@ident=substring-before($url, ':')][1]" />
            <xsl:with-param name="url" select="substring-after($url, ':')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$url" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- XInclude does not permit fragment identifiers in
         xi:include/@href (it's useless; the HTTP request does not
         pass the fragment). Convert to a querystring. -->
    <xsl:variable name="final-url" select="replace($full-url, '#', '?id=')" />
    <xi:include href="{kiln:url-for-match('ereed-extract-referenced-content',
                      ($final-url), 1)}" />
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
        <xsl:value-of select="resolve-uri($expanded-url, $base)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$expanded-url" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
