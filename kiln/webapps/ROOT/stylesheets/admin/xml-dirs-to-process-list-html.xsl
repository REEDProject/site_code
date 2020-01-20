<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:dir="http://apache.org/cocoon/directory/2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl"/>
  <xsl:include href="cocoon://_internal/url/reverse.xsl" />

  <xsl:template match="/aggregation/dir:directory" mode="tei">
    <h3>TEI</h3>

    <p>
      <a class="button round"
         href="{kiln:url-for-match('local-solr-index-all', (), 0)}">
        <xsl:text>Index all records (search)</xsl:text>
      </a>
      <xsl:text> </xsl:text>
      <a class="button round"
         href="{kiln:url-for-match('local-admin-entity-record-dates', (), 0)}">
        <xsl:text>Show entities by date</xsl:text>
      </a>
      <!--<a class="button round"
         href="{kiln:url-for-match('local-rdf-harvest-all-display', (), 0)}">
        <xsl:text>Harvest all (RDF)</xsl:text>
      </a>-->
    </p>

    <form method="get" action="{kiln:url-for-match('local-admin-concordance-word-lists-report', (), 0)}">
      <table id="table">
        <thead>
          <tr>
            <th scope="col"></th>
            <th scope="col">File</th>
            <th scope="col">Reports</th>
            <th scope="col">Search</th>
            <th scope="col">View</th>
          </tr>
        </thead>
        <tbody>
          <!-- The bibliography.xml file must be present, with that
               name, in the tei directory, so just record it here. -->
          <tr>
            <td></td>
            <!-- File path. -->
            <td>
              <xsl:text>bibliography.xml</xsl:text>
            </td>
            <td></td>
            <td>
              <a title="Index document in search server"
                 href="{kiln:url-for-match('local-solr-index', ('tei-bibliography', 'tei/bibliography'), 0)}">
                <xsl:text>Index</xsl:text>
              </a>
            </td>
            <td>
              <a href="{kiln:url-for-match('ereed-about-bibliography', (), 0)}">
                <xsl:text>View on site</xsl:text>
              </a>
            </td>
          </tr>
          <!-- The glossary.xml file must be present, with that name,
               in the tei directory, so just record it here. -->
          <tr>
            <td></td>
            <td>
              <xsl:text>glossary.xml</xsl:text>
            </td>
            <td>
              <a href="{kiln:url-for-match('local-admin-glossary-report', (), 0)}" title="Report on missing orth and gram elements">
                <xsl:text>Missing orth/gram</xsl:text>
              </a>
            </td>
            <td></td>
            <td>
              <a href="{kiln:url-for-match('ereed-about-glossaries', (), 0)}">
                <xsl:text>View on site</xsl:text>
              </a>
            </td>
          </tr>
          <!-- Records are the dynamic files (in that it's not known
               how many there are or what they are called). -->
          <xsl:apply-templates mode="tei"
                               select=".//dir:directory[@name='records']">
            <xsl:with-param name="path" select="'tei/'" />
          </xsl:apply-templates>
        </tbody>
      </table>

      <div class="row">
        <div class="large-8 columns">
          <select id="format_select" name="format">
            <option value="html">HTML</option>
            <option value="csv">CSV</option>
          </select>
        </div>
        <div class="large-4 columns">
          <input class="button round" type="submit" value="Generate concordance" />
        </div>
      </div>
    </form>
  </xsl:template>

  <xsl:template match="dir:directory" mode="#all">
    <xsl:param name="path"/>
    <xsl:variable name="new_path" select="concat($path, @name, '/')"/>
    <xsl:apply-templates select="dir:file" mode="#current">
      <xsl:with-param name="path" select="$new_path"/>
      <xsl:with-param name="parent-dir" select="@name" />
    </xsl:apply-templates>
    <xsl:apply-templates select="dir:directory" mode="#current">
      <xsl:with-param name="path" select="$new_path"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="dir:file" mode="tei" />

  <xsl:template match="dir:file[ends-with(@name, '.xml')]" mode="tei">
    <xsl:param name="path"/>
    <xsl:param name="parent-dir" />
    <xsl:variable name="filepath">
      <xsl:value-of select="$path"/>
      <xsl:value-of select="substring-before(@name, '.xml')"/>
    </xsl:variable>
    <xsl:variable name="short-filepath">
      <xsl:value-of select="substring-after($filepath, 'tei/')" />
    </xsl:variable>
    <xsl:variable name="basename">
      <xsl:value-of select="substring-after($short-filepath, '/')" />
    </xsl:variable>
    <tr>
      <td><input type="checkbox" name="docs" value="{$filepath}" /></td>
      <!-- File path. -->
      <td>
        <xsl:value-of select="$short-filepath"/>
        <xsl:text>.xml</xsl:text>
      </td>
      <td>
        <a href="{kiln:url-for-match('local-admin-collection-editing-csv', ($basename), 0)}" title="Generate CSV file for capturing editor feedback on individual records">Generate editing CSV</a>
      </td>
      <!-- Default Schematron link. -->
      <!--<td>
        <a title="Schematron validation report"
           href="{kiln:url-for-match('local-admin-schematron-validation',
                 ($filepath), 0)}">
          <xsl:text>Schematron</xsl:text>
        </a>
        </td>-->
      <!-- Search indexing. -->
      <td>
        <xsl:variable name="content-type">
          <xsl:text>tei</xsl:text>
          <xsl:if test="$parent-dir != 'tei'">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$parent-dir" />
          </xsl:if>
        </xsl:variable>
        <a title="Index document in search server"
           href="{kiln:url-for-match('local-solr-index',
                 ($content-type, $filepath), 0)}">
          <xsl:text>Index</xsl:text>
        </a>
      </td>
      <td>
        <a href="{kiln:url-for-match('local-admin-collection-records',
                 ($basename), 0)}">
          <xsl:text>View all records</xsl:text>
        </a>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
