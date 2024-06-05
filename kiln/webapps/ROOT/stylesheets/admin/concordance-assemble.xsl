<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Remove words from the records that occur in the stop word and
       exclusion lists. -->

  <xsl:variable name="context-length" select="10" />

  <xsl:template match="data">
    <concordance>
      <xsl:variable name="exclusions" select="exclusions/words/w" />
      <xsl:for-each-group select="word_lists/word_list/record/w"
                          group-by="@lemma">
        <xsl:for-each-group select="current-group()" group-by="@xml:lang">
          <xsl:variable name="lemma" select="@lemma" />
          <xsl:variable name="lang" select="distinct-values(current-group()/@xml:lang)" />
          <xsl:if test="not($lemma = $exclusions[not(@xml:lang)] or
                        $lemma = $exclusions[@xml:lang=$lang])">
            <entry>
              <w><xsl:value-of select="$lemma" /></w>
              <count><xsl:value-of select="count(current-group())" /></count>
              <lang><xsl:value-of select="$lang" /></lang>
              <cits>
                <xsl:for-each select="current-group()">
                  <cit date="{../@date}" record="{../@cit}">
                    <xsl:apply-templates select="." mode="citation" />
                  </cit>
                </xsl:for-each>
              </cits>
            </entry>
          </xsl:if>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </concordance>
  </xsl:template>

  <xsl:template match="w" mode="citation">
    <xsl:variable name="preceding-context">
      <xsl:call-template name="citation-context">
        <xsl:with-param name="count" select="1" />
        <xsl:with-param name="node"
                        select="preceding-sibling::node()[$context-length]" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="following-context">
      <xsl:call-template name="citation-context">
        <xsl:with-param name="count" select="1" />
        <xsl:with-param name="node" select="following-sibling::node()[1]" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="normalize-space($preceding-context)" />
    <xsl:if test="ends-with($preceding-context, ' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <term><xsl:value-of select="." /></term>
    <xsl:if test="starts-with($following-context, ' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="$following-context" />
  </xsl:template>

  <xsl:template name="citation-context">
    <xsl:param name="count" />
    <xsl:param name="node" />
    <xsl:value-of select="$node" />
    <xsl:variable name="next-node" select="$node/following-sibling::node()[1]" />
    <xsl:if test="$count &lt; $context-length">
      <xsl:call-template name="citation-context">
        <xsl:with-param name="count" select="$count + 1" />
        <xsl:with-param name="node" select="$next-node" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
