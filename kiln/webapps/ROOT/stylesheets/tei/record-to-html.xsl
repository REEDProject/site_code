<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="to-html.xsl" />

  <xsl:variable name="record_text"
                select="/aggregation/TEICorpus/tei:TEI/tei:text" />

  <xsl:template match="tei:div" mode="collection">
    <div class="row selected-record-summary relative">
      <div class="columns medium-9 record">
        <xsl:apply-templates />
        <xsl:if test="not(preceding-sibling::tei:div)">
          <div class="small-margin-bottom-25">
            <!-- QAZ: tools-small. -->
            <div class="hide-for-medium">
              <div class="record-sidebar hide-for-medium" >
                <div class="bibliography-filter filter hide-for-medium boxed alternate-style hide-for-medium clear full-width">
                  <div class="filter-head jump-to-filter">TOOLS</div>
                  <div class="filter-content-wrapper relative">
                    <div class="filter-content">
                      <!-- QAZ: tools. -->
                      <div class="tools">
                        <div class="tools-heading show-for-medium">TOOLS</div>
                        <ul class="tools">
                          <li class="email"><a href="">Email</a></li>
                          <li class="print"><a href="">Print</a></li>
                          <li class="pdf"><a href="">PDF</a></li>
                          <li class="xml"><a href="">XML</a></li>
                          <li class="bookmark"><a href="">Bookmark</a></li>
                          <li class="share"><a href="">Share</a></li>
                        </ul>
                      </div>
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
          <!-- QAZ: tools. -->
          <div class="tools">
            <div class="tools-heading show-for-medium">TOOLS</div>
            <ul class="tools">
              <li class="email"><a href="">Email</a></li>
              <li class="print"><a href="">Print</a></li>
              <li class="pdf"><a href="">PDF</a></li>
              <li class="xml"><a href="">XML</a></li>
              <li class="bookmark"><a href="">Bookmark</a></li>
              <li class="share"><a href="">Share</a></li>
            </ul>
          </div>
          <div class="padding-top-45">
            <xsl:copy-of select="$helpful_links" />
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- A tei:div in the editorial matter of a collection that contains
       record(s) has a different layout. -->
  <xsl:template match="tei:div[tei:text]" mode="collection">
    <xsl:apply-templates mode="collection" select="node()" />
  </xsl:template>

  <xsl:template match="tei:text[@type='record']" mode="collection">
    <div class="row selected relative">
      <xsl:call-template name="display-selected-record">
        <xsl:with-param name="is_collection" select="1" />
      </xsl:call-template>
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

  <xsl:template name="display-record-collation-notes">
    <xsl:if test="./tei:body/tei:div[@type='collation_notes']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Collation Notes</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="$record_text/tei:body/tei:div[@type='collation_notes']" />
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
        <xsl:call-template name="display-record-collation-notes" />
        <xsl:call-template name="display-record-glossed-terms" />
        <xsl:call-template name="display-record-endnote" />
        <xsl:call-template name="display-record-doc-desc" />
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="display-record-doc-desc">
    <li class="accordion-item" data-accordion-item="">
      <a href="#" class="accordion-title">Document Description</a>
      <div class="accordion-content" data-tab-content="">
        <xsl:variable name="head" select="$record_text/tei:body/tei:head" />
        <p>
          <xsl:text>Record title: </xsl:text>
          <xsl:value-of select="$head/tei:title" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:repository" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:idno[@type='shelfmark']" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:settlement" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:idno[@type='publication']" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:idno[@type='publication_number']" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:idno[@type='author_surname']" />
          <xsl:apply-templates mode="doc_desc" select="$head/tei:idno[@type='short_title']" />
        </p>
        <xsl:apply-templates select="$head/tei:p[@type='edDesc']" />
        <xsl:apply-templates select="$head/tei:p[@type='docDesc']" />
        <xsl:apply-templates select="$head/tei:p[@type='techDesc']" />
      </div>
    </li>
  </xsl:template>

  <xsl:template name="display-record-endnote">
    <xsl:if test="./tei:body/tei:div[@type='endnote']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Endnote</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="$record_text/tei:body/tei:div[@type='endnote']" />
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-entities">
    <ul class="tags">
      <xsl:for-each select=".//tei:rs[@ref]">
        <!-- QAZ: Only display each entity once. -->
        <xsl:variable name="entity-id">
          <xsl:text>entity-</xsl:text>
          <xsl:call-template name="get-entity-id-from-url">
            <xsl:with-param name="eats-url" select="@ref" />
          </xsl:call-template>
        </xsl:variable>
        <li class="tag">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="make-entity-url">
                <xsl:with-param name="eats-url" select="@ref" />
              </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="id($entity-id)/primary_name" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="display-record-footnotes">
    <xsl:if test=".//tei:note[@type='foot']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Footnotes</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="footnotes">
            <xsl:apply-templates mode="group" select=".//tei:note[@type='foot']" />
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-glossed-terms">
    <xsl:if test=".//tei:term[@ref]">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Glossed Terms</a>
        <div class="accordion-content" data-tab-content="">
          <p>Click a term to see the earliest instance of that term in the records.</p>
          <ul class="glossed-terms">
            <!-- QAZ: Terms may be repeated within the same entry;
                 only one instance should be rendered here. -->
            <xsl:apply-templates mode="group" select=".//tei:term[@ref]" />
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-info">
    <div class="record-info-inner">
      <i>
        <!-- QAZ: Use EATSML name? -->
        <xsl:apply-templates select="tei:body/tei:head/tei:rs" />
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="tei:body/tei:head/tei:date" />
      </i>
    </div>
  </xsl:template>

  <xsl:template name="display-record-marginalia">
    <xsl:if test=".//tei:note[@type='marginal']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Marginalia</a>
        <div class="accordion-content" data-tab-content="">
          <ul class="marginalia-list">
            <xsl:apply-templates mode="group" select="$record_text//tei:note[@type='marginal']" />
          </ul>
        </div>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-record-shelfmark">
    <div class="shelfmark">
      <xsl:copy-of select="tei:body/tei:head/tei:span[@type='shelfmark'][@subtype='html']/node()" />
    </div>
  </xsl:template>

  <xsl:template name="display-record-sidebar">
    <xsl:variable name="entities">
      <xsl:call-template name="display-record-entities" />
    </xsl:variable>
    <div class="show-for-medium">
      <div class="show-hide">
        <div class="heading">SHOW OR HIDE</div>
        <label class="checkbox"><input type="checkbox" name="show-tags" /><span class="checkbox-inner"> </span>Tag</label>
        <label class="checkbox"><input type="checkbox" name="show-terms" /><span class="checkbox-inner"> </span>Glossed Terms</label>
      </div>
      <div class="view-tags">
        <div class="heading">
          <span>VIEW TAGS</span>
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
              <label class="checkbox"><input type="checkbox" name="show-tags" /><span class="checkbox-inner"> </span>Tag</label>
              <label class="checkbox"><input type="checkbox" name="show-terms" /><span class="checkbox-inner"> </span>Glossed Terms</label>
            </div>
          </div>
        </div>
      </div>
      <div class="bibliography-filter filter hide-for-medium boxed alternate-style hide-for-medium clear left full-width">
        <div class="filter-head jump-to-filter">VIEW TAGS</div>
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
        <xsl:apply-templates select="tei:body/tei:head/tei:title" />
      </h1>
    </div>
  </xsl:template>

  <xsl:template name="display-record-tools">
    <div class="tools">
      <div class="tools-heading show-for-medium">TOOLS</div>
      <ul class="tools">
        <li class="email"><a href="">Email</a></li>
        <li class="print"><a href="">Print</a></li>
        <li class="pdf"><a href="">PDF</a></li>
        <li class="xml"><a href="">XML</a></li>
        <li class="bookmark"><a href="">Bookmark</a></li>
        <li class="share"><a href="">Share</a></li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="display-record-transcription">
    <div class="record-content">
      <xsl:apply-templates select="tei:body/tei:div[@type='transcription']" />
    </div>
  </xsl:template>

  <xsl:template name="display-record-translation">
    <xsl:if test="./tei:body/tei:div[@type='translation']">
      <li class="accordion-item" data-accordion-item="">
        <a href="#" class="accordion-title">Record Translation</a>
        <div class="accordion-content" data-tab-content="">
          <xsl:apply-templates select="$record_text/tei:body/tei:div[@type='translation']" />
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
