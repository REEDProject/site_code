<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:eats="http://eats.artefact.org.nz/ns/eatsml/"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="entity" select="/aggregation/eats:entities/eats:entity" />

  <xsl:template name="display-entity-primary-name">
    <xsl:value-of select="$entity/primary_name" />
  </xsl:template>

  <xsl:template name="display-entity-title">
    <xsl:value-of select="$entity/title" />
  </xsl:template>

  <xsl:template name="display-related-entities">
    <table class="display related-entities-table responsive" cellspacing="0" width="100%">
      <tbody class="related-content">
        <xsl:for-each select="$entity/relationships/relationship">
          <tr>
            <td class="individual-related-entity">
              <xsl:value-of select="name" />
              <xsl:text> </xsl:text>
              <a href="{entity/@url}"><xsl:value-of select="entity" /></a>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

</xsl:stylesheet>
