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

  <xsl:import href="utils.xsl" />

  <xsl:template match="tei:add">
    <xsl:apply-templates />
  </xsl:template>

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

  <xsl:template match="tei:choice" mode="abbreviations">
    <tr>
      <td>
        <xsl:value-of select="tei:abbr" />
      </td>
      <td>
        <xsl:value-of select="tei:expan" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:ex">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:figure">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:gap[@extent]">
    <xsl:text>&lt;</xsl:text>
    <xsl:for-each select="1 to @extent">
      <xsl:text>.</xsl:text>
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:gap[@reason='omitted']">
    <xsl:text>...</xsl:text>
  </xsl:template>

  <xsl:template match="tei:gram">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:graphic">
    <img src="{$kiln:assets-path}{@url}" />
  </xsl:template>

  <xsl:template match="tei:graphic[@type='smartframe']">
    <script src="{@url}" data-image-id="{@n}" data-theme="aco" data-width="100%"></script>
  </xsl:template>

  <xsl:template match="tei:handShift">
    <xsl:text>°</xsl:text>
  </xsl:template>

  <xsl:template match="tei:front/tei:div/tei:head" />

  <xsl:template match="tei:front/tei:div//tei:div/tei:head">
    <xsl:variable name="level" select="count(ancestor::tei:div)+1" />
    <xsl:element name="h{$level}">
      <xsl:attribute name="id" select="generate-id(..)" />
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <!-- Superscript -->
  <xsl:template match="tei:hi[@rend='superscript']">
    <sup>
      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <xsl:template match="tei:text[@type='record']/tei:body/tei:div/tei:div/tei:head">
    <p>
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>

  <xsl:template match="tei:idno[@type='authorSurname']" mode="doc_desc">
    <br />
    <xsl:text>Author: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='publication']" mode="doc_desc">
    <br />
    <xsl:text>Publication: </xsl:text>
    <xsl:choose>
      <xsl:when test="normalize-space() = 'STC Pollard and Redgrave (eds), Short-Title Catalogue'">
        <xsl:text>STC</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space() = 'Wing Wing, Short-Title Catalogue'">
        <xsl:text>Wing</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:idno[@type='pubNumber']" mode="doc_desc">
    <br />
    <xsl:text>Publication number: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='shelfmark']" mode="doc_desc">
    <br />
    <xsl:text>Shelfmark: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:idno[@type='shortTitle']" mode="doc_desc">
    <br />
    <xsl:text>Work title: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']">
    <table>
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:item" />

  <xsl:template match="tei:list[@type='gloss']/tei:label">
    <tr>
      <td>
        <xsl:apply-templates select="@*|node()" />
      </td>
      <td>
        <xsl:apply-templates select="following-sibling::tei:item[1]/@*" />
        <xsl:apply-templates select="following-sibling::tei:item[1]/node()" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:note[@type='collation']">
    <span class="collation tag" note="{generate-id()}"></span>
  </xsl:template>

  <xsl:template match="tei:note[@type='collation']" mode="group">
    <li note="{generate-id()}">
      <xsl:apply-templates />
    </li>
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
    <span class="marginalia" note="{generate-id()}"></span>
  </xsl:template>

  <xsl:template match="tei:note[@type='marginal']" mode="group">
    <li note="{generate-id()}">
      <xsl:variable name="side" select="substring-after(@place, 'margin_')" />
      <img src="{$kiln:assets-path}/images/marginalia-{$side}.png" />
      <xsl:text> </xsl:text>
      <xsl:apply-templates />
      <xsl:if test=".//tei:note[@type='foot']">
        <p>
          <xsl:text>[Footnote</xsl:text>
          <xsl:if test="count(.//tei:note[@type='foot']) &gt; 1">
            <xsl:text>s</xsl:text>
          </xsl:if>
          <xsl:text>: </xsl:text>
          <xsl:for-each select=".//tei:note[@type='foot']">
            <xsl:apply-templates />
            <xsl:if test="position() != last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:text>]</xsl:text>
        </p>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="tei:orth">
    <b>
      <xsl:apply-templates />
    </b>
  </xsl:template>

  <xsl:template match="tei:pb">
    <xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="tei:div/tei:pb" />

  <xsl:template match="tei:ptr[@target]">
    <a href="{@target}">
      <xsl:apply-templates select="@*|node()" />
    </a>
  </xsl:template>

  <xsl:template match="tei:quote[@source]">
    <a href="{@source}">
      <q cite="{@source}">
        <xsl:apply-templates select="@*|node()" />
      </q>
    </a>
  </xsl:template>

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

  <xsl:template match="tei:seg[@type='signed']">
    <span>
      <xsl:apply-templates select="@*" />
      <xsl:call-template name="tei-assign-classes" />
      <i>(signed)</i>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="node()" />
    </span>
  </xsl:template>

  <xsl:template match="tei:sense" mode="group">
    <span class="link-to-instance">
      <xsl:apply-templates select="preceding-sibling::tei:form[1]" />
    </span>
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

  <xsl:template match="tei:supplied">
    <i>
      <xsl:apply-templates />
    </i>
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

  <xsl:template match="tei:ab//tei:title|tei:bibl//tei:title|tei:p//tei:title">
    <i>
      <xsl:apply-templates select="@*|node()" />
    </i>
  </xsl:template>

  <!-- tei:bibl included in a record heading should not italicise titles. -->
  <xsl:template match="tei:head/tei:bibl/tei:title" priority="10">
    <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <xsl:template match="tei:quote">
    <xsl:choose>
      <xsl:when test=".//tei:ab | .//tei:p | .//tei:list | .//tei:table | .//tei:lg | .//tei:floatingText">
        <blockquote>
          <xsl:apply-templates select="@*|node()" />
        </blockquote>
      </xsl:when>
      <xsl:otherwise>
        <q>
          <xsl:apply-templates select="@*|node()" />
        </q>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@kiln:title">
    <xsl:attribute name="title" select="." />
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
