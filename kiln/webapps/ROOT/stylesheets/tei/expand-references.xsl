<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="#all"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Expand @sameAs and @ana references. These typically replace the
       element carrying the referencing attribute with the content of
       the referenced element.

       The pipeline calling this must be following by an XInclude
       transformation to effect the actual inclusion. -->

  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:variable name="tei" select="/tei:TEI" />

  <xsl:template match="tei:quote[@source]">
    <xsl:variable name="context" select="." />
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
      <!-- We are treating this properly at this step (@source
           allowing multiple references), even though we have no
           useful processing to handle such a case, and will likely
           assume that it is a single reference at a later point. -->
      <xsl:for-each select="tokenize(@source, '\s+')">
        <xsl:choose>
          <!-- Internal reference, no need for an XInclude. Copy the
               referenced element here inside a kiln:added, for
               processing in tidy-expanded-references.xsl later. -->
          <xsl:when test="starts-with(., '#')">
            <kiln:added>
              <xsl:variable name="source" select="substring-after(., '#')" />
              <xsl:for-each select="$context">
                <xsl:apply-templates select="id($source)" mode="referenced" />
              </xsl:for-each>
            </kiln:added>
          </xsl:when>
          <!-- External to entire site reference, just leave as is. -->
          <xsl:when test="contains(., '://')" />
          <!-- Reference to another document in the collection.

               QAZ: This is annoying, because if it's a reference to a
               record, we need to run much this same normalisation
               step on it in order to get the full title, but we
               cannot recurse. For now, just leave them be. -->
          <xsl:otherwise />
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:text[@ana]" priority="10">
    <!-- The record types that are attached to the tei:text should not
         replace the content of the element. -->
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:variable name="eats_prefix" select="/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:listPrefixDef/tei:prefixDef[@ident='eats']" />
      <xsl:variable name="eats_pattern" select="replace($eats_prefix/@replacementPattern, '\$1', $eats_prefix/@matchPattern)" />
      <xsl:variable name="ana" select="tokenize(@ana, '\s+')" />
      <xsl:variable name="record_types" as="xs:string*">
        <xsl:for-each select="$ana">
          <xsl:if test="not(matches(., $eats_pattern))">
            <xsl:sequence select="." />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="associated_entities" as="xs:string*">
        <xsl:for-each select="$ana">
          <xsl:if test="matches(., $eats_pattern)">
            <xsl:sequence select="." />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="count($record_types) &gt; 0">
        <index indexName="record_type">
          <xsl:for-each select="$record_types">
            <tei:term>
              <xsl:call-template name="make-xinclude">
                <xsl:with-param name="url" select="." />
              </xsl:call-template>
            </tei:term>
          </xsl:for-each>
        </index>
      </xsl:if>
      <xsl:if test="count($associated_entities) &gt; 0">
        <index indexName="associated_entity">
          <xsl:for-each select="$associated_entities">
            <tei:term ref="{.}" />
          </xsl:for-each>
        </index>
      </xsl:if>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:*[@ana]" mode="#default referenced-record">
    <xsl:for-each select="tokenize(@ana, '\s+')">
      <xsl:call-template name="make-xinclude">
        <xsl:with-param name="url" select="." />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:text[@corresp]">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="tei:*[@corresp]">
    <xsl:for-each select="tokenize(@corresp, '\s+')">
      <xsl:call-template name="make-xinclude">
        <xsl:with-param name="url" select="." />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:text[@target]">
    <xsl:variable name="context" select="." />
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <!-- We are treating this properly at this step (@target
           allowing multiple references), even though we have no
           useful processing to handle such a case, and will likely
           assume that it is a single reference at a later point. -->
      <xsl:for-each select="tokenize(@target, '\s+')">
        <xsl:choose>
          <!-- Internal reference, no need for an XInclude. Copy the
               referenced element here inside a kiln:added, for
               processing in tidy-expanded-references.xsl later. -->
          <xsl:when test="starts-with(., '#')">
            <kiln:added>
              <xsl:variable name="target" select="substring-after(., '#')" />
              <xsl:for-each select="$context">
                <xsl:apply-templates select="id($target)" mode="referenced" />
              </xsl:for-each>
            </kiln:added>
          </xsl:when>
          <!-- External to entire site reference, just leave as is. -->
          <xsl:when test="contains(., '://')" />
          <!-- Reference to another document in the collection.

               QAZ: This is annoying, because if it's a reference to a
               record, we need to run much this same normalisation
               step on it in order to get the full title, but we
               cannot recurse. For now, just leave them be. -->
          <xsl:otherwise />
        </xsl:choose>
      </xsl:for-each>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@ana" />
  <xsl:template match="tei:text/@corresp">
    <xsl:attribute name="other_collection_ids">
      <xsl:for-each select="tokenize(., '\s+')">
        <xsl:value-of select="substring-before(., '.xml')" />
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@corresp" />

  <!-- Referenced records just need the tei:body/tei:head to be copied
       across. We also need to expand the tei:seg in the tei:head in
       order to get the title.

       We want to avoid potential infinite loops, where one record
       references a second record which in turn references the
       first. -->
  <xsl:template match="tei:text[@type='record']" mode="referenced">
    <xsl:copy>
      <xsl:apply-templates mode="referenced-record" select="@*|tei:body/tei:head" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="referenced-record">
    <xsl:copy>
      <xsl:apply-templates mode="referenced-record" select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- References to things other than records only need an element
       carrying the referenced xml:id along with the containing
       [front|body]/div's xml:id. -->
  <xsl:template match="tei:*" mode="referenced">
    <xsl:copy>
      <xsl:apply-templates select="@xml:id" />
      <xsl:attribute name="section-id" select="ancestor-or-self::tei:div[local-name(parent::*)=('back', 'front')]/@xml:id" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="make-xinclude">
    <xsl:param name="url" />
    <!-- XInclude does not permit fragment identifiers in
         xi:include/@href (it's useless; the HTTP request does not
         pass the fragment). Convert to a querystring. -->
    <xsl:variable name="final-url" select="replace($url, '#', '?id=')" />
    <xi:include href="{kiln:url-for-match('ereed-extract-referenced-content',
                      ($final-url), 1)}" />
  </xsl:template>

</xsl:stylesheet>
