<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

  <xsl:import href="cocoon://_internal/url/reverse.xsl" />

  <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl" />

  <xsl:template match="tei:add[@place='above']">
    <xsl:text>⸢</xsl:text>
    <xsl:apply-templates />
    <xsl:text>⸣</xsl:text>
  </xsl:template>

  <xsl:template match="tei:add[@place='below']">
    <xsl:text>⸤</xsl:text>
    <xsl:apply-templates />
    <xsl:text>⸥</xsl:text>
  </xsl:template>

  <xsl:template match="tei:damage">
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates />
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:ex">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:gap[@extent]">
    <xsl:for-each select="1 to @extent">
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:gap[@reason='omitted']">
    <xsl:text>...</xsl:text>
  </xsl:template>

  <xsl:template match="tei:front/tei:div/tei:head" />

  <xsl:template match="tei:front/tei:div//tei:div/tei:head">
    <xsl:variable name="level" select="count(ancestor::tei:div)+1" />
    <xsl:element name="h{$level}">
      <xsl:attribute name="id" select="generate-id(..)" />
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:note[@type='foot']">
    <span class="footnote tag" note="{generate-id()}"></span>
  </xsl:template>

  <xsl:template match="tei:note[@type='foot']" mode="group">
    <li note="{generate-id()}">
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="tei:note[@type='marginal']">
    <!-- QAZ: icon indicating place of note. -->
    <span class="marginalia" note="{generate-id()}"></span>
  </xsl:template>

  <xsl:template match="tei:note[@type='marginal']" mode="group">
    <li note="{generate-id()}">
      <!-- QAZ: icon indicating place of note. -->
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="tei:pb" />

  <xsl:template match="tei:rs[@ref]">
    <a class="tag">
      <xsl:attribute name="href">
        <xsl:call-template name="make-entity-url">
          <xsl:with-param name="eats-url" select="@ref" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates />
    </a>
  </xsl:template>

  <xsl:template match="tei:space">
    <i>(blank)</i>
  </xsl:template>

  <xsl:template name="make-entity-url">
    <xsl:param name="eats-url" />
    <xsl:variable name="entity-id"
                  select="substring-before(substring-after(@ref, '/entity/'), '/')" />
    <xsl:value-of select="kiln:url-for-match('ereed-entity-display-html', ($entity-id), 0)" />
  </xsl:template>

</xsl:stylesheet>
