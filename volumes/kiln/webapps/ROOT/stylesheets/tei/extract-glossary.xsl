<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Extract the TEI header, identified glossary, and associated
       front matter, wrapped in a tei:TEI element. -->

  <xsl:param name="glossary-id" />

  <xsl:template match="tei:TEI">
    <xsl:variable name="glossary" select="id($glossary-id)" />
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:copy-of select="tei:teiHeader" />
      <text>
        <front>
          <xsl:copy-of select="id(substring-after($glossary/@corresp, '#'))" />
          <xsl:copy-of select="id('gloss_abbreviations')" />
        </front>
        <body>
          <xsl:copy-of select="$glossary" />
        </body>
        <back>
          <!-- Create a list of headings in order for generating a ToC. -->
          <xsl:for-each select="tei:text/tei:body/tei:div">
            <div id="{@xml:id}">
              <xsl:copy-of select="tei:head" />
            </div>
          </xsl:for-each>
        </back>
      </text>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
