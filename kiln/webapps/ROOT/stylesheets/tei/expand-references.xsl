<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Expand @sameAs and @ana references. These replace the element
       carrying the referencing attribute with the content of the
       referenced element.

       The pipeline calling this must be following by an XInclude
       transformation to effect the actual inclusion. -->

  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:template match="tei:*[@ana]">
    <xsl:call-template name="make-xinclude">
      <xsl:with-param name="url" select="@ana" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:*[@sameAs]">
    <xsl:call-template name="make-xinclude">
      <xsl:with-param name="url" select="@sameAs" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="make-xinclude">
    <xsl:param name="url" />
    <xsl:variable name="full-url">
      <xsl:choose>
        <xsl:when test="contains($url, ':')">
          <xsl:call-template name="expand-url">
            <xsl:with-param name="prefixDef" select="/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:listPrefixDef/tei:prefixDef[@ident=substring-before($url, ':')][1]" />
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
                      ($final-url))}" />
  </xsl:template>

  <xsl:template name="expand-url">
    <xsl:param name="prefixDef" />
    <xsl:param name="url" />
    <xsl:variable name="expanded-url"
                  select="replace($url, $prefixDef/@matchPattern,
                          $prefixDef/@replacementPattern)" />
    <xsl:choose>
      <xsl:when test="ancestor::*[@xml:base][1]">
        <xsl:value-of select="resolve-uri($expanded-url, ancestor::*[@xml:base][1]/@xml:base)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$expanded-url" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
