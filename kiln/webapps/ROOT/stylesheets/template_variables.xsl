<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Variables for snippets of static HTML that are repeated due to
       accessibility variations. -->

  <xsl:variable name="helpful_links">
    <div class="tools">
      <div class="tools-heading show-for-medium">HELPFUL LINKS</div>
      <ul class="no-padding">
        <li><a href="{kiln:url-for-match('ereed-howto-anatomy', ())}">Anatomy of a Record</a></li>
        <li><a href="{kiln:url-for-match('ereed-about-glossaries', ())}">Glossaries</a></li>
        <li><a href="{kiln:url-for-match('ereed-about-symbols', ())}">Symbols &amp; Abbreviations</a></li>
      </ul>
    </div>
  </xsl:variable>

</xsl:stylesheet>
