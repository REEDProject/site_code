<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT adds the Solr query parameters passed in the
       query-string parameter to an XML query document (root element
       "query"). The document is only added to, with the new elements
       added after the existing ones.

       This XSLT overrides the Kiln version with the same name, since
       it must handle range queries based on two different fields.

       A q element in the XML query document may have a type attribute
       with value "default" to indicate that it should be used if and
       only if there are no q parameters (that are not empty) in the
       query-string.

  -->

  <xsl:import href="../../kiln/stylesheets/solr/merge-parameters.xsl" />

  <xsl:template name="handle-querystring-parameter">
    <xsl:param name="key" />
    <xsl:param name="value" />
    <xsl:param name="q_fields" />
    <xsl:choose>
      <xsl:when test="$key = 'date_from'">
        <xsl:variable name="real_value">
          <xsl:choose>
            <xsl:when test="$value">
              <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>
              <!-- This is sufficiently long before "the Middle Ages"
                   when REED begins. -->
              <xsl:text>1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <record_date type="range_start">
          <xsl:call-template name="kiln:escape-value">
            <xsl:with-param name="value" select="$real_value" />
            <xsl:with-param name="url-escaped" select="1" />
          </xsl:call-template>
        </record_date>
      </xsl:when>
      <xsl:when test="$key = 'date_to'">
        <xsl:variable name="real_value">
          <xsl:choose>
            <xsl:when test="$value">
              <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>
              <!-- This is suitably long after 1642, the year REED
                   stops. -->
              <xsl:text>2000</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <record_date type="range_end">
          <xsl:call-template name="kiln:escape-value">
            <xsl:with-param name="value" select="$real_value" />
            <xsl:with-param name="url-escaped" select="1" />
          </xsl:call-template>
        </record_date>
      </xsl:when>
      <xsl:when test="normalize-space($value)">
        <xsl:choose>
          <xsl:when test="$key = $q_fields">
            <xsl:element name="q">
              <xsl:value-of select="$key" />
              <xsl:text>:</xsl:text>
              <xsl:call-template name="kiln:escape-value">
                <xsl:with-param name="value" select="$value" />
                <xsl:with-param name="url-escaped" select="1" />
              </xsl:call-template>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="{$key}">
              <xsl:call-template name="kiln:escape-value">
                <xsl:with-param name="value" select="$value" />
                <xsl:with-param name="url-escaped" select="1" />
              </xsl:call-template>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
