<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="tei"
                version="1.0"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to wrap blocks of text in tei:ab. Treat tei:lb as
       potential markers of blocks. Avoid creating empty tei:ab and
       cover existing blocks.

       Thankfully almost all tei:lb are at the top level (children of
       a tei:div), and those few that aren't can be ignored or handled
       manually). -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Transcription section divs. -->
  <xsl:template match="tei:div[../@type='transcription' or ../@type='translation']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="tei:head" />
      <xsl:variable name="following-id">
        <xsl:call-template name="get-first-following">
          <xsl:with-param name="start" select="tei:head" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="following"
                    select="tei:head/following-sibling::node()[generate-id(.)=$following-id]" />
      <xsl:apply-templates select="comment()[following-sibling::node()=$following]" />
      <xsl:apply-templates mode="initial" select="$following" />
    </xsl:copy>
  </xsl:template>

  <!-- Content divs that do not have a tei:head. -->
  <xsl:template match="tei:div[@type='endnote']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates mode="initial" select="child::node()[1]" />
    </xsl:copy>
  </xsl:template>

  <!-- Elements that should not be wrapped in tei:ab. -->
  <xsl:template match="tei:ab|tei:closer|tei:list|tei:pb|tei:table"
                mode="initial">
    <xsl:text>
</xsl:text>
    <xsl:copy-of select="." />
    <xsl:text>
</xsl:text>
    <xsl:variable name="following-id">
      <xsl:call-template name="get-first-following" />
    </xsl:variable>
    <xsl:variable name="following"
                  select="following-sibling::node()[generate-id(.)=$following-id]" />
    <xsl:apply-templates mode="initial" select="$following" />
  </xsl:template>

  <xsl:template match="tei:lb" mode="initial">
    <xsl:variable name="following-id">
      <xsl:call-template name="get-first-following" />
    </xsl:variable>
    <xsl:variable name="following"
                  select="following-sibling::node()[generate-id(.)=$following-id]" />
    <xsl:variable name="following-name" select="local-name($following)" />
    <xsl:choose>
      <xsl:when test="$following and $following-name != 'ab' and
                      $following-name != 'closer' and $following-name != 'lb'
                      and $following-name != 'list' and $following-name != 'pb'
                      and $following-name != 'table'">
        <xsl:text>
</xsl:text>
        <ab>
          <xsl:apply-templates mode="following" select="$following" />
        </ab>
        <xsl:text>
</xsl:text>
        <xsl:apply-templates mode="initial"
                             select="following-sibling::tei:lb[1]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="initial" select="$following" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="initial">
    <xsl:text>
</xsl:text>
    <ab>
      <xsl:copy-of select="." />
      <xsl:apply-templates mode="following" select="following-sibling::node()[1]" />
    </ab>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates mode="initial"
                         select="following-sibling::tei:lb[1]" />
  </xsl:template>

  <xsl:template match="tei:lb" mode="following" />

  <xsl:template match="node()" mode="following">
    <xsl:copy-of select="." />
    <xsl:apply-templates mode="following"
                         select="following-sibling::node()[1]" />
  </xsl:template>

  <xsl:template name="get-first-following">
    <xsl:param name="start" select="." />
    <!-- "Return" the id of the first following-sibling that is either
         a text node with non-whitespace content or an element. -->
    <xsl:variable name="first-text"
                  select="$start/following-sibling::text()[normalize-space()][1]" />
    <xsl:variable name="first-element"
                  select="$start/following-sibling::*[1]" />
    <xsl:variable name="text-count"
                  select="count($first-text/preceding-sibling::node())" />
    <xsl:variable name="element-count"
                  select="count($first-element/preceding-sibling::node())" />
    <xsl:choose>
      <xsl:when test="not($first-text)">
        <xsl:value-of select="generate-id($first-element)" />
      </xsl:when>
      <xsl:when test="not($first-element)">
        <xsl:value-of select="generate-id($first-text)" />
      </xsl:when>
      <xsl:when test="$text-count &lt; $element-count">
        <xsl:value-of select="generate-id($first-text)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id($first-element)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
