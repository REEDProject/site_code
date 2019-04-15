<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="lowernormal" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="upper"       select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:template match="tei:TEI">
    <word_list>
      <xsl:apply-templates select="tei:text/tei:group/tei:text[@type='record']/tei:body" />
      <xsl:apply-templates select="tei:text/tei:back//tei:floatingText[@type='record']/tei:body" />
    </word_list>
  </xsl:template>

  <xsl:template match="tei:body">
    <record>
      <xsl:attribute name="date">
        <xsl:choose>
          <xsl:when test="tei:head/tei:date/@when-iso">
            <xsl:value-of select="tei:head/tei:date/@when-iso" />
          </xsl:when>
          <xsl:when test="tei:head/tei:date/@from-iso">
            <xsl:value-of select="tei:head/tei:date/@from-iso" />
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="cit" select="normalize-space(tei:head)" />
      <xsl:apply-templates select="tei:div[@type='transcription']" />
    </record>
  </xsl:template>

  <xsl:template match="text()[normalize-space()]">
    <xsl:variable name='lang' select="ancestor::*[normalize-space(@xml:lang)][1]/@xml:lang"/>
    <xsl:analyze-string select="." regex="[\p{{L}}]+">
      <xsl:matching-substring>
        <xsl:element name="w">
          <xsl:attribute name="xml:lang" select="$lang" />
          <xsl:attribute name="lemma"
                         select="translate(., $upper, $lowernormal)" />
          <xsl:value-of select="." />
        </xsl:element>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <nw><xsl:value-of select="translate(., '&#xA;', ' ')" /></nw>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

</xsl:stylesheet>
