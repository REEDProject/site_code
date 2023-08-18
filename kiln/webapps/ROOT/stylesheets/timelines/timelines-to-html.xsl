<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="kiln">

  <xsl:template match="live/timeline">
    <div class="timelines-overview-link">
      <a href="{kiln:url-for-match('ereed-timeline', (@xml:id), 0)}">
        <xsl:value-of select="title" />
      </a>
    </div>
    <p><xsl:value-of select="description" /></p>
  </xsl:template>

  <xsl:template match="development/timeline">
    <p><xsl:value-of select="." /></p>
  </xsl:template>

  <xsl:template match="featured">
    <xsl:variable name="timeline" select="id(substring-after(@ref, '#'))" />
    <div class="featured-timelines-thumbnail">
      <img src="{kiln:url-for-match('local-images-png', (thumbnail), 0)}"
           alt="Thumbnail of {$timeline/title}" />
    </div>
    <a href="{kiln:url-for-match('ereed-timeline', ($timeline/@xml:id), 0)}">Explore <xsl:value-of select="$timeline/title" /></a>
  </xsl:template>

</xsl:stylesheet>
