<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to add a teiHeader. -->

  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <teiHeader>
        <fileDesc>
          <titleStmt>
          </titleStmt>
          <sourceDesc>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <listPrefixDef>
            <prefixDef ident="eats" matchPattern="([0-9]+)"
                       replacementPattern="https://ereed.org/eats/entity/$1/">
              <p>URIs using the <code>eats</code> prefix are references to EATS entities.</p>
            </prefixDef>
            <prefixDef ident="gloss" matchPattern="([\S]+)"
                       replacementPattern="../glossary.xml#$1">
              <p>Private URIs using the <code>gloss</code> prefix are pointers to entities in the glossary.xml file. For example, <code>gloss:histrio-1</code> dereferences to <code>glossary.xml#histrio-1</code>.</p>
            </prefixDef>
            <prefixDef ident="taxon" matchPattern="([A-Za-z0-9_-]+)"
                       replacementPattern="../taxonomy.xml#$1">
              <p>Private URIs using the <code>taxon</code> prefix are pointers to entities in the taxonomy.xml file. For example, <code>taxon:church</code> dereferences to <code>taxonomy.xml#church</code>.</p>
            </prefixDef>
          </listPrefixDef>
        </encodingDesc>
        <profileDesc>
          <langUsage>
            <xsl:for-each select="//tei:*[@xml:lang]">
              <xsl:if test="not(preceding::tei:*[@xml:lang=current()/@xml:lang] or ancestor::tei:*[@xml:lang=current()/@xml:lang])">
                <language ident="{@xml:lang}">
                  <xsl:choose>
                    <xsl:when test="@xml:lang = 'cnx'">Middle Cornish</xsl:when>
                    <xsl:when test="@xml:lang = 'cor'">Cornish</xsl:when>
                    <xsl:when test="@xml:lang = 'cym'">Welsh</xsl:when>
                    <xsl:when test="@xml:lang = 'deu'">German</xsl:when>
                    <xsl:when test="@xml:lang = 'eng'">English</xsl:when>
                    <xsl:when test="@xml:lang = 'fra'">French</xsl:when>
                    <xsl:when test="@xml:lang = 'gla'">Scottish Gaelic</xsl:when>
                    <xsl:when test="@xml:lang = 'gmh'">Middle High German</xsl:when>
                    <xsl:when test="@xml:lang = 'gml'">Middle Low German</xsl:when>
                    <xsl:when test="@xml:lang = 'grc'">Ancient Greek</xsl:when>
                    <xsl:when test="@xml:lang = 'ita'">Italian</xsl:when>
                    <xsl:when test="@xml:lang = 'lat'">Latin</xsl:when>
                    <xsl:when test="@xml:lang = 'por'">Portuguese</xsl:when>
                    <xsl:when test="@xml:lang = 'spa'">Spanish</xsl:when>
                    <xsl:when test="@xml:lang = 'wlm'">Middle Welsh</xsl:when>
                    <xsl:when test="@xml:lang = 'xno'">Anglo-Norman</xsl:when>
                    <xsl:otherwise>ERROR: Word converter XSLT add_header.xsl needs to be updated to have a name for this language code, to be in sync with the codes allowed in the @-code grammar!</xsl:otherwise>
                  </xsl:choose>
                </language>
              </xsl:if>
            </xsl:for-each>
          </langUsage>
        </profileDesc>
      </teiHeader>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
