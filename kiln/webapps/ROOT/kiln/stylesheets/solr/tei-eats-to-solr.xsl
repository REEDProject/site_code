<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a TEI document together with an EATSML
       document into a Solr index document. -->

  <!-- Path to the TEI file being indexed. -->
  <xsl:param name="file-path" />

  <!-- Add error logging -->
  <xsl:template name="log-error">
    <xsl:param name="message"/>
    <doc>
      <field name="type">error_log</field>
      <field name="error_message"><xsl:value-of select="$message"/></field>
      <field name="source_file"><xsl:value-of select="$file-path"/></field>
    </doc>
  </xsl:template>

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
    <!-- Create a log document to verify that processing started -->
    <doc>
      <field name="type">processing_log</field>
      <field name="message">Started processing file</field>
      <field name="file_path"><xsl:value-of select="$file-path"/></field>
    </doc>

    <!-- Log any text elements with copyOf -->
    <xsl:for-each select="//tei:text[@copyOf]">
      <doc>
        <field name="type">found_copyOf</field>
        <field name="copyOf_value"><xsl:value-of select="@copyOf"/></field>
        <field name="element_id"><xsl:value-of select="@xml:id"/></field>
      </doc>

      <xsl:variable name="ref" select="@copyOf"/>
      <xsl:variable name="doc-name" select="substring-before($ref, '#')"/>
      <xsl:variable name="element-id" select="substring-after($ref, '#')"/>
      
      <!-- Try multiple possible paths to find the referenced document -->
      <xsl:variable name="doc-paths" as="xs:string*">
        <xsl:sequence select="$doc-name"/> <!-- Try direct path -->
        <xsl:sequence select="concat(replace($file-path, '[^/]+$', ''), $doc-name)"/> <!-- Try relative to current file -->
        <xsl:sequence select="concat('../', $doc-name)"/> <!-- Try one level up -->
      </xsl:variable>

      <xsl:variable name="referenced-doc">
        <xsl:for-each select="$doc-paths">
          <xsl:try>
            <xsl:sequence select="document(.)"/>
            <!-- Log successful document load -->
            <doc>
              <field name="type">document_load_success</field>
              <field name="path"><xsl:value-of select="."/></field>
            </doc>
            <xsl:catch>
              <!-- Log failed attempt -->
              <doc>
                <field name="type">document_load_error</field>
                <field name="attempted_path"><xsl:value-of select="."/></field>
                <field name="error"><xsl:value-of select="$err:description"/></field>
              </doc>
            </xsl:catch>
          </xsl:try>
        </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$referenced-doc">
          <xsl:variable name="referenced-text" select="$referenced-doc//*[@xml:id=$element-id]"/>
          <xsl:choose>
            <xsl:when test="$referenced-text">
              <!-- Create solr document -->
              <doc>
                <xsl:sequence select="$document-metadata"/>
                <field name="file_path"><xsl:value-of select="$file-path"/></field>
                <field name="document_id"><xsl:value-of select="@xml:id"/></field>
                <field name="type">copied_record</field>
                <field name="original_document"><xsl:value-of select="$doc-name"/></field>
                <field name="original_id"><xsl:value-of select="$element-id"/></field>
                <field name="text"><xsl:value-of select="normalize-space($referenced-text)"/></field>
              </doc>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="log-error">
                <xsl:with-param name="message" select="concat('Could not find element with id: ', $element-id)"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log-error">
            <xsl:with-param name="message" select="concat('Could not load document: ', $doc-name)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <!-- Process regular documents  -->
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <xsl:sequence select="$document-metadata"/>
        <field name="file_path"><xsl:value-of select="$file-path"/></field>
        <field name="document_id"><xsl:value-of select="/*/tei/tei:*/@xml:id"/></field>
        <field name="type">original_record</field>
        <field name="text"><xsl:value-of select="normalize-space($free-text)"/></field>
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
