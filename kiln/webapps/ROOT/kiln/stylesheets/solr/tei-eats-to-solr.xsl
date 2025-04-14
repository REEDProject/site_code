<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a TEI document together with an EATSML
       document into a Solr index document. -->

  <!-- Path to the TEI file being indexed. -->
  <xsl:param name="file-path" />

  <xsl:variable name="document-metadata">
    <xsl:apply-templates mode="document-metadata"
                         select="/*/tei/*/tei:teiHeader" />
  </xsl:variable>

  <xsl:variable name="free-text">
    <!-- Modified to handle both regular and copyOf text elements -->
    <xsl:apply-templates mode="free-text" select="/*/tei/*/tei:text[not(@copyOf)]" />
    <xsl:for-each select="/*/tei/*/tei:text[@copyOf]">
      <!-- Debug info -->
      <field name="debug_found_copyOf">true</field>
      <field name="debug_copyOf_value"><xsl:value-of select="@copyOf"/></field>
      
      <xsl:variable name="ref" select="@copyOf"/>
      <xsl:variable name="doc-name" select="substring-before($ref, '#')"/>
      <xsl:variable name="element-id" select="substring-after($ref, '#')"/>
      
      <!-- Debug info -->
      <field name="debug_doc_name"><xsl:value-of select="$doc-name"/></field>
      <field name="debug_element_id"><xsl:value-of select="$element-id"/></field>
      
      <xsl:variable name="referenced-doc" select="document($doc-name)"/>
      <!-- Debug info -->
      <field name="debug_doc_loaded">
        <xsl:choose>
          <xsl:when test="$referenced-doc">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </field>
      
      <xsl:if test="$referenced-doc">
        <xsl:apply-templates mode="free-text" select="$referenced-doc//*[@xml:id=$element-id]"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <!-- Process text elements with copyOf -->
    <xsl:for-each select="/*/tei/*/tei:text[@copyOf]">
      <xsl:variable name="ref" select="@copyOf"/>
      <xsl:variable name="doc-name" select="substring-before($ref, '#')"/>
      <xsl:variable name="element-id" select="substring-after($ref, '#')"/>
      
      <!-- Try to resolve the document path relative to the current file -->
      <xsl:variable name="current-dir" select="replace($file-path, '[^/]+$', '')"/>
      <xsl:variable name="full-doc-path" select="concat($current-dir, $doc-name)"/>
      
      <!-- Debug document -->
      <doc>
        <field name="debug_type">copy_processing</field>
        <field name="debug_current_file"><xsl:value-of select="$file-path"/></field>
        <field name="debug_ref"><xsl:value-of select="$ref"/></field>
        <field name="debug_doc_name"><xsl:value-of select="$doc-name"/></field>
        <field name="debug_element_id"><xsl:value-of select="$element-id"/></field>
        <field name="debug_full_path"><xsl:value-of select="$full-doc-path"/></field>
      </doc>

      <xsl:variable name="referenced-doc" select="document($full-doc-path)"/>
      <xsl:variable name="referenced-text" select="$referenced-doc//*[@xml:id=$element-id]"/>
      
      <xsl:if test="$referenced-text">
        <doc>
          <xsl:sequence select="$document-metadata" />

          <field name="file_path">
            <xsl:value-of select="$file-path" />
          </field>
          <field name="document_id">
            <xsl:value-of select="@xml:id" />
          </field>
          <field name="original_document">
            <xsl:value-of select="$doc-name" />
          </field>
          <field name="original_id">
            <xsl:value-of select="$element-id" />
          </field>

          <field name="text">
            <xsl:value-of select="normalize-space($referenced-text)" />
          </field>
        </doc>

        <!-- Process any entity mentions in the referenced text -->
        <xsl:apply-templates mode="entity-mention" select="$referenced-text//tei:*[@key]" />
      </xsl:if>
    </xsl:for-each>

    <!-- Text content for non-copyOf elements -->
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <xsl:sequence select="$document-metadata" />

        <field name="file_path">
          <xsl:value-of select="$file-path" />
        </field>
        <field name="document_id">
          <xsl:value-of select="/*/tei/tei:*/@xml:id" />
        </field>

        <field name="text">
          <xsl:value-of select="normalize-space($free-text)" />
        </field>
      </doc>
    </xsl:if>

    <!-- Process regular entity mentions -->
    <xsl:apply-templates mode="entity-mention" select="/*/tei/*/tei:text//tei:*[@key]" />
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title"
                mode="document-metadata">
    <field name="document_title">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:author"
                mode="document-metadata">
    <field name="author">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:editor"
                mode="document-metadata">
    <field name="editor">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:sourceDesc//tei:publicationStmt/tei:date[1]"
                mode="document-metadata">
    <xsl:if test="@when">
      <field name="publication_date">
        <xsl:value-of select="@when" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()" mode="document-metadata" />

  <xsl:template match="node()" mode="free-text">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:*[@key]" mode="entity-mention">
    <doc>
      <xsl:sequence select="$document-metadata" />

      <xsl:variable name="entity-key" select="@key" />

      <field name="file_path">
        <xsl:value-of select="$file-path" />
      </field>
      <field name="document_id">
        <xsl:value-of select="/*/tei/tei:*/@xml:id" />
      </field>
      <field name="section_id">
        <xsl:value-of
          select="ancestor::tei:*[self::tei:div or self::tei:body or self::tei:front or self::tei:back or self::tei:group or self::tei:text][@xml:id][1]/@xml:id"
         />
      </field>
      <field name="entity_key">
        <xsl:value-of select="$entity-key" />
      </field>
      <field name="entity_name">
        <xsl:value-of select="normalize-space(.)" />
      </field>

      <xsl:for-each select="/*/eats/entities/entity[keys/key = $entity-key]/names/name">
        <field name="eats_entity_name">
          <xsl:value-of select="normalize-space(.)" />
        </field>
      </xsl:for-each>
    </doc>
  </xsl:template>
</xsl:stylesheet>
