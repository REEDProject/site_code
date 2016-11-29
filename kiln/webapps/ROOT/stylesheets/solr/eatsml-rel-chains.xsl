<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to make relationship chains explicit. That is, where A
       relates to B and B relates to C, and the relationship is one
       that implies A also relates to C, then add that explicit A->C
       relationship to A.

       The primary example of this (and the one implemented here) is
       the "is in / contains" relationship for places.

  -->

  <xsl:variable name="contains_id"
                select="'entity_relationship_type-502'" />
  <xsl:variable name="place_types"
                select="('entity_type-539', 'entity_type-4833',
                        'entity_type-541', 'entity_type-543',
                        'entity_type-545', 'entity_type-547',
                        'entity_type-551', 'entity_type-21368')" />

  <xsl:template match="eats:entity_relationship">
    <xsl:copy-of select="." />
    <xsl:variable name="entity_id" select="../../@xml:id" />
    <xsl:if test="../../eats:entity_types/eats:entity_type/@entity_type=$place_types
                  and @entity_relationship_type=$contains_id and
                  @domain_entity=$entity_id">
      <xsl:variable name="range_id" select="@range_entity" />
      <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_id][@domain_entity=$range_id]"
                           mode="recursed">
        <xsl:with-param name="domain_id" select="$entity_id" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eats:entity_relationship" mode="recursed">
    <xsl:param name="domain_id" />
    <eats:entity_relationship>
      <xsl:attribute name="domain_entity" select="$domain_id" />
      <xsl:copy-of select="@authority" />
      <xsl:copy-of select="@certainty" />
      <xsl:copy-of select="@entity_relationship_type" />
      <xsl:copy-of select="@range_entity" />
    </eats:entity_relationship>
    <xsl:variable name="range_id" select="@range_entity" />
    <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_id][@domain_entity=$range_id]"
                         mode="recursed">
        <xsl:with-param name="domain_id" select="$domain_id" />
      </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
