<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT for displaying Solr results.

       Includes automatic handling of facets. Facets may either be
       ANDed or ORed together; this is controlled by which of
       display-unselected-and-facet/display-unselected-or-facet and
       display-selected-and-facet/display-selected-or-facet pairs are
       used. Additional xsl:templates can be added to allow for some
       facets to be ORed and some to be ANDed.

       Note that ORed facets require that the facet.field value(s) of
       the Solr query include an exclusion of the tag(s), as required
       for the particular query. This XSLT automatically assigns a tag
       named "<field name>Tag" to ORed facet fields, so that is the
       scheme that should be followed. -->

  <xsl:import href="../defaults.xsl" />
  <xsl:include href="cocoon://_internal/url/reverse.xsl" />
  <xsl:include href="results-pagination.xsl" />

  <xsl:key name="item-by-eats-id" match="*[@eats_id]" use="@eats_id" />

  <!-- Using the XML from a request generator is much simpler than
       using the value of {request:queryString}, because the former
       provides unescaped values.

       However, it is still useful at several junctions to have an
       assembled string (including to disassemble it). -->
  <xsl:variable name="query-string">
    <xsl:for-each select="/aggregation/h:request/h:requestParameters/h:parameter/h:value">
      <xsl:value-of select="../@name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="." />
      <xsl:if test="not(position() = last())">
        <xsl:text>&amp;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="int" mode="search-results">
    <!-- A facet's count. -->
    <!-- If this facet is ANDed together (as separate fq parameters),
         then call display-unselected-and-facet. If a facet is ORed
         together in a single parameter, call
         display-unselected-or-facet. -->
    <xsl:call-template name="display-unselected-or-facet" />
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']" mode="search-results">
    <xsl:if test="lst/int">
      <h3>Facets</h3>

      <div class="section-container accordion"
           data-section="accordion">
        <xsl:apply-templates mode="search-results" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields]/lst"
                mode="search-results">
    <li class="accordion-item" data-accordion-item="">
      <a href="#" class="accordion-title">
        <xsl:apply-templates mode="search-results" select="@name" />
      </a>
      <div class="accordion-content" data-tab-content="">
        <xsl:variable name="facet-values">
          <xsl:apply-templates mode="search-results" />
        </xsl:variable>
        <xsl:for-each select="$facet-values/span">
          <xsl:sort select="." />
          <xsl:copy-of select="." />
        </xsl:for-each>
      </div>
    </li>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst/@name"
                mode="search-results">
    <xsl:for-each select="tokenize(., '_')">
      <xsl:if test="position() = last()">
        <xsl:value-of select="upper-case(substring(., 1, 1))" />
        <xsl:value-of select="substring(., 2)" />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="result/doc" mode="search-results">
    <xsl:variable name="result-url" select="kiln:url-for-match('ereed-record-display-html', (str[@name='document_id']))" />
    <tr>
      <td><input name="select_all" value="1" id="table-select-all" type="checkbox" /></td>
      <td class="show-for-small-only">
        <a href="{$result-url}">
          <xsl:value-of select="arr[@name='document_title']/str[1]" />
        </a>
      </td>
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_date']" /></td>
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_location']" /></td>
      <td class="show-for-medium"><a href="{$result-url}"><xsl:value-of select="str[@name='record_title']" /></a></td>
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_shelfmark']" /></td>
    </tr>
  </xsl:template>

  <xsl:template match="*[@name='fq']" mode="search-results">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'str'">
        <xsl:apply-templates mode="display-selected-facet" select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="str">
          <xsl:apply-templates mode="display-selected-facet" select="." />
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="str" mode="display-selected-facet">
    <!-- If a facet is ANDed together (as separate fq parameters),
         then call display-selected-and-facet. If a facet is ORed
         together in a single parameter, call
         display-selected-or-facet. -->
    <xsl:call-template name="display-selected-or-facet" />
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

  <xsl:template name="display-selected-and-facet">
    <xsl:variable name="fq">
      <!-- Match the fq parameter as it appears in the query
           string. -->
      <xsl:text>&amp;fq=</xsl:text>
      <xsl:value-of select="." />
    </xsl:variable>
    <li>
      <xsl:value-of select="replace(., '[^:]+:&quot;(.*)&quot;$', '$1')" />
      <xsl:text> (</xsl:text>
      <!-- Create a link to unapply the facet. -->
      <a>
        <xsl:attribute name="href">
          <xsl:text>?</xsl:text>
          <xsl:value-of select="replace($query-string, $fq, '')" />
        </xsl:attribute>
        <xsl:text>x</xsl:text>
      </a>
      <xsl:text>)</xsl:text>
    </li>
  </xsl:template>

  <xsl:template name="display-selected-or-facet">
    <!-- Handle a context node consisting of one or more facet values
         joined by " OR " (eg, "date:(foo OR bar)"). -->
    <xsl:variable name="old-fq">
      <!-- Match the fq parameter as it appears in the query
           string. -->
      <xsl:text>&amp;fq=</xsl:text>
      <xsl:value-of select="." />
    </xsl:variable>
    <xsl:variable name="prefix" select="substring-before($old-fq, '(')" />
    <xsl:variable name="facets"
                  select="tokenize(substring-before(
                          substring-after(., '('), ')'), ' OR ')" />
    <xsl:variable name="context" select="." />
    <xsl:for-each select="$facets">
      <xsl:variable name="new-fq">
        <xsl:if test="count($facets) &gt; 1">
          <xsl:value-of select="$prefix" />
          <xsl:text>(</xsl:text>
          <xsl:for-each select="remove($facets, position())">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
              <xsl:text> OR </xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:variable>
      <!-- Display the facet value without the surrounding quotes. -->
      <span class="active-filter">
        <xsl:call-template name="lookup-facet-id">
          <xsl:with-param name="context" select="$context" />
          <xsl:with-param name="id"
                          select="substring(., 2, string-length(.)-2)" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <!-- Create a link to unapply the facet. -->
        <a>
          <xsl:attribute name="href">
            <xsl:text>?</xsl:text>
            <!-- Since both $old-fq and $new-fq will contain
                 characters that are meaningful within a regular
                 expressions, use a string substitution rather than
                 replace. -->
            <xsl:value-of select="kiln:string-replace($query-string,
                                  $old-fq, $new-fq)" />
          </xsl:attribute>
          <span class="close"></span>
        </a>
      </span>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="display-unselected-and-facet">
    <xsl:variable name="fq">
      <xsl:value-of select="../@name" />
      <xsl:text>:"</xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text>"</xsl:text>
    </xsl:variable>
    <!-- List a facet only if it is not selected. -->
    <xsl:if test="not(/aggregation/h:request/h:requestParameters/h:parameter[@name='fq']/h:value = $fq)">
      <li>
        <a>
          <xsl:attribute name="href">
            <xsl:text>?</xsl:text>
            <xsl:value-of select="$query-string" />
            <xsl:text>&amp;fq=</xsl:text>
            <xsl:value-of select="$fq" />
          </xsl:attribute>
          <xsl:value-of select="@name" />
        </a>
        <xsl:call-template name="display-facet-count" />
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-unselected-or-facet">
    <xsl:variable name="name">
      <xsl:text>{!tag=</xsl:text>
      <xsl:value-of select="../@name" />
      <xsl:text>Tag}</xsl:text>
      <xsl:value-of select="../@name" />
    </xsl:variable>
    <xsl:variable name="old-fq" select="/aggregation/h:request/h:requestParameters/h:parameter[@name='fq']/h:value[starts-with(., concat($name, ':'))]" />
    <!-- List a facet only if it is not selected. -->
    <xsl:if test="not(contains($old-fq, @name))">
      <!-- This test is susceptible to a false positive if the facet
           name is a substring of another. -->
      <!-- Create a link to apply the facet filter. -->
      <span class="checkbox">
        <a>
          <xsl:attribute name="href">
            <xsl:text>?</xsl:text>
            <xsl:choose>
              <xsl:when test="not($old-fq)">
                <xsl:value-of select="$query-string" />
                <xsl:text>&amp;fq=</xsl:text>
                <xsl:value-of select="$name" />
                <xsl:text>:("</xsl:text>
                <xsl:value-of select="@name" />
                <xsl:text>")</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="new-fq">
                  <xsl:value-of select="substring-before($old-fq, ')')" />
                  <xsl:text> OR "</xsl:text>
                  <xsl:value-of select="@name" />
                  <xsl:text>")</xsl:text>
                </xsl:variable>
                <xsl:value-of select="kiln:string-replace($query-string,
                                      $old-fq, $new-fq)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:call-template name="lookup-facet-id">
            <xsl:with-param name="id" select="@name" />
          </xsl:call-template>
        </a>
        <xsl:call-template name="display-facet-count" />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-facet-count">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template name="lookup-facet-id">
    <xsl:param name="context" select="." />
    <xsl:param name="id" />
    <xsl:for-each select="$context">
      <xsl:variable name="item" select="key('item-by-eats-id', $id)" />
      <xsl:choose>
        <xsl:when test="$item">
          <xsl:value-of select="$item" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="kiln:string-replace" as="xs:string">
    <!-- Replaces the first occurrence of $replaced in $input with
         $replacement. -->
    <xsl:param name="input" as="xs:string" />
    <xsl:param name="replaced" as="xs:string" />
    <xsl:param name="replacement" as="xs:string" />
    <xsl:sequence select="concat(substring-before($input, $replaced),
                          $replacement, substring-after($input, $replaced))" />
  </xsl:function>

</xsl:stylesheet>
