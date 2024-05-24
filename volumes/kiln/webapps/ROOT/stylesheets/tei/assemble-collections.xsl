<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create XIncludes to include the collection documents for the
       records identified by the "ids" parameter in the request,
       wrapping them in a tei:TEICorpus element. -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:template match="aggregation">
    <xsl:copy>
      <xsl:copy-of select="*" />
      <!-- Don't use the TEI namespace for the TEICorpus element,
           since it is used in a Cocoon pipeline and I can't see how
           to get a namespaced map:part/@element. This is an interim
           step only, so it's not important to have the namespace. -->
      <TEICorpus>
        <xsl:for-each-group select="h:request/h:requestParameters/h:parameter[@name='ids']/h:value" group-by="substring-before(., '-')">
          <xi:include href="{kiln:url-for-match('ereed-preprocess-records-tei', (current-grouping-key()), 1)}" />
        </xsl:for-each-group>
      </TEICorpus>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
