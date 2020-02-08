<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove any kiln:added elements (from
       extract-referenced-content.xsl) and massage the included
       content. -->

  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:template match="kiln:added">
    <xsl:apply-templates mode="addition" select="node()" />
  </xsl:template>

  <xsl:template match="tei:bibl" mode="addition">
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="tei:index[@indexName='record_type']/tei:term/kiln:added"
                mode="addition">
    <xsl:value-of select="tei:category/@xml:id" />
  </xsl:template>

  <xsl:template match="tei:ptr[kiln:added/tei:text/@type='record']">
    <!-- We are here assuming that @target is a single value, because
         there isn't any good processing we can do if it's not. -->
    <xsl:variable name="record-id" select="substring-after(@target, '#')" />
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name='target')]" />
      <xsl:attribute name="target">
        <xsl:value-of select="kiln:url-for-match('ereed-record-display-html', $record-id, 0)" />
      </xsl:attribute>
      <xsl:apply-templates mode="record-addition" select="kiln:added/tei:text" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:quote[kiln:added/tei:text/@type='record']">
    <!-- We are here assuming that @source is a single value, because
         there isn't any good processing we can do if it's not. -->
    <xsl:variable name="record-id" select="substring-after(@source, '#')" />
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name='source')]" />
      <xsl:attribute name="source">
        <xsl:value-of select="kiln:url-for-match('ereed-record-display-html', $record-id, 0)" />
      </xsl:attribute>
      <xsl:attribute name="kiln:title">
        <xsl:apply-templates mode="record-addition"
                             select="kiln:added/tei:text" />
      </xsl:attribute>
      <xsl:apply-templates select="text()|*[not(tei:text[@type='record'])]" />
    </xsl:copy>
  </xsl:template>

  <!-- Reference pointing to something that is not a record (ie, a
       'collection part'). -->
  <xsl:template match="tei:ref[kiln:added/tei:*[normalize-space(@section-id)]]">
    <xsl:variable name="doc" select="/*/@xml:id" />
    <xsl:variable name="part-id" select="kiln:added/tei:*/@section-id" />
    <xsl:variable name="anchor" select="kiln:added/tei:*/@xml:id" />
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name='target')]" />
      <xsl:attribute name="target">
        <xsl:value-of select="kiln:url-for-match('ereed-collection-part', ($doc, $part-id), 0)" />
        <xsl:if test="$part-id != $anchor">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$anchor" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="node()[local-name()!='added']" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="kiln:added/tei:category">
    <xsl:copy-of select="tei:catDesc/node()" />
  </xsl:template>

  <xsl:template match="kiln:added/tei:text[@type='record']"
                mode="record-addition">
    <!-- A record has been referenced. We want only its title. -->
    <xsl:value-of select="tei:head/kiln:added/tei:bibl/tei:title" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="tei:head/tei:date" />
  </xsl:template>

  <xsl:template match="@*|node()" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
