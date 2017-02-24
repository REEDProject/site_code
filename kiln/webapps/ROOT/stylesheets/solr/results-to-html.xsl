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
  <xsl:include href="../eatsml/entity-to-html.xsl" />

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
    <xsl:call-template name="display-unselected-and-facet" />
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
    <xsl:variable name="facet-values">
      <xsl:apply-templates mode="search-results" />
    </xsl:variable>
    <xsl:if test="normalize-space($facet-values)">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">
          <xsl:apply-templates mode="search-results" select="@name" />
        </a>
        <div class="accordion-content" data-tab-content="">
          <ul class="open-filters">
            <xsl:for-each select="$facet-values/li">
              <xsl:sort select="." />
              <xsl:copy-of select="." />
            </xsl:for-each>
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields]/lst"
                mode="search-results-no-hierarchy">
    <xsl:variable name="facet-values">
      <xsl:apply-templates mode="search-results" />
    </xsl:variable>
    <xsl:for-each select="$facet-values/li">
      <xsl:sort select="." />
      <xsl:copy-of select="." />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst/@name"
                mode="search-results">
    <xsl:choose>
      <xsl:when test=". = 'facet_entertainers_patronised'">
        <xsl:text>Patronized</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_entertainments_custom'">
        <xsl:text>Seasonal Custom</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_entertainments_animal'">
        <xsl:text>Animal Sport</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_drama_work'">
        <xsl:text>Titled Work</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_instrument'">
        <xsl:text>Instruments</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_book'">
        <xsl:text>Books</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_property'">
        <xsl:text>Props &amp; Machinery</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_set'">
        <xsl:text>Sets</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_wagon'">
        <xsl:text>Pageant Wagons</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_costume'">
        <xsl:text>Costumes</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_food'">
        <xsl:text>Food &amp; Drink</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="tokenize(., '_')">
          <xsl:if test="position() = last()">
            <xsl:value-of select="upper-case(substring(., 1, 1))" />
            <xsl:value-of select="substring(., 2)" />
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="result/doc" mode="editorial-search-results">
    <xsl:variable name="collection_id" select="str[@name='collection_id']" />
    <xsl:variable name="part_id" select="str[@name='document_id']" />
    <xsl:variable name="result-url" select="kiln:url-for-match('ereed-collection-part', ($collection_id, $part_id), 0)" />
    <tr>
      <td>
        <xsl:value-of select="/aggregation/collections/collection[@id=$collection_id]" />
      </td>
      <td>
        <a href="{$result-url}">
          <xsl:value-of select="arr[@name='document_title']/str[1]" />
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="result/doc" mode="search-results">
    <xsl:variable name="record-id" select="str[@name='document_id']" />
    <xsl:variable name="result-url" select="kiln:url-for-match('ereed-record-display-html', ($record-id), 0)" />
    <tr>
      <td><label class="checkbox"><input name="ids" value="{$record-id}" type="checkbox" /><span class="checkbox-inner"></span></label></td>
      <td class="show-for-small-only">
        <a href="{$result-url}">
          <xsl:value-of select="arr[@name='document_title']/str[1]" />
        </a>
      </td>
      <!-- QAZ: Put record_date in an attribute to use for sorting. -->
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_date_display']" /></td>
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
    <xsl:call-template name="display-selected-and-facet" />
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

  <xsl:template name="display-selected-and-facet">
    <xsl:variable name="fq">
      <!-- Match the fq parameter as it appears in the query
           string. -->
      <xsl:text>fq=</xsl:text>
      <xsl:value-of select="." />
    </xsl:variable>
    <!-- Filter out the document_type fq, as that is set in the
         underlying query. QAZ: It would be good not to special case
         this. -->
    <xsl:if test="not(. = 'document_type:record')">
      <xsl:variable name="id" select="replace(., '[^:]+:&quot;(.*)&quot;$', '$1')" />
      <span class="active-filter">
        <xsl:call-template name="lookup-facet-id">
          <xsl:with-param name="context" select="." />
          <xsl:with-param name="id" select="$id" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <!-- Create a link to unapply the facet. -->
        <a>
          <xsl:attribute name="href">
            <xsl:text>?</xsl:text>
            <xsl:value-of select="replace($query-string, $fq, '')" />
          </xsl:attribute>
          <span class="close"></span>
        </a>
      </span>
      <xsl:text> </xsl:text>
    </xsl:if>
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
            <xsl:call-template name="make-deselect-facet-link">
              <xsl:with-param name="facet" select="." />
              <xsl:with-param name="facets" select="$facets" />
              <xsl:with-param name="prefix" select="$prefix" />
              <xsl:with-param name="fq" select="$old-fq" />
            </xsl:call-template>
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
    <xsl:variable name="selected" select="/aggregation/h:request/h:requestParameters/h:parameter[@name='fq']/h:value = $fq" />
    <li class="checkbox">
      <xsl:if test="$selected">
        <xsl:attribute name="class" select="'checkbox checked'" />
      </xsl:if>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="$selected">
              <xsl:text>?</xsl:text>
              <xsl:value-of select="replace($query-string, concat('fq=', $fq), '')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>?</xsl:text>
              <xsl:value-of select="$query-string" />
              <xsl:text>&amp;fq=</xsl:text>
              <xsl:value-of select="$fq" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="lookup-facet-id">
          <xsl:with-param name="id" select="@name" />
        </xsl:call-template>
        <xsl:call-template name="display-facet-count" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="display-unselected-or-facet">
    <xsl:variable name="facet-name">
      <xsl:text>{!tag=</xsl:text>
      <xsl:value-of select="../@name" />
      <xsl:text>Tag}</xsl:text>
      <xsl:value-of select="../@name" />
    </xsl:variable>
    <xsl:variable name="facet-value"
                  select="concat('&quot;', @name, '&quot;')" />
    <!-- Equivalently this could get the information from
         /aggregation/response. -->
    <xsl:variable name="old-fq" select="/aggregation/h:request/h:requestParameters/h:parameter[@name='fq']/h:value[starts-with(., concat($facet-name, ':'))]" />
    <xsl:variable name="selected" select="contains($old-fq, $facet-value)" />
    <li class="checkbox">
      <xsl:if test="$selected">
        <xsl:attribute name="class" select="'checkbox checked'" />
      </xsl:if>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="not($selected)">
              <!-- Create a link to apply the facet filter. -->
              <xsl:text>?</xsl:text>
              <xsl:choose>
                <xsl:when test="not($old-fq)">
                  <xsl:value-of select="$query-string" />
                  <xsl:text>&amp;fq=</xsl:text>
                  <xsl:value-of select="$facet-name" />
                  <xsl:text>:(</xsl:text>
                  <xsl:value-of select="$facet-value" />
                  <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="new-fq">
                    <xsl:value-of select="substring-before($old-fq, ')')" />
                    <xsl:text> OR </xsl:text>
                    <xsl:value-of select="$facet-value" />
                    <xsl:text>)</xsl:text>
                  </xsl:variable>
                  <xsl:value-of select="kiln:string-replace($query-string,
                                        $old-fq, $new-fq)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <!-- Create a link to remove the facet filter. -->
              <xsl:call-template name="make-deselect-facet-link">
                <xsl:with-param name="facet" select="$facet-value" />
                <xsl:with-param name="facets"
                                select="tokenize(substring-before(
                                        substring-after($old-fq, '('), ')'), ' OR ')" />
                <xsl:with-param name="prefix" select="concat('&amp;fq=', $facet-name, ':')" />
                <xsl:with-param name="fq" select="concat('&amp;fq=', $old-fq)" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="lookup-facet-id">
          <xsl:with-param name="id" select="@name" />
        </xsl:call-template>
        <xsl:call-template name="display-facet-count" />
      </a>
    </li>
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
        <xsl:when test="$item and local-name($item) = 'entity'">
          <xsl:call-template name="display-entity-primary-name-plus">
            <xsl:with-param name="entity" select="$item" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$item">
          <xsl:value-of select="normalize-space($item)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="make-deselect-facet-link">
    <!-- Insert the URL for the current search minus the supplied
         (currently selected) facet value. -->
    <!-- The facet value to remove. -->
    <xsl:param name="facet" />
    <!-- The sequence of facet values for a facet that contains $facet. -->
    <xsl:param name="facets" />
    <!-- The part of the query-string for this facet that precedes the
         list of facet values. -->
    <xsl:param name="prefix" />
    <!-- The current part of the query-string for this facet. -->
    <xsl:param name="fq" />
    <xsl:variable name="new-fq">
      <xsl:if test="count($facets) &gt; 1">
        <xsl:value-of select="$prefix" />
        <xsl:text>(</xsl:text>
        <xsl:for-each select="remove($facets, index-of($facets, $facet))">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:text> OR </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:text>?</xsl:text>
    <!-- Since both $old-fq and $new-fq will contain characters that
         are meaningful within a regular expressions, use a string
         substitution rather than replace. -->
    <xsl:value-of select="kiln:string-replace($query-string, $fq, $new-fq)" />
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
