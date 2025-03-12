<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT for displaying Solr results. -->

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

  <!-- Display a facet (in the list of all facets). -->
  <xsl:template match="int" mode="search-results">
    <xsl:variable name="name" select="../@name" />
    <xsl:variable name="value" select="@name" />
    <li class="checkbox">
      <xsl:variable name="selected" select="$request/h:parameter[@name=$name]/h:value = $value" />
      <xsl:if test="$selected">
        <xsl:attribute name="class" select="'checkbox checked'" />
      </xsl:if>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="$selected">
              <xsl:call-template name="make-deselect-facet-url">
                <xsl:with-param name="facet-name" select="$name" />
                <xsl:with-param name="facet-value" select="$value" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$query-string-at-start" />
              <xsl:text>&amp;</xsl:text>
              <xsl:value-of select="$name" />
              <xsl:text>=</xsl:text>
              <xsl:value-of select="kiln:escape-for-query-string($value)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="display-facet-value">
          <xsl:with-param name="facet-field" select="$name" />
          <xsl:with-param name="facet-value" select="$value" />
        </xsl:call-template>
        <xsl:call-template name="display-facet-count" />
      </a>
    </li>
  </xsl:template>

  <!-- Display facets (in the list of all facets). -->
  <xsl:template match="lst[@name='facet_fields']" mode="search-results">
    <xsl:if test="lst/int">
      <h3>Facets</h3>

      <div class="section-container accordion"
           data-section="accordion">
        <xsl:apply-templates mode="search-results" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst"
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
              <xsl:sort select="lower-case(.)" />
              <xsl:copy-of select="." />
            </xsl:for-each>
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst"
                mode="search-results-nested">
    <xsl:variable name="facet-values">
      <xsl:apply-templates mode="search-results" />
    </xsl:variable>
    <xsl:if test="normalize-space($facet-values)">
      <li class="accordion-inner-item" data-accordion-item="">
        <a href="#" class="accordion-inner-title">
          <xsl:apply-templates mode="search-results" select="@name" />
        </a>
        <div class="accordion-inner-content" data-tab-content="">
          <ul class="open-filters">
            <xsl:for-each select="$facet-values/li">
              <xsl:sort select="lower-case(.)" />
              <xsl:copy-of select="." />
            </xsl:for-each>
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst"
                mode="search-results-no-hierarchy">
    <xsl:variable name="facet-values">
      <xsl:apply-templates mode="search-results" />
    </xsl:variable>
    <xsl:for-each select="$facet-values/li">
      <xsl:sort select="lower-case(.)" />
      <xsl:copy-of select="." />
    </xsl:for-each>
  </xsl:template>

  <!-- Display a facet's name. -->
  <xsl:template match="lst[@name='facet_fields']/lst/@name"
                mode="search-results">
    <xsl:choose>
      <xsl:when test=". = 'facet_collectives_guild_occupational'">
        <xsl:text>Guild, Occupational</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_collectives_guild_religious'">
        <xsl:text>Guild, Religious</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_collectives_office_specific'">
        <xsl:text>Filter by specific office</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_collectives_office_type'">
        <xsl:text>Filter by office type</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_entertainments_custom'">
        <xsl:text>Folk Custom</xsl:text>
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
        <xsl:text>Props</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_set'">
        <xsl:text>Sets/Machinery</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_wagon'">
        <xsl:text>Pageant Wagons</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_costume'">
        <xsl:text>Costumes</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_materials_food'">
        <xsl:text>Food/Drink</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_central_gov'">
        <xsl:text>Central Government</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_chronicles'">
        <xsl:text>Chronicle/History</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_church'">
        <xsl:text>Church</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_education'">
        <xsl:text>Educational Institution</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_family'">
        <xsl:text>Family</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_guild'">
        <xsl:text>Guild</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_local_gov'">
        <xsl:text>Local Government</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_manorial'">
        <xsl:text>Manorial</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_playhouse'">
        <xsl:text>Playhouse/Arena</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_rel_community'">
        <xsl:text>Religious Community</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'facet_record_type_soc_lit'">
        <xsl:text>Social Commentary/Literary Work</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'facet_locations_feature_')">
        <xsl:for-each select="tokenize(substring-after(., 'facet_locations_feature_'), '_')">
          <xsl:value-of select="upper-case(substring(., 1, 1))" />
          <xsl:value-of select="substring(., 2)" />
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="starts-with(., 'facet_people_named_')">
        <xsl:for-each select="tokenize(substring-after(., 'facet_people_named_'), '_')">
          <xsl:choose>
            <xsl:when test="position() = (1, 3)">
              <xsl:value-of select="upper-case(substring(., 1, 1))" />
              <xsl:value-of select="substring(., 2)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>–</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
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

  <!-- Display an individual search result (entity context). -->
  <xsl:template match="result/doc" mode="editorial-search-results">
    <xsl:variable name="collection_id" select="arr[@name='collection_id']/str[1]" />
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

  <!-- Display an individual search result. -->
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
      <td class="show-for-medium" data-order="{arr[@name='record_date']/int[1]}"><xsl:value-of select="str[@name='record_date_display']" /></td>
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_location']" /></td>
      <td class="show-for-medium"><a href="{$result-url}"><xsl:value-of select="str[@name='record_title']" /></a></td>
      <td class="show-for-medium"><xsl:value-of select="str[@name='record_shelfmark']" /></td>
    </tr>
  </xsl:template>

  <!-- Display selected facets. -->
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

  <!-- Display selected facet. -->
  <xsl:template match="str" mode="display-selected-facet">
    <!-- ORed facets have names and values that are different from
         ANDed facets and must be handled differently. ORed facets
         have the exclusion tag at the beginning of the name, and may
         have multiple values within parentheses separated by " OR
         ". -->
    <xsl:choose>
      <xsl:when test="starts-with(., '{!tag')">
        <xsl:call-template name="display-selected-or-facet" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="display-selected-and-facet" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

  <xsl:template name="display-selected-facet">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <span class="active-filter">
      <xsl:call-template name="display-facet-value">
        <xsl:with-param name="facet-field" select="$name" />
        <xsl:with-param name="facet-value" select="$value" />
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <!-- Create a link to unapply the facet. -->
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="make-deselect-facet-url">
            <xsl:with-param name="facet-name" select="$name" />
            <xsl:with-param name="facet-value" select="$value" />
          </xsl:call-template>
        </xsl:attribute>
        <span class="close"></span>
      </a>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Display a selected AND facet. -->
  <xsl:template name="display-selected-and-facet">
    <xsl:variable name="name" select="substring-before(., ':')" />
    <xsl:variable name="value"
                  select="replace(., '^[^:]+:&quot;(.*)&quot;$', '$1')" />
    <xsl:if test="not($name='document_type')">
      <xsl:call-template name="display-selected-facet">
        <xsl:with-param name="name" select="$name" />
        <xsl:with-param name="value" select="$value" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Display a selected OR facet. -->
  <xsl:template name="display-selected-or-facet">
    <xsl:variable name="name"
                  select="substring-before(substring-after(., '}'), ':')" />
    <xsl:variable name="value" select="substring-before(substring-after(., ':('), ')')" />
    <xsl:for-each select="tokenize($value, ' OR ')">
      <xsl:call-template name="display-selected-facet">
        <xsl:with-param name="name" select="$name" />
        <!-- The facet value has surrounding quotes. -->
        <xsl:with-param name="value" select="substring(., 2, string-length(.)-2)" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="display-facet-count">
    <xsl:if test="string-length(.) > 0 and number(.) > 0">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="." />
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-facet-value">
    <xsl:param name="facet-field" />
    <xsl:param name="facet-value" />
    <xsl:variable name="item" select="key('item-by-eats-id', $facet-value)" />
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
        <xsl:value-of select="$facet-value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-nested-facets">
    <xsl:param name="facets" />
    <xsl:param name="inner" select="false()" />
    <xsl:param name="title" />
    <xsl:variable name="title-class">
      <xsl:choose>
        <xsl:when test="$inner">
          <xsl:text>accordion-inner-title</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>accordion-title</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <li class="accordion-item" data-accordion-item="">
      <a href="#" class="{$title-class}">
        <xsl:value-of select="$title" />
      </a>
      <xsl:choose>
        <xsl:when test="count($facets) = 1">
          <xsl:variable name="facet-values">
            <xsl:apply-templates select="$facets/*" mode="search-results" />
          </xsl:variable>
          <div class="accordion-inner-content" data-tab-content="">
            <ul class="open-filters">
              <xsl:for-each select="$facet-values/li">
                <xsl:sort select="lower-case(.)" />
                <xsl:copy-of select="." />
              </xsl:for-each>
            </ul>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="accordion-content" data-tab-content="">
            <ul class="accordion" data-accordion="" data-allow-all-closed="true">
              <xsl:apply-templates select="$facets" mode="search-results-nested" />
            </ul>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template name="make-deselect-facet-url">
    <xsl:param name="facet-name" />
    <xsl:param name="facet-value" />
    <xsl:variable name="name-value-pair">
      <!-- Match the fq parameter as it appears in the query
           string. -->
      <xsl:value-of select="$facet-name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="kiln:escape-for-query-string($facet-value)" />
    </xsl:variable>
    <xsl:value-of select="kiln:string-replace($query-string-at-start,
                                $name-value-pair, '')" />
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
