<xsl:transform version="3.0" 
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:h="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               exclude-result-prefixes="h fn xs">
  <xsl:output
     method="xml"
     indent="yes"
     doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with MathML3 v1.1 20151215//EN"
     doctype-system="JATS-journalpublishing1-mathml3.dtd"
     />

  <xsl:param name="translatedFile" as="xs:string" select="''"/>
  <xsl:param name="translatedDoc" as="document-node()?" select="fn:doc($translatedFile)"/>
  <xsl:variable name="translatedLang" select="$translatedDoc/article/@xml:lang"/>
  <xsl:variable name="originalArticle" select="/article"/>
  <xsl:variable name="originalLang" select="$originalArticle/@xml:lang"/>

  <xsl:template match="article">
    <xsl:copy>
      <xsl:copy-of select="@*|*"/>
      <sub-article id="{fn:concat('article-', $translatedLang)}">
        <xsl:apply-templates select="$translatedDoc/article/@*[name()!='dtd-version']"/>
        <front-stub>
          <!-- Skip journal-meta fields, should all be the same. -->
          <!-- Copy article-meta fields that differ from original article. -->
          <xsl:for-each select="$translatedDoc/article/front/article-meta/*">
            <xsl:variable name="name" select="name(.)"/>
            <xsl:variable name="hasSame">
              <xsl:choose>
                <!-- Always convert contrib-group and all
                     (aff or aff-alternatives)
                     to make it easier for casual readers, 
                     and to ensure matching id and rid are both present. -->
                <xsl:when test="self::contrib-group or self::aff-alternatives or
                                self::aff">false</xsl:when>
                <xsl:when test="@xml:lang">
                  <xsl:variable name="lang" select="@xml:lang"/>
                  <xsl:value-of select=". = $originalArticle/front/article-meta/*[name(.)=$name and @xml:lang=$lang]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select=". = $originalArticle/front/article-meta/*[name(.)=$name]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$hasSame='false'">
              <xsl:apply-templates select="."/>
            </xsl:if>
          </xsl:for-each>
        </front-stub>
        <xsl:apply-templates select="$translatedDoc/article/front/following-sibling::*"/>
      </sub-article>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="article-id[@pub-id-type='doi']">
    <xsl:variable name="originalDOI" select="$originalArticle/front/article-meta/article-id[@pub-id-type='doi']/text()"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- trans-title-group within subarticle is wrongly checked against
       article language rather than subarticle language, so comment it out -->
  <xsl:template match="trans-title-group[@xml:lang=$originalLang]">
    <xsl:comment>
      <xsl:text>&lt;trans-title-group xml:lang="</xsl:text>
      <xsl:value-of select="$originalLang"/>
      <xsl:text>"&gt;</xsl:text>
      <xsl:for-each select="*">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lt;/trans-title-group&gt;</xsl:text>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="@id|@rid">
    <xsl:attribute name="{name()}" select="fn:concat($translatedLang, '-', .)"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
