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
            <prefixDef ident="ereed" matchPattern="([A-Za-z0-9]+)"
                       replacementPattern="../code_list.xml#$1">
              <p>Private URIs using the <code>ereed</code> prefix are pointers to entities in the code_list.xml file. For example, <code>ereed:BPA</code> dereferences to <code>code_list.xml#BPA</code>.</p>
            </prefixDef>
          </listPrefixDef>
        </encodingDesc>
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
