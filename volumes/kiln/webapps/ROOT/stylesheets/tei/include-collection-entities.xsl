<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create an XInclude to include EATSML entities for the
       collection, with the collection's associated place
       selected. -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:import href="utils.xsl" />

  <xsl:template match="aggregation">
    <xsl:copy>
      <xsl:copy-of select="node()" />
      <xsl:variable name="collection-entity">
        <xsl:call-template name="get-entity-id-from-url">
          <xsl:with-param name="eats-url" select="/aggregation/TEICorpus/tei:TEI/tei:teiHeader/tei:profileDesc/tei:settingDesc/tei:place/tei:placeName/@ref" />
        </xsl:call-template>
      </xsl:variable>
      <xi:include href="{kiln:url-for-match('ereed-extract-entity', ($collection-entity), 1)}" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
