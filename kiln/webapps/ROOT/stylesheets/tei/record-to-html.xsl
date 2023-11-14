<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="to-html.xsl" />
  <xsl:import href="../eatsml/entity-to-html.xsl" />

  <xsl:variable name="record_text"
                select="/aggregation/TEICorpus/tei:TEI/tei:text" />

  <xsl:template match="tei:div" mode="collection">
    <div class="row selected-record-summary relative">
      <div class="columns medium-9 record">
        <xsl:apply-templates />
        <xsl:if test="not(preceding-sibling::tei:div)">
          <div class="small-margin-bottom-25">
            <div class="hide-for-medium">
              <div class="record-sidebar hide-for-medium" >
                <div class="bibliography-filter filter hide-for-medium boxed alternate-style clear full-width">
                  <div class="filter-head jump-to-filter">SHOW OR HIDE</div>
                  <div class="filter-content-wrapper relative">
                    <div class="filter-content">
                      <div class="show-hide">
                        <label class="checkbox"><input type="checkbox" name="show-tags" /><span class="checkbox-inner"> </span>Tag</label>
                      </div>
                    </div>
                  </div>
                  <div class="filter-head jump-to-filter">TOOLS</div>
                  <div class="filter-content-wrapper relative">
                    <div class="filter-content">
                      <xsl:call-template name="display-record-tools" />
                    </div>
                  </div>
                </div>
                <div class="bibliography-filter filter hide-for-medium boxed alternate-style hide-for-medium clear full-width">
                  <div class="filter-head jump-to-filter">HELPFUL LINKS</div>
                  <div class="filter-content-wrapper relative">
                    <div class="filter-content">
                      <xsl:copy-of select="$helpful_links" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </xsl:if>
      </div>
      <xsl:if test="not(preceding-sibling::tei:div)">
        <div class="columns record-sidebar show-for-medium">
          <div class="show-hide">
            <div class="heading">SHOW OR HIDE</div>
            <label class="checkbox"><input type="checkbox" name="show-tags" autocomplete="off" /><span class="checkbox-inner"> </span>Entities</label>
          </div>
          <xsl:call-template name="display-record-tools" />
          <div class="padding-top-45">
            <xsl:copy-of select="$helpful_links" />
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- A tei:div in the editorial matter of a collection that contains
       record(s) has a different layout. -->
  <xsl:template match="tei:div[record]" mode="collection">
    <xsl:apply-templates mode="collection" select="node()" />
  </xsl:template>

  <xsl:template match="record" mode="collection">
    <div class="row selected relative">
      <xsl:for-each select="id(substring-after(@corresp, '#'))">
        <xsl:call-template name="display-selected-record">
          <xsl:with-param name="is_collection" select="1" />
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="display-collection-name">
    <xsl:value-of select="/aggregation/TEICorpus/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']" />
  </xsl:template>

  <xsl:template name="display-collection-editorial-toc">
    <xsl:variable name="collection"
                  select="/aggregation/TEICorpus/tei:TEI/@xml:id" />
    <ul class="sub-sections">
      <xsl:for-each select="$record_text/tei:*[local-name()=('front', 'back')]/tei:div">
        <li>
          <a href="{kiln:url-for-match('ereed-collection-part', ($collection, @xml:id), 0)}">
            <xsl:if test="@type='appendix'">
              <xsl:text>Appendix</xsl:text>
              <xsl:if test="@n">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@n" />
              </xsl:if>
              <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:value-of select="tei:head" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- The following named templates all assume that the context node
       is a tei:text[@type='record']. -->

  <xsl:template name="display-record-associated-entities">
    <xsl:if test="tei:index[@indexName='associated_entity']/tei:term">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Event Entity Pages</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="marginalia-list">
            <xsl:for-each select="tei:index[@indexName='associated_entity']/tei:term">
              <xsl:call-template name="display-record-entity">
                <xsl:with-param name="eats-url" select="@ref" />
              </xsl:call-template>
            </xsl:for-each>
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-collation-notes">
    <xsl:if test=".//tei:note[@type='collation']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Collation Notes</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="collation-list">
            <xsl:apply-templates mode="group" select=".//tei:note[@type='collation']" />
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-data">
    <div class="record-accordion">
      <ul class="accordion" data-accordion="" data-allow-all-closed="true">
        <xsl:call-template name="display-record-marginalia" />
        <xsl:call-template name="display-record-footnotes" />
        <xsl:call-template name="display-record-translation" />
        <xsl:call-template name="display-record-modernization" />
        <xsl:call-template name="display-record-collation-notes" />
        <xsl:call-template name="display-record-glossed-terms" />
        <xsl:call-template name="display-record-endnote" />
        <xsl:call-template name="display-record-associated-entities" />
        <xsl:call-template name="display-record-doc-desc" />
        <xsl:call-template name="display-record-images" />
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="display-record-doc-desc">
    <li class="accordion-item" data-accordion-item="">
      <a href="#" class="accordion-title">Document Description</a>
      <div class="accordion-content" data-tab-content="">
        <xsl:variable name="head" select="tei:body/tei:head" />
        <xsl:for-each select="$head/tei:bibl">
          <p>
            <xsl:text>Record title: </xsl:text>
            <xsl:value-of select="tei:title" />
            <xsl:apply-templates mode="doc_desc" select="tei:repository" />
            <xsl:apply-templates mode="doc_desc" select="tei:idno[@type='shelfmark']" />
            <xsl:apply-templates mode="doc_desc" select="tei:settlement" />
            <xsl:apply-templates mode="doc_desc" select="tei:idno[@type='publication']" />
            <xsl:apply-templates mode="doc_desc" select="tei:idno[@type='pubNumber']" />
            <xsl:apply-templates mode="doc_desc" select="tei:idno[@type='authorSurname']" />
            <xsl:apply-templates mode="doc_desc" select="tei:idno[@type='shortTitle']" />
          </p>
          <xsl:apply-templates select="tei:p[@type='edDesc']" />
          <xsl:apply-templates select="tei:p[@type='docDesc']" />
          <xsl:apply-templates select="tei:p[@type='techDesc']" />
        </xsl:for-each>
      </div>
    </li>
  </xsl:template>

  <xsl:template name="display-record-endnote">
    <xsl:if test="./tei:body/tei:div[@type='endnote']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Endnote</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="tei:body/tei:div[@type='endnote']" />
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-entity">
    <xsl:param name="eats-url" />
    <xsl:variable name="entity-id">
      <xsl:text>entity-</xsl:text>
      <xsl:call-template name="get-entity-id-from-url">
        <xsl:with-param name="eats-url" select="$eats-url" />
      </xsl:call-template>
    </xsl:variable>
    <li class="tag">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="make-entity-url">
            <xsl:with-param name="eats-url" select="$eats-url" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="display-entity-primary-name-plus">
          <xsl:with-param name="entity" select="id($entity-id)" />
        </xsl:call-template>
      </a>
    </li>
  </xsl:template>

  <xsl:template name="display-record-entities">
    <xsl:variable name="record-id" select="@xml:id" />
    <ul class="tags">
      <xsl:for-each select=".//tei:rs[@ref][not(@ref=preceding::tei:rs[ancestor::tei:text/@xml:id=$record-id]/@ref)]">
        <xsl:call-template name="display-record-entity">
          <xsl:with-param name="eats-url" select="@ref" />
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="tei:index[@indexName='associated_entity']/tei:term">
        <xsl:call-template name="display-record-entity">
          <xsl:with-param name="eats-url" select="@ref" />
        </xsl:call-template>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="display-record-footnotes">
    <xsl:if test=".//tei:note[@type='foot' and not(ancestor::tei:div/@subtype='modernization')]">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Footnotes</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="footnotes">
            <xsl:apply-templates mode="group" select=".//tei:note[@type='foot' and not(ancestor::tei:div/@subtype='modernization')]" />
          </ul>
        </div>
      </li>
    </xsl:if>
    <xsl:if test=".//tei:note[@type='foot' and ancestor::tei:div/@subtype='modernization']">
      <ul class="footnotes" style="display: none;">
        <xsl:apply-templates mode="group" select=".//tei:note[@type='foot' and ancestor::tei:div/@subtype='modernization']" />
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-glossed-terms">
    <xsl:if test="tei:body//tei:term[@ref]">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Glossed Terms</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="glossed-terms">
            <xsl:variable name="text-id" select="@xml:id" />
            <xsl:apply-templates mode="group" select="tei:body//tei:term[@ref][not(@ref = preceding::tei:term[@ref][ancestor::tei:text[1]/@xml:id=$text-id]/@ref)]">
              <xsl:sort order="ascending" select="id(substring-after(@ref, '#'))/ancestor::tei:entry[1]/tei:form/tei:orth" lang="en"/>
            </xsl:apply-templates>
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-images">
    <xsl:variable name="facs" select=".//tei:pb[normalize-space(@facs)]" />
    <xsl:if test="$facs">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Manuscript Images</a>
        <div class="accordion-content" data-tab-content="">
          <p>
            <xsl:for-each select="$facs">
              <xsl:variable name="url"
                            select="id(substring-after(@facs, '#'))/@url" />
              <xsl:variable name="ref" select="substring-after(substring-before($url, '.'), 'images/')" />
              <a href="{kiln:url-for-match('local-images-jpeg', ($ref), 0)}">
                <img src="{kiln:url-for-match('local-images-jpeg-thumbnail', ($ref), 0)}" />
              </a>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </p>
          <p><xsl:value-of select="id(substring-after($facs[1]/@facs, '#'))/tei:desc" /></p>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-info">
    <div class="record-info-inner">
      <i>
        <!-- QAZ: Use EATSML name? -->
        <xsl:apply-templates select="tei:body/tei:head/tei:rs[1]" />
        <xsl:if test="tei:body/tei:head/tei:rs[2]">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="tei:body/tei:head/tei:rs[2]" />
        </xsl:if>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="tei:body/tei:head/tei:date" />
      </i>
    </div>
  </xsl:template>

  <xsl:template name="display-record-marginalia">
    <xsl:if test=".//tei:note[@type='marginal' and not(ancestor::tei:div/@subtype='modernization')]">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Marginalia</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="marginalia-list">
            <xsl:apply-templates mode="group" select=".//tei:note[@type='marginal' and not(ancestor::tei:div/@subtype='modernization')]" />
          </ul>
        </div>
      </li>
    </xsl:if>
    <xsl:if test=".//tei:note[@type='marginal' and ancestor::tei:div/@subtype='modernization']">
      <ul class="marginalia-list" style="display: none;">
        <xsl:apply-templates mode="group" select=".//tei:note[@type='marginal' and ancestor::tei:div/@subtype='modernization']" />
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-shelfmark">
    <div class="shelfmark">
      <xsl:for-each select="tei:body/tei:head/tei:bibl">
        <xsl:copy-of select="tei:span[@type='shelfmark'][@subtype='html']/node()" />
        <xsl:if test="position()!=last()"><br /></xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="display-record-sidebar">
    <xsl:variable name="entities">
      <xsl:call-template name="display-record-entities" />
    </xsl:variable>
    <div class="show-for-medium">
      <div class="show-hide">
        <div class="heading">SHOW OR HIDE</div>
        <label class="checkbox"><input type="checkbox" name="show-tags" autocomplete="off" /><span class="checkbox-inner"> </span>Entities</label>
        <label class="checkbox"><input type="checkbox" name="show-terms" autocomplete="off" /><span class="checkbox-inner"> </span>Glossed Terms</label>
      </div>
      <div class="view-tags">
        <div class="heading">
          <span>VIEW ENTITIES</span>
        </div>
        <xsl:copy-of select="$entities" />
      </div>
      <a href="#" class="back-to-top show-for-medium sticky-bottom button expanded transparent small-margin-top-25 small-margin-bottom-25">Back to top</a>
    </div>
    <div class="hide-for-medium">
      <div class="bibliography-filter filter hide-for-medium boxed alternate-style hide-for-medium clear left full-width">
        <div class="filter-head jump-to-filter">SHOW OR HIDE</div>
        <div class="filter-content-wrapper relative">
          <div class="filter-content">
            <div class="show-hide">
              <label class="checkbox"><input type="checkbox" name="show-tags" autocomplete="off" /><span class="checkbox-inner"> </span>Tag</label>
              <label class="checkbox"><input type="checkbox" name="show-terms" autocomplete="off" /><span class="checkbox-inner"> </span>Glossed Terms</label>
            </div>
          </div>
        </div>
      </div>
      <div class="bibliography-filter filter hide-for-medium boxed alternate-style hide-for-medium clear left full-width">
        <div class="filter-head jump-to-filter">VIEW ENTITIES</div>
        <div class="filter-content-wrapper relative">
          <div class="filter-content">
            <xsl:copy-of select="$entities" />
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="display-record-title">
    <div class="record-title">
      <h1>
        <xsl:apply-templates select="tei:body/tei:head/tei:bibl[1]/tei:title" />
      </h1>
    </div>
  </xsl:template>

  <xsl:template name="display-record-tools">
    <div class="tools">
      <div class="tools-heading show-for-medium">TOOLS</div>
      <ul class="tools">
        <!--<li class="email"><a href="">Email</a></li>
        <li class="print"><a href="">Print</a></li>
        <li class="pdf"><a href="">PDF</a></li>-->
        <li class="xml"><a href="https://github.com/REEDProject/Collections">XML</a></li>
        <!--<li class="bookmark"><a href="">Bookmark</a></li>
        <li class="share"><a href="">Share</a></li>-->
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="display-record-transcription">
    <div class="record-content">
      <xsl:apply-templates select="tei:body/tei:div[@type='transcription']" />
    </div>
  </xsl:template>

  <xsl:template name="display-record-translation">
    <xsl:if test="./tei:body/tei:div[@type='translation' and not (@subtype)]">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Record Translation</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="tei:body/tei:div[@type='translation']" />
        </div>
      </li>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="display-record-modernization">
    <xsl:if test="./tei:body/tei:div[@type='translation' and @subtype='modernization']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Modernized Text</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="tei:body/tei:div[@type='translation' and @subtype='modernization']" />
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-selected-record">
    <xsl:param name="is_collection" select="0" />
    <div class="columns medium-9 record-title" data-equalizer-watch="">
      <div class="record">
        <xsl:call-template name="display-record-info" />
        <xsl:call-template name="display-record-title" />
        <xsl:call-template name="display-record-shelfmark" />
        <hr />
      </div>
    </div>
    <div class="columns medium-2 record-sidebar" data-equalizer-watch="">
      <xsl:call-template name="display-record-sidebar" />
    </div>
    <div data-equalizer-watch="">
      <xsl:attribute name="class">
        <xsl:text>columns medium-9 record-info</xsl:text>
        <xsl:if test="$is_collection">
          <xsl:text> end</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:call-template name="display-record-transcription" />
      <xsl:call-template name="display-record-data" />
      <a href="#" class="back-to-top button transparent hide-for-medium sticky-bottom expanded small-margin-bottom-25 small-margin-top-25">Back To Top</a>
    </div>
  </xsl:template>

  <!-- The following named templates all assume that the context node
       is a tei:front/tei:div or tei:back. -->

  <xsl:template name="display-section-data">
    <div class="record-accordion">
      <ul class="accordion" data-accordion="" data-allow-all-closed="true">
        <xsl:call-template name="display-record-footnotes" />
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="display-section-toc">
    <ul class="sub-sections">
      <xsl:for-each select="tei:div">
        <li>
          <a href="#{generate-id()}">
            <xsl:value-of select="tei:head" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="display-appendix-toc">
    <ul class="individual-related-entity numbered list coloured">
      <xsl:for-each select="tei:div">
        <li>
          <span>
            <a href="#{generate-id()}">
              <xsl:value-of select="tei:head" />
            </a>
          </span>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

</xsl:stylesheet>
