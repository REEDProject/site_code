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

  <xsl:template match="tei:author">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:bibl" mode="bibliography">
    <li>
      <span>
        <xsl:apply-templates />
      </span>
    </li>
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

  <xsl:template match="tei:gap">
    <xsl:choose>
      <xsl:when test="ancestor::tei:ab|ancestor::tei:lg|ancestor::tei:p">
        <xsl:apply-templates mode="actual" select="." />
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates mode="actual" select="." />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:gap[@extent]" mode="actual">
    <xsl:for-each select="1 to @extent">
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:gap[@reason='omitted']" mode="actual">
    <xsl:text>...</xsl:text>
  </xsl:template>

  <xsl:template match="tei:gram" mode="group">
    <i>
      <xsl:value-of select="." />
    </i>
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

  <xsl:template match="tei:idno[@type='author_surname']" mode="doc_desc">
    <br />
    <xsl:text>Author: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='publication']" mode="doc_desc">
    <br />
    <xsl:text>Publication: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='publication_number']" mode="doc_desc">
    <br />
    <xsl:text>Publication number: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='shelfmark']" mode="doc_desc">
    <br />
    <xsl:text>Shelfmark: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='short_title']" mode="doc_desc">
    <br />
    <xsl:text>Work title: </xsl:text>
    <xsl:value-of select="." />
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

  <xsl:template match="tei:ref[not(@target)]">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:repository" mode="doc_desc">
    <br />
    <xsl:text>Repository: </xsl:text>
    <xsl:apply-templates />
  </xsl:template>

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

  <xsl:template match="tei:sense" mode="group">
    <b class="link-to-instance">
      <xsl:value-of select="preceding-sibling::tei:form[1]/tei:orth" />
    </b>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="group" select="preceding::tei:gram[1]" />
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="tei:settlement" mode="doc_desc">
    <br />
    <xsl:text>Repository location: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:space">
    <i>(blank)</i>
  </xsl:template>

  <xsl:template match="tei:term[@ref]">
    <span class="term" note="{substring-after(@ref, '#')}">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:term[@ref]" mode="group">
    <xsl:variable name="sense-id" select="substring-after(@ref, '#')" />
    <li note="{$sense-id}">
      <xsl:apply-templates mode="group" select="id($sense-id)" />
    </li>
  </xsl:template>

  <xsl:template match="tei:ab//tei:title|tei:p//tei:title">
    <i>
      <xsl:apply-templates select="@*|node()" />
    </i>
  </xsl:template>

  <xsl:template name="get-entity-id-from-url">
    <xsl:param name="eats-url" />
    <xsl:value-of select="substring-before(substring-after($eats-url, '/entity/'), '/')" />
  </xsl:template>

  <xsl:template name="make-entity-url">
    <xsl:param name="eats-url" />
    <xsl:variable name="entity-id">
      <xsl:call-template name="get-entity-id-from-url">
        <xsl:with-param name="eats-url" select="$eats-url" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="kiln:url-for-match('ereed-entity-display-html', ($entity-id), 0)" />
  </xsl:template>

</xsl:stylesheet>
