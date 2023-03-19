<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />
  <xsl:include href="cocoon://_internal/url/reverse.xsl" />
  <xsl:include href="results-pagination.xsl" />

  <xsl:template match="result/doc" mode="search-results">
    <xsl:variable name="doc-type" select="str[@name='document_type']" />
    <xsl:variable name="document-id" select="str[@name='document_id']" />
    <xsl:variable name="collection-id" select="arr[@name='collection_id']/str[1]" />
    <xsl:variable name="result-url">
      <!-- Use the doc-type to determine what URL to use to display
           the document from which this result came. -->
      <xsl:choose>
        <xsl:when test="$doc-type = 'record'">
          <xsl:value-of select="kiln:url-for-match('ereed-record-display-html',
                                ($document-id), 0)" />
        </xsl:when>
        <xsl:when test="$doc-type = 'editorial'">
          <xsl:value-of select="kiln:url-for-match('ereed-collection-part', ($collection-id, $document-id), 0)" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <tr>
      <td></td>
      <td class="show-for-small-only">
        <a href="{$result-url}">
          <xsl:value-of select="arr[@name='document_title']/str[1]" />
        </a>
      </td>
      <td class="show-for-medium">
        <xsl:value-of select="str[@name='record_date_display']" />
      </td>
      <td class="show-for-medium">
        <xsl:value-of select="str[@name='record_location']" />
      </td>
      <td class="show-for-medium">
        <a href="{$result-url}">
          <xsl:value-of select="str[@name='record_title']" />
        </a>
      </td>
      <td class="show-for-medium">
        <xsl:value-of select="str[@name='record_shelfmark']" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="response/result" mode="search-results">
    <xsl:apply-templates mode="search-results" select="doc" />
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

</xsl:stylesheet>
