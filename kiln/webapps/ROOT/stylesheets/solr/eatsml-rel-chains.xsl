<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to make relationship chains explicit. That is, where A
       relates to B and B relates to C, and the relationship is one
       that implies A also relates to C, then add that explicit A->C
       relationship to A.

       Implemented here:

         * Place containment.

         * Office holding (holding an office that is a specific form
           of a more general office)

  -->

  <xsl:variable name="contains_id"
                select="'entity_relationship_type-502'" />
  <xsl:variable name="holds_office_id"
                select="'entity_relationship_type-34962'" />
  <xsl:variable name="is_subset_of_id"
                select="'entity_relationship_type-499'" />
  <xsl:variable name="office_types" select="('entity_type-25986')" />
  <xsl:variable name="place_types"
                select="('entity_type-539', 'entity_type-4833',
                        'entity_type-541', 'entity_type-543',
                        'entity_type-545', 'entity_type-547',
                        'entity_type-551', 'entity_type-21368')" />

  <xsl:template match="eats:entity_relationship">
    <xsl:copy-of select="." />
    <xsl:variable name="entity_id" select="../../@xml:id" />
    <xsl:variable name="range_id" select="@range_entity" />
    <!-- Place containment: every place that is contained by another
         place is also contained by every place that contains that
         other place. -->
    <xsl:if test="../../eats:entity_types/eats:entity_type/@entity_type=$place_types and
                  @entity_relationship_type=$contains_id and
                  @domain_entity=$entity_id">
      <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_id][@domain_entity=$range_id]"
                           mode="recursed_contains">
        <xsl:with-param name="domain_id" select="$entity_id" />
      </xsl:apply-templates>
    </xsl:if>
    <!-- Office type subsets: an office counts as every office it is a
         subset of. -->
    <xsl:if test="../../eats:entity_types/eats:entity_type/@eats_id = $office_types and
                  @entity_relationship_type = $is_subset_of_id and
                  @domain_entity = $entity_id">
      <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$is_subset_of_id][@domain_entity=$range_id]"
                           mode="recursed_subset">
        <xsl:with-param name="certainty" select="@certainty" />
        <xsl:with-param name="domain_id" select="$entity_id" />
        <xsl:with-param name="relationship_type_id"
                        select="@entity_relationship_type" />
      </xsl:apply-templates>
    </xsl:if>
    <!-- Holding office subsets: an entity that holds an office also
         holds every office that is a superset of that office. -->
    <xsl:if test="@entity_relationship_type=$holds_office_id and
                  @domain_entity=$entity_id">
      <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$is_subset_of_id][@domain_entity=$range_id]"
                           mode="recursed_subset">
        <xsl:with-param name="certainty" select="@certainty" />
        <xsl:with-param name="domain_id" select="$entity_id" />
        <xsl:with-param name="relationship_type_id"
                        select="@entity_relationship_type" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- Containment. -->
  <xsl:template match="eats:entity_relationship" mode="recursed_contains">
    <xsl:param name="domain_id" />
    <entity_relationship>
      <xsl:attribute name="domain_entity" select="$domain_id" />
      <xsl:copy-of select="@authority" />
      <xsl:copy-of select="@certainty" />
      <xsl:copy-of select="@entity_relationship_type" />
      <xsl:copy-of select="@range_entity" />
    </entity_relationship>
    <xsl:variable name="range_id" select="@range_entity" />
    <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$contains_id][@domain_entity=$range_id]"
                         mode="recursed_contains">
        <xsl:with-param name="domain_id" select="$domain_id" />
      </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="eats:entity_relationship"
                mode="recursed_subset">
    <!-- Rather than creating a copy of the relationship with the
         domain entity substituted, here the relationship type and
         certainty must also be substituted from the original. -->
    <xsl:param name="certainty" />
    <xsl:param name="domain_id" />
    <xsl:param name="relationship_type_id" />
    <entity_relationship>
      <xsl:copy-of select="@authority" />
      <xsl:attribute name="certainty" select="$certainty" />
      <xsl:attribute name="domain_entity" select="$domain_id" />
      <xsl:attribute name="entity_relationship_type"
                     select="$relationship_type_id" />
      <xsl:copy-of select="@range_entity" />
    </entity_relationship>
    <xsl:variable name="range_id" select="@range_entity" />
    <xsl:apply-templates select="id($range_id)/eats:entity_relationships/eats:entity_relationship[@entity_relationship_type=$is_subset_of_id][@domain_entity=$range_id]"
                         mode="recursed_subset">
      <xsl:with-param name="certainty" select="$certainty" />
      <xsl:with-param name="domain_id" select="$domain_id" />
      <xsl:with-param name="relationship_type_id"
                      select="$relationship_type_id" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
