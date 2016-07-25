<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />
  <xsl:include href="cocoon://_internal/url/reverse.xsl" />
  <xsl:include href="results-pagination.xsl" />
  <xsl:include href="../../kiln/stylesheets/solr/utils.xsl" />

  <xsl:template match="result/doc" mode="search-results">
    <xsl:variable name="doc-type"
                  select="tokenize(str[@name='file_path'], '/')[2]" />
    <xsl:variable name="document-id" select="str[@name='document_id']" />
    <xsl:variable name="result-url">
      <!-- Use the doc-type to determine what URL to use to display
           the document from which this result came. -->
      <xsl:choose>
        <xsl:when test="$doc-type = 'records'">
          <xsl:value-of select="kiln:url-for-match('ereed-record-display-html',
                                ($document-id))" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <li>
      <a href="{$result-url}">
        <xsl:value-of select="arr[@name='document_title']/str[1]" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="response/result" mode="search-results">
    <xsl:choose>
      <xsl:when test="number(@numFound) = 0">
        <h3>No results found</h3>
      </xsl:when>
      <xsl:when test="doc">
        <ul>
          <xsl:apply-templates mode="search-results" select="doc" />
        </ul>

        <xsl:call-template name="add-results-pagination" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

</xsl:stylesheet>
