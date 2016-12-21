<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="to-html.xsl" />

  <xsl:variable name="record_text"
                select="/aggregation/tei:TEI/tei:text" />
  <xsl:variable name="record_title" select="$record_text/tei:body/tei:head/tei:bibl/tei:title" />

</xsl:stylesheet>
