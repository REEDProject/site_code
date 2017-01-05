<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create XIncludes for each filepath specified in an HTTP
       request, calling to a pipeline to generate a word list. -->

  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:template match="h:request">
    <data>
      <xi:include href="{kiln:url-for-match('local-admin-concordance-exclude-lists', (), 1)}" />
      <word_lists>
        <xsl:apply-templates select="h:requestParameters/h:parameter[@name='docs']/h:value" />
      </word_lists>
    </data>
  </xsl:template>

  <xsl:template match="h:value">
    <xi:include href="{kiln:url-for-match('local-admin-concordance-word-list', (.), 1)}" />
  </xsl:template>

</xsl:stylesheet>
