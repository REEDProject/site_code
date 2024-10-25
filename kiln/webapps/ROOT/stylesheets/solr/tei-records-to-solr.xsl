<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert a TEI document containing eREED records and
       full EATSML into a Solr index document. -->

  <xsl:param name="file-path" />

  <xsl:key name="entities-by-url" match="/aggregation/eatsml/entities/entity"
           use="@url" />

  <xsl:template match="/">
    <add>
      <!-- Treat each eREED record as its own Solr document. -->
      <xsl:apply-templates select="/aggregation/tei/tei:TEI/tei:text/tei:group/tei:text[@type='record']" />
      <!-- Index front and back matter. -->
      <xsl:apply-templates select="/aggregation/tei/tei:TEI/tei:text/tei:front/tei:div" mode="editorial" />
      <xsl:apply-templates select="/aggregation/tei/tei:TEI/tei:text/tei:back/tei:div" mode="editorial" />
    </add>
  </xsl:template>

  <xsl:template match="tei:div" mode="editorial">
    <doc>
      <field name="file_path">
        <xsl:value-of select="$file-path" />
      </field>
      <field name="document_id">
        <xsl:value-of select="@xml:id" />
      </field>
      <field name="document_type">
        <xsl:text>editorial</xsl:text>
      </field>
      <field name="document_title">
        <xsl:value-of select="tei:head" />
      </field>
      <!-- While this isn't a record, it's convenient to have a
           record_title for search result display that has both record
           and editorial results. -->
      <field name="record_title">
        <xsl:value-of select="tei:head" />
      </field>
      <field name="collection_id">
        <xsl:value-of select="/aggregation/tei/tei:TEI/@xml:id" />
      </field>
      <xsl:apply-templates mode="entity-mention"
                           select=".//tei:*[local-name()=('name', 'rs')][@ref]" />
    </doc>
  </xsl:template>
  
  <!-- New template to handle records that are shared between collections -->
  <xsl:template match="tei:text[@copyOf]">
    <xsl:variable name="target" select="@copyOf" />
    <xsl:apply-templates select="id($target)" />
  </xsl:template>

  <xsl:template match="tei:text[@type='record'][not (@copyOf)]">
    <xsl:variable name="free-text">
      <xsl:apply-templates mode="free-text" select="." />
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="free-text-notes" select=".//tei:note" />
    </xsl:variable>
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <field name="file_path">
          <xsl:value-of select="$file-path" />
        </field>
        <field name="document_id">
          <xsl:value-of select="@xml:id" />
        </field>
        <field name="document_type">
          <xsl:text>record</xsl:text>
        </field>
        <field name="document_title">
          <xsl:variable name="document_title">
            <xsl:value-of select="tei:body/tei:head/tei:date" />
            <xsl:text>, </xsl:text>
            <!-- QAZ: Use EATSML name? -->
            <xsl:value-of select="tei:body/tei:head/tei:rs[1]" />
            <xsl:if test="tei:body/tei:head/tei:rs[2]">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="tei:body/tei:head/tei:rs[2]" />
            </xsl:if>
            <xsl:text>. </xsl:text>
            <xsl:value-of select="tei:body/tei:head/tei:bibl[1]/tei:title" />
            <xsl:text>. </xsl:text>
            <xsl:value-of select="tei:body/tei:head/tei:bibl[1]/tei:span[@type='shelfmark'][@subtype='text']" />
          </xsl:variable>
          <xsl:value-of select="normalize-space($document_title)" />
        </field>
        <field name="collection_id">
          <xsl:value-of select="/aggregation/tei/tei:TEI/@xml:id" />
        </field>
        <xsl:for-each select="tokenize(@other_collection_ids, '\s+')">
          <field name="collection_id">
            <xsl:value-of select="." />
          </field>
        </xsl:for-each>
        <field name="record_title">
          <xsl:value-of select="normalize-space(tei:body/tei:head/tei:bibl[1]/tei:title)" />
        </field>
        <field name="record_location">
          <!-- QAZ: Use EATSML name? -->
          <xsl:for-each select="tei:body/tei:head/tei:rs">
            <xsl:value-of select="normalize-space()" />
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </field>
        <field name="record_location_id">
          <xsl:text>entity-</xsl:text>
          <xsl:variable name="location_ref">
            <xsl:choose>
              <xsl:when test="tei:body/tei:head/tei:rs[@role='recMapLoc']">
                <xsl:value-of select="tei:body/tei:head/tei:rs[@role='recMapLoc']/@ref" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="tei:body/tei:head/tei:rs[position()=last()]/@ref" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="substring-before(substring-after($location_ref, '/entity/'), '/')" />
        </field>
        <field name="record_shelfmark">
          <xsl:value-of select="tei:body/tei:head/tei:bibl[1]/tei:span[@type='shelfmark'][@subtype='text']" />
        </field>
        <xsl:apply-templates select="tei:body/tei:head/tei:date" />
        <field name="record_date_display">
          <xsl:value-of select="tei:body/tei:head/tei:date" />
        </field>
        <field name="text">
          <xsl:value-of select="normalize-space($free-text)" />
        </field>
        <xsl:apply-templates mode="record_type"
                             select="tei:index[@indexName='record_type']/tei:term" />
        <xsl:apply-templates mode="entity-mention"
                             select=".//tei:*[local-name()=('name', 'rs')]
                                     [@ref]" />
        <xsl:apply-templates mode="entity-mention"
                             select="tei:index[@indexName='associated_entity']/tei:term" />
        <xsl:apply-templates mode="entity-facet"
                             select=".//tei:*[local-name()=('name', 'rs')]
                                     [@ref]" />
        <xsl:apply-templates mode="entity-facet"
                             select="tei:index[@indexName='associated_entity']/tei:term" />
      </doc>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:date">
    <xsl:choose>
      <xsl:when test="@when-iso">
        <field name="record_date">
          <xsl:value-of select="@when-iso" />
        </field>
      </xsl:when>
      <xsl:when test="@from-iso and @to-iso">
        <xsl:for-each select="@from-iso to @to-iso">
          <field name="record_date">
            <xsl:value-of select="." />
          </field>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:term" mode="record_type">
    <!-- This parcelling of values into different fields based on the
         value is a hack; it should be done via the hierarchy
         expressed in the record_types category in
         taxonomy.xml. However, that information is not present at
         this point in processing, so a more wide-reaching code change
         is required. -->
    <xsl:variable name="value" select="normalize-space()" />
    <xsl:variable name="field_name">
      <xsl:text>facet_record_type_</xsl:text>
      <xsl:choose>
        <xsl:when test="$value = ('Parliament', 'Council of the North', 'Courts of Law', 'Royal', 'Privy Council')">
          <xsl:text>central_gov</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Chronicles', 'Historiography')">
          <xsl:text>chronicles</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Archdiocesan/Diocesan Administration', 'Ecclesiastical Courts', 'Parish')">
          <xsl:text>church</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Schools', 'Universities', 'Inns of Court')">
          <xsl:text>education</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Household', 'Personal', 'Estate')">
          <xsl:text>family</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Craft/Trade Guilds', 'Religious Guilds')">
          <xsl:text>guild</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Borough/City', 'County', 'Civil Parish')">
          <xsl:text>local_gov</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Accounts', 'Courts')">
          <xsl:text>manorial</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Inventories', 'Advertisements', 'Memoranda', 'Business', 'Correspondence', 'Estate')">
          <xsl:text>playhouse</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Monasteries', 'Nunneries', 'Friaries')">
          <xsl:text>rel_community</xsl:text>
        </xsl:when>
        <xsl:when test="$value = ('Drama', 'Entertainments', 'Essays',
                                  'Poetry', 'Satire', 'Sermons')">
          <xsl:text>soc_lit</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$value">
      <field name="{$field_name}">
        <xsl:value-of select="$value" />
      </field>
    </xsl:if>
  </xsl:template>

  <!-- Used for the entity reference tool in the Oxygen EATS plugin. -->
  <xsl:template match="tei:*[@ref]" mode="entity-mention">
    <xsl:for-each select="tokenize(@ref, '\p{Z}+')">
      <field name="mentioned_entities">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:*[@ref]" mode="entity-facet">
    <!-- Copy the fields already defined for this entity in the
         EATS-derived data. -->
    <xsl:variable name="node" select="." />
    <!-- This is a kludge to provide a context node when calling
         key(), which is required. -->
    <xsl:for-each select="tokenize(@ref, '\s+')">
      <xsl:variable name="url" select="." />
      <xsl:for-each select="$node">
        <xsl:copy-of select="key('entities-by-url', $url)/field" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- Do not index material brought in about the repository etc of a
       record. -->
  <xsl:template match="tei:index[@indexName='record_type']" mode="free-text" />
  <xsl:template match="tei:index[@indexName='associated_entity']"
                mode="free-text" />
  <xsl:template match="tei:body/tei:head/tei:bibl" mode="free-text">
    <xsl:apply-templates select="tei:title" mode="free-text" />
    <xsl:apply-templates select="tei:p[@type='edDesc']" mode="free-text" />
  </xsl:template>

  <xsl:template match="tei:note" mode="free-text" />

  <xsl:template match="*" mode="free-text">
    <xsl:apply-templates mode="free-text" />
  </xsl:template>

  <xsl:template match="tei:note" mode="free-text-note">
    <xsl:apply-templates mode="free-text" />
  </xsl:template>

</xsl:stylesheet>
