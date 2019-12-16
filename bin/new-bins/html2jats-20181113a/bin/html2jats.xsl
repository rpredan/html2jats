<?xml version="1.0" encoding="UTF-8"?>
<!--
  Transform an xhtml file (exported from InDesign)
  to JATS 1.1 format acceptable to the PubMedCentral Style Checker.

  The source document generally is in either sl or en, but due to InDesign
  limitations the body lang is always sl-SI.  The actual article language
  is identified with
    body/sidebar[1]/p/span[@class='primary-language']
  Translations of parts of the text have been added.

  The InDesign export does not permit adding xml:lang atributes, so
  some parts of the xhtml are marked during export by adding a 'lang-'
  class, such as "lang-en" for en.

  * body/sidebar[@class='meta-wrapper']
    <p class="aff lang-sl">...</p>
    <p class="aff lang-en">...</p>

  * body/sidebar[@class='meta-wrapper']
    <p class="keywords lang-sl">...</p>
    <p class="keywords lang-en">...</p>

  * body/article
    <h1 class="title sl">...</h1>
    <h1 class="title en">...</h1>

  The authors list is marked during export to indicate, for each name,
  which part is the surname and which part is the given name(s).

  * body/article
    <p class="author">
       <span class="given-names">Gaja Cvejić</span>
       <span class="surname">Vidali</span>
       ,
       <span class="given-names">Samo</span>
       <span class="surname">Zver</span>
    </p>

  If authors have different affiliates, they are marked with a sup
  tag after the end of the name (and after comma if not last author).
  Multiple affiliations are separated by comma within one sup tag.
  Affiliation superscripts must be digits.  Affiliation superscripts
  must match affiliate ids.

  * body/sidebar[@class='meta-wrapper']
    <p class="aff lang-en"><span class="ref-aff">1</span> Faculty of Medicine, University of Maribor, Maribor, Slovenia</p>
    <p class="aff lang-en"><span class="ref-aff">2</span> DNV GL - Healthcare , Strategic Research and Innovation, Norway</p>

  * body/article
    <p class="author" lang="en-US">
       <span class="given-name">Maja</span>
       <span class="surname">Šikić Pogačar</span>,<sup class="sup">1</sup>
       <span class="given-name">Eva</span>
       <span class="surname">Turk</span>,<sup class="sup">1,2</sup>
       <span class="given-name">Dušanka</span>
       <span class="surname">Mičetić Turk</span><sup class="sup">1</sup>
    </p>

  A p with class 'ul' is a list item.  It must start with a span (with
  no class needed) that contains the label for the item, typically a
  bullet character.

  Cross references:

  A span with class="xref" must contain a number that refers to an id in
  the bibliographic reflist.

  A span with class="table-ref" must contain a number that refers to
  the bold number starting the caption of a table following the article.
  The table will be inserted as a float at the first such reference.

  A span with class="fig-ref" must contain a number that refers to
  the bold number starting the caption of a figure following the article.
  The figure will be inserted as a float at the first such reference.

  version: 20181024a
  author: grammal at freelancer for rpredan
-->
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

  <!-- 
    Optional file exported from edifiX JATS plugin.
    If present, this template simply copies two element trees into its output:
    "/article/front/article-meta/custom-meta-group"
    and "/article/back/ref-list".
  -->
  <xsl:param name="reflistFile" as="xs:string" select="''"/>
  <xsl:param name="reflistDoc" as="document-node()?" select="fn:doc($reflistFile)"/>

  <!-- primary language of article text, either sl or en -->
  <xsl:variable name="primaryLang"
                select="/h:html/h:body/h:sidebar[1]/h:p/h:span[@class='primary-language']"/>
  <xsl:variable name="primaryLangClass" select="fn:concat('lang-', $primaryLang)"/>

  <xsl:template match="/h:html">
    <xsl:apply-templates select="h:body"/>
  </xsl:template>
  <xsl:template match="h:body">
    <xsl:if test="fn:empty($primaryLang)">
      <xsl:message>Error: language not found at /html/body/sidebar[1]/p/span[@class='primary-language']</xsl:message>
    </xsl:if>
    <article dtd-version="1.1">
      <xsl:attribute name="xml:lang" select="$primaryLang"/>
      <xsl:call-template name="article-type"/>
      <front>
        <xsl:call-template name="journal-meta"/>
        <xsl:call-template name="article-meta"/>
      </front>
      <xsl:call-template name="body"/>
      <back>
        <xsl:call-template name="ack"/>
        <!-- endmatter tables or figures not referenced in the text -->
        <xsl:call-template name="orphan-wrappers"/>
        <xsl:call-template name="ref-list"/>
      </back>
    </article>
  </xsl:template>
  
  <xsl:template name="article-type">
    <xsl:variable name="articleTypeEn" select="h:sidebar[@class='hidden-meta-wrapper']//h:span[@class='article-type-en']"/>
    <xsl:attribute name="article-type">
      <xsl:choose>
        <xsl:when test="$articleTypeEn='Editorial'">editorial</xsl:when>
        <xsl:when test="$articleTypeEn='Original scientific article'">research-article</xsl:when>
        <xsl:when test="$articleTypeEn='Review article'">review-article</xsl:when>
        <xsl:when test="$articleTypeEn='Short scientific article'">research-article</xsl:when>
        <xsl:when test="$articleTypeEn='Professional article'">discussion</xsl:when>
        <xsl:otherwise>other</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="journal-meta">
    <!-- context is h:body -->
    <journal-meta>
      <journal-id journal-id-type="publisher-id">Zdrav Vestn</journal-id>
      <journal-id journal-id-type="nlm-ta">Zdrav Vestn</journal-id>
      <journal-id journal-id-type="doi">Zdrav Vestn</journal-id>
      <journal-title-group>
        <xsl:choose>
          <xsl:when test="$primaryLang='en'">
            <journal-title>Slovenian Medical Journal</journal-title>
            <trans-title-group xml:lang="sl">
              <trans-title>Zdravniški vestnik</trans-title>
            </trans-title-group>
          </xsl:when>
          <xsl:otherwise>
            <journal-title>Zdravniški vestnik</journal-title>
            <trans-title-group xml:lang="en">
              <trans-title>Slovenian Medical Journal</trans-title>
            </trans-title-group>
          </xsl:otherwise>
        </xsl:choose>
        <abbrev-journal-title>Zdrav Vestn</abbrev-journal-title>
      </journal-title-group>
      <!-- deprecated pub-type is required by PMC style checker as of 2018-09. -->
      <issn publication-format="ppub" pub-type="ppub">1318-0347</issn>
      <issn publication-format="epub" pub-type="epub">1581-0224</issn>
      <issn-l>0350-0063</issn-l>
      <publisher>
        <publisher-name xml:lang="sl">Slovensko zdravniško društvo</publisher-name>
        <publisher-name xml:lang="en">Slovenian Medical Association</publisher-name>
        <publisher-loc xml:lang="sl">Ljubljana, Slovenia</publisher-loc>
      </publisher>
    </journal-meta>
  </xsl:template>

  <xsl:template name="article-meta">
    <!-- context is h:body -->
    <article-meta>
      <xsl:call-template name="article-id"/>
      <xsl:call-template name="article-categories"/>
      <xsl:call-template name="title-group"/>
      <xsl:call-template name="contrib-group"/>
      <xsl:call-template name="aff-alternatives"/>
      <xsl:call-template name="author-notes"/>
      <xsl:call-template name="pub-date"/>
      <xsl:call-template name="volume-issue-pages"/>
      <xsl:call-template name="history"/>
      <xsl:call-template name="permissions"/>
      <xsl:call-template name="abstract"/>
      <xsl:call-template name="kwd-group"/>
      <xsl:if test="$reflistDoc/article/front/article-meta/custom-meta-group">
        <xsl:copy-of select="$reflistDoc/article/front/article-meta/custom-meta-group"/>
      </xsl:if>
    </article-meta>
  </xsl:template>

  <xsl:template name="article-id">
    <!-- context is h:body -->
    <xsl:variable name="doi" select="fn:substring-after(.//h:p[@class='doi'], 'DOI: ')"/>
    <xsl:variable name="doiPub" select="fn:substring-after($doi, '/')"/>
    <xsl:variable name="doiPubId" select="fn:substring-after($doiPub, '.')"/>
    <article-id pub-id-type="doi"><xsl:value-of select="$doi"/></article-id>
    <article-id pub-id-type="publisher-id"><xsl:value-of select="$doiPubId"/></article-id>
  </xsl:template>

  <xsl:template name="article-categories">
    <!-- context is h:body -->
    <xsl:variable name="sidebar1" select="h:sidebar[1]"/>
    <xsl:variable name="discipline-en" select="$sidebar1//h:span[@class='discipline-en']"/>
    <xsl:variable name="discipline-sl" select="$sidebar1//h:span[@class='discipline-sl']"/>
    <xsl:variable name="discipline-primaryLang" select="$sidebar1//h:span[@class=fn:concat('discipline-', $primaryLang)]"/>
    <xsl:variable name="article-type-en" select="$sidebar1//h:span[@class='article-type-en']"/>
    <xsl:variable name="article-type-sl" select="$sidebar1//h:span[@class='article-type-sl']"/>
    <article-categories>
      <subj-group subj-group-type="discipline" xml:lang="en">
        <subject>Medicine and health sciences</subject>
        <subj-group>
          <subject><xsl:value-of select="$discipline-en"/></subject>
        </subj-group>
      </subj-group>
      <xsl:if test="fn:exists($discipline-sl)">
        <subj-group subj-group-type="discipline" xml:lang="sl">
          <subject>Medicina/Zdravstvo</subject>
          <subj-group>
            <subject><xsl:value-of select="$discipline-sl"/></subject>
          </subj-group>
        </subj-group>
      </xsl:if>
      <subj-group subj-group-type="article-type" xml:lang="en">
        <subject><xsl:value-of select="$article-type-en"/></subject>
      </subj-group>
      <xsl:if test="fn:exists($article-type-sl)">
        <subj-group subj-group-type="article-type" xml:lang="sl">
          <subject><xsl:value-of select="$article-type-sl"/></subject>
        </subj-group>
      </xsl:if>
      <subj-group subj-group-type="heading"><!--exactly 1 heading group as required by PMC-->
        <xsl:attribute name="xml:lang" select="$primaryLang"/>
        <subject><xsl:value-of select="$discipline-primaryLang"/></subject>
      </subj-group>
    </article-categories>
  </xsl:template>

  <xsl:template name="title-group">
    <!-- context is h:body -->
    <xsl:variable name="sidebar1" select="h:sidebar[1]"/>
    <xsl:variable name="running-head" select="$sidebar1//h:span[@class='running-header']"/>
    <xsl:variable name="origTitle" select="h:article/h:h1[fn:tokenize(@class)='title' and 
                                                          fn:tokenize(@class)=$primaryLangClass]"/>
    <title-group>
      <article-title>
        <xsl:attribute name="xml:lang" select="fn:lower-case($primaryLang)"/>
        <xsl:value-of select="$origTitle"/>
      </article-title>
      <!-- assumes translated title(s) is/are after the original title -->
      <xsl:for-each select="$origTitle/following-sibling::h:h1[fn:tokenize(@class)='title']">
        <xsl:variable name="altLang" select="fn:substring-after(@class, 'lang-')"/>
        <trans-title-group>
          <trans-title>
            <xsl:attribute name="xml:lang" select="fn:lower-case($altLang)"/>
            <xsl:value-of select="."/>
          </trans-title>
        </trans-title-group>
      </xsl:for-each>
      <alt-title alt-title-type="running-head" xml:lang="{$primaryLang}">
        <xsl:value-of select="$running-head"/>
      </alt-title>
    </title-group>

  </xsl:template>

  <!--
  Parse an author paragraph containing a comma-separated list of authors in the following format.
  <span class="given-name">J. G.</span> <span "surname">van der Hayden</span>
  
  The given-name is explicitly spanned at the beginning of the name.
  The surname is explicitly spanned at the end of the name.

  (To compensate for InDesign bugs, abutting tags with the same name and class are merged.)

  Future work: default surname to last name. Surname-first names. Mononymous names. Name suffixes, name prefixes.
  -->
  <xsl:template name="contrib-group">
    <!-- context is h:body -->
    <xsl:variable name="authorParagraph" select="h:article/h:p[@class='author']"/>
    <xsl:variable name="authorParagraphMerged" as="node()">
      <p>
        <xsl:call-template name="mergeAbuttingElements">
          <xsl:with-param name="seq" select="$authorParagraph/node()"/>
        </xsl:call-template>
      </p>
    </xsl:variable>                  
    <xsl:variable name="partNameSpans" select="$authorParagraphMerged/node()[self::h:span]"/>
    <xsl:variable name="fullNameStrings" select="fn:tokenize(fn:normalize-space($authorParagraph), '\s*,(\d+(,\d+)*)?\s*')"/>
    <xsl:variable name="correspondence" select="h:sidebar/h:p[@class='correspondence']"/>
    <contrib-group>
      <xsl:call-template name="contrib-loop">
        <xsl:with-param name="nodeSeq" select="$authorParagraphMerged/node()"/>
        <xsl:with-param name="fullNameStrings" select="$fullNameStrings"/>
        <xsl:with-param name="partNameSpans" select="$partNameSpans"/>
        <xsl:with-param name="correspondence" select="$correspondence"/>
      </xsl:call-template>
    </contrib-group>
  </xsl:template>
  <xsl:template name="contrib-loop">
    <xsl:param name="nodeSeq"/>
    <xsl:param name="fullNameStrings"/>
    <xsl:param name="partNameSpans"/>
    <xsl:param name="correspondence"/>
    <xsl:if test="fn:exists($fullNameStrings)">
      <xsl:variable name="fullNameString" select="fn:replace($fullNameStrings[1], '\d', '')"/>
      <xsl:variable name="span1" select="$partNameSpans[1]"/>
      <xsl:variable name="span2" select="$partNameSpans[2]"/>
      <xsl:variable name="span1String" select="fn:normalize-space($span1)"/>
      <xsl:variable name="span2String" select="fn:normalize-space($span2)"/>
      <xsl:choose>  
        <!-- Full name matches next two name spans -->
        <xsl:when test="fn:starts-with($fullNameString, $span1String) and
                        fn:ends-with($fullNameString, $span2String)">
          <xsl:choose>
            <xsl:when test="fn:matches($span1/@class, 'given-name[s]?') and 
                            fn:matches($span2/@class, 'surname[s]?')">
              <!-- sup tag must be 1 or 2 nodes after span2 -->
              <xsl:variable name="span2Index" select="1+fn:count($span2/preceding-sibling::node())"/>
              <xsl:variable name="sup" select="$nodeSeq[$span2Index lt fn:position() and 
                                                        fn:position() le $span2Index + 2 and 
                                                        fn:name()='sup']"/>
              <xsl:call-template name="contrib">
                <xsl:with-param name="surname" select="$span2String"/>
                <xsl:with-param name="given-name" select="$span1String"/>
                <xsl:with-param name="sup" select="$sup"/><!-- affiliation superscript -->
                <xsl:with-param name="correspondence" select="$correspondence"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>Error: author name span classes are not "given-name" and "surname": "</xsl:text>
                <xsl:value-of select="$span1/@class"/>
                <xsl:text>", "</xsl:text>
                <xsl:value-of select="$span2/@class"/>
                <xsl:text>".</xsl:text>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="contrib-loop">
            <xsl:with-param name="nodeSeq" select="$nodeSeq"/>
            <xsl:with-param name="fullNameStrings" select="fn:tail($fullNameStrings)"/>
            <xsl:with-param name="partNameSpans" select="fn:tail(fn:tail($partNameSpans))"/>
            <xsl:with-param name="correspondence" select="$correspondence"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Error: fullname did not match next span or spans: "</xsl:text>
            <xsl:value-of select="$fullNameString"/>
            <xsl:text>", "</xsl:text>
            <xsl:value-of select="$span1String"/>
            <xsl:text>", "</xsl:text>
            <xsl:value-of select="$span2String"/>
            <xsl:text>".</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <xsl:template name="contrib">
    <xsl:param name="given-name"/>
    <xsl:param name="surname"/>
    <xsl:param name="sup"/> <!-- affiliation superscript -->
    <xsl:param name="correspondence"/>
    <!-- context is full name -->
    <xsl:variable name="affIndexOr1">
      <xsl:choose>
        <xsl:when test="$sup"><xsl:value-of select="$sup"/></xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <contrib contrib-type="author" xlink:type="simple">
      <name name-style="western">
        <xsl:if test="fn:exists($surname)">
          <surname><xsl:value-of select="$surname"/></surname>
        </xsl:if>
        <xsl:if test="fn:exists($given-name)">
          <given-names><xsl:value-of select="$given-name"/></given-names>
        </xsl:if>
      </name>
      <xsl:for-each select="fn:tokenize($affIndexOr1, ',')">
        <xref ref-type="aff">
          <xsl:attribute name="rid">
            <xsl:value-of select="fn:concat('aff', .)"/>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </xref>
      </xsl:for-each>
      <xsl:if test="(fn:contains($correspondence, $surname) or fn:empty($surname)) and
                    (fn:contains($correspondence, $given-name) or fn:empty($given-name))">
        <xref ref-type="corresp" rid="corr"/>
      </xsl:if>
    </contrib>
  </xsl:template>
  <!-- 
  Given a sequences of elements and separating text, create a new sequence that
  merges abutting elements with same tag and class.  "Abutting" means there is
  no separating text node between the elements.
  Sample1: <span class="a">A</span><span class="a">B</span> <span class="a">C</span>
  Result1: <span class="a">AB</span> <span class="a">C</span>
  C is not included in the first result span because there is text space before its span.
  (Reason is to compensate for InDesign problems that prevent a single merged tag.)
  -->
  <xsl:template name="mergeAbuttingElements" as="node()*">
    <xsl:param name="seq" as="node()*"/> <!-- sequence of elements and text -->
    <xsl:choose>
      <xsl:when test="fn:empty($seq)"></xsl:when>
      <xsl:when test="fn:empty(fn:tail($seq))"><xsl:copy-of select="fn:head($seq)"/></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="e1" select="$seq[1]" as="node()"/>
        <xsl:variable name="e2" select="$seq[2]" as="node()"/>
        <xsl:choose>
          <xsl:when test="$e1/fn:name() != '' and
                          $e1/fn:name() = $e2/fn:name() and
                          $e1/@class = $e2/@class">
            <xsl:call-template name="mergeAbuttingElements">
              <xsl:with-param name="seq" as="node()*">
                <xsl:element namespace="{$e1/fn:namespace-uri()}" name="{$e1/fn:name()}">
                  <xsl:attribute name="class" select="$e1/@class"/>
                  <xsl:value-of select="fn:concat($e1, $e2)"/>
                </xsl:element>
                <xsl:for-each select="fn:tail(fn:tail($seq))">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$e1"/>
            <xsl:call-template name="mergeAbuttingElements">
              <xsl:with-param name="seq" select="fn:tail($seq)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="aff-alternatives">
    <!-- context is h:body -->
    <xsl:for-each select="h:sidebar/h:p[fn:tokenize(@class)='aff' and
                                        fn:tokenize(@class)=$primaryLangClass]">
      <xsl:variable name="affIndex" select="1+fn:count(preceding-sibling::h:p[fn:tokenize(@class)='aff' and fn:tokenize(@class)=$primaryLangClass])"/>
      <xsl:variable name="id" select="fn:concat('aff', $affIndex)"/>
      <xsl:variable name="refAff" select="h:span[@class='ref-aff']"/>
      <xsl:variable name="altAffs"
                    select="following-sibling::h:p[fn:tokenize(@class) = 'aff' and
                                                   (fn:empty($refAff) or
                                                    $refAff = h:span[@class='ref-aff'])]"/>
      <xsl:variable name="label">
        <xsl:choose>
          <xsl:when test="fn:normalize-space($refAff) != ''">
            <xsl:value-of select="$refAff"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$affIndex"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="fn:exists($altAffs)">
          <aff-alternatives>
            <xsl:attribute name="id" select="$id"/>
            <aff>
              <xsl:attribute name="xml:lang" select="fn:lower-case($primaryLang)"/>
              <xsl:call-template name="aff-label-institution">
                <xsl:with-param name="label" select="$label"/>
                <xsl:with-param name="text" select="."/>
              </xsl:call-template>
            </aff>
            <xsl:for-each select="$altAffs">
              <aff>
                <xsl:attribute name="xml:lang" select="fn:lower-case(fn:substring-after(./@class, 'aff lang-'))"/>
                <xsl:call-template name="aff-label-institution">
                  <xsl:with-param name="label" select="$label"/>
                  <xsl:with-param name="text" select="."/>
                </xsl:call-template>
              </aff>
            </xsl:for-each>
          </aff-alternatives>
        </xsl:when>
        <xsl:otherwise>
          <!-- Similar to first aff above but without alt-alternatives wrapper.
               (PMC style checker forbids 1 aff in aff-alternatives, though JATS schema allows it.) -->
          <aff>
            <xsl:attribute name="id" select="$id"/>
            <xsl:attribute name="xml:lang" select="fn:lower-case($primaryLang)"/>
            <xsl:call-template name="aff-label-institution">
              <xsl:with-param name="label" select="$label"/>
              <xsl:with-param name="text" select="."/>
            </xsl:call-template>
          </aff>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="aff-label-institution">
    <xsl:param name="label"/>
    <xsl:param name="text"/>
    <label><xsl:value-of select="$label"/></label>
    <institution>
      <xsl:choose>
        <xsl:when test="fn:starts-with($text, $label)">
          <xsl:value-of select="fn:normalize-space(fn:substring-after($text, $label))"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
      </xsl:choose>
    </institution>
  </xsl:template>

  <xsl:template name="author-notes">
    <!-- context is h:body -->
    <xsl:variable name="conflictStmt-sl" select="h:sidebar[@class='meta-wrapper']/p[@class='conflict-of-interest' and @lang='sl']"/>
    <xsl:variable name="conflictStmt-en" select="h:sidebar[@class='meta-wrapper']/p[@class='conflict-of-interest' and @lang='en']"/>
    <xsl:variable name="correspondence" select="h:sidebar/h:p[@class='correspondence']"/>
    <author-notes>
      <xsl:choose>
        <xsl:when test="$conflictStmt-sl or $conflictStmt-en">
          <xsl:if test="$conflictStmt-sl">
            <fn fn-type="conflict" xml:lang="sl">
              <p><xsl:value-of select="$conflictStmt-sl"/></p>
            </fn>
          </xsl:if>
          <xsl:if test="$conflictStmt-en">
            <fn fn-type="conflict" xml:lang="en">
              <p><xsl:value-of select="$conflictStmt-en"/></p>
            </fn>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <fn fn-type="conflict" xml:lang="en">
            <p>The authors have declared that no competing interests exist.</p>
          </fn>
          <fn fn-type="conflict" xml:lang="sl">
            <p>Avtorji so izjavili, da ne obstajajo nobeni konkurenčni interesi.</p>
          </fn>
        </xsl:otherwise>
      </xsl:choose>
      <corresp id="corr">
        <xsl:value-of select="fn:substring-before($correspondence, ',')"/>
        <xsl:text>, e-mail: </xsl:text>
        <email xlink:type="simple">
          <xsl:value-of select="substring-after($correspondence, ' e: ')"/>
        </email>
      </corresp>
    </author-notes>
  </xsl:template>

  <xsl:template name="pub-date">
    <!-- context is h:body -->
    <xsl:variable name="ref-en" select="h:sidebar[1]/h:p/h:span[@class='reference-en']"/>
    <xsl:variable name="refParts" select="fn:tokenize($ref-en, ' [|] ')"/>
    <xsl:variable name="date" select="fn:head(fn:tail($refParts))"/>
    <xsl:variable name="enDash">&#x2013;</xsl:variable>
    <xsl:variable name="dateParts" select="fn:replace($date, $enDash, ' ') => fn:normalize-space() => fn:tokenize()"/>
    <xsl:variable name="revDateParts" select="fn:reverse($dateParts)"/>
    <xsl:variable name="year" select="fn:head($revDateParts)"/>
    <xsl:variable name="endMonth">
      <xsl:call-template name="monthNumberFromEnglishName">
        <xsl:with-param name="englishMonth" select="fn:head(fn:tail($revDateParts))"/>
      </xsl:call-template>
    </xsl:variable>
    <pub-date pub-type="ppub">
      <month><xsl:value-of select="$endMonth"/></month>
      <year><xsl:value-of select="$year"/></year>
    </pub-date>
    <pub-date pub-type="epub">
      <month><xsl:value-of select="$endMonth"/></month>
      <year><xsl:value-of select="$year"/></year>
    </pub-date>
  </xsl:template>
  <xsl:template name="monthNumberFromEnglishName">
    <xsl:param name="englishMonth"/>
    <xsl:choose>
      <xsl:when test="$englishMonth='January'">1</xsl:when>
      <xsl:when test="$englishMonth='February'">2</xsl:when>
      <xsl:when test="$englishMonth='March'">3</xsl:when>
      <xsl:when test="$englishMonth='April'">4</xsl:when>
      <xsl:when test="$englishMonth='May'">5</xsl:when>
      <xsl:when test="$englishMonth='June'">6</xsl:when>
      <xsl:when test="$englishMonth='July'">7</xsl:when>
      <xsl:when test="$englishMonth='August'">8</xsl:when>
      <xsl:when test="$englishMonth='September'">9</xsl:when>
      <xsl:when test="$englishMonth='October'">10</xsl:when>
      <xsl:when test="$englishMonth='November'">11</xsl:when>
      <xsl:when test="$englishMonth='December'">12</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$englishMonth"/>
        <xsl:comment>Not a capitalized English month name</xsl:comment>
      </xsl:otherwise>
    </xsl:choose>      
  </xsl:template>

  <xsl:template name="volume-issue-pages">
    <!-- context is h:body -->
    <xsl:variable name="citeAs" select="h:article/h:p[@class='cite-as']"/>
    <xsl:variable name="vip" select="fn:substring-after($citeAs, ';')"/>
    <xsl:variable name="volume" select="fn:substring-before($vip, '(')"/>
    <xsl:variable name="issue" select="fn:substring-before(fn:substring-after($vip, '('), ')')"/>
    <xsl:variable name="pageRange" select="fn:substring-before(fn:substring-after($vip, '):'), '.')"/>
    <xsl:variable name="enDash">&#x2013;</xsl:variable>
    <xsl:variable name="pageSeq" select="fn:tokenize($pageRange, $enDash)"/>
    <xsl:variable name="beginPage" select="fn:head($pageSeq)"/>
    <xsl:variable name="endPage" select="fn:head(fn:reverse($pageSeq))"/>
    <volume><xsl:value-of select="$volume"/></volume>
    <issue><xsl:value-of select="$issue"/></issue>
    <fpage><xsl:value-of select="$beginPage"/></fpage>
    <lpage><xsl:value-of select="$endPage"/></lpage>
  </xsl:template>

  <xsl:template name="history">
    <!-- context is h:body -->
    <xsl:variable name="history" select="h:sidebar[@class='meta-wrapper' and position()=2]/h:p[@class='history']"/>
    <!-- History labels do not depend on primary language.  
         An original English article may have Slovenian labels (as in the printed Slovenian journal).
         However, a translated English article has English labels (as it appears online). -->
    <xsl:variable name="receivedLabel" select="if (fn:starts-with($history, 'Prispelo: ')) then 'Prispelo: ' else 'Received: '"/>
    <xsl:variable name="acceptedLabel" select="if (fn:contains($history, ' Sprejeto: ')) then ' Sprejeto: ' else ' Accepted: '"/>
    <xsl:variable name="receivedDate" select="fn:substring-before(fn:substring-after($history, $receivedLabel), $acceptedLabel)"/>
    <xsl:variable name="receivedParts" select="fn:tokenize($receivedDate, '. ')"/>
    <xsl:variable name="receivedDay" select="fn:head($receivedParts)"/>
    <xsl:variable name="receivedMonth" select="fn:head(fn:tail($receivedParts))"/>
    <xsl:variable name="receivedYear" select="fn:head(fn:tail(fn:tail($receivedParts)))"/>

    <xsl:variable name="acceptedDate" select="fn:substring-after($history, $acceptedLabel)"/>
    <xsl:variable name="acceptedParts" select="fn:tokenize($acceptedDate, '. ')"/>
    <xsl:variable name="acceptedDay" select="fn:head($acceptedParts)"/>
    <xsl:variable name="acceptedMonth" select="fn:head(fn:tail($acceptedParts))"/>
    <xsl:variable name="acceptedYear" select="fn:head(fn:tail(fn:tail($acceptedParts)))"/>
    <history>
      <date date-type="received">
        <day><xsl:value-of select="$receivedDay"/></day>
        <month><xsl:value-of select="$receivedMonth"/></month>
        <year><xsl:value-of select="$receivedYear"/></year>
      </date>
      <date date-type="accepted">
        <day><xsl:value-of select="$acceptedDay"/></day>
        <month><xsl:value-of select="$acceptedMonth"/></month>
        <year><xsl:value-of select="$acceptedYear"/></year>
      </date>
    </history>
  </xsl:template>

  <xsl:template name="permissions">
    <!-- context is h:body -->
    <xsl:variable name="citeAs" select="h:article/h:p[@class='cite-as']!fn:normalize-space(.)"/>
    <xsl:variable name="year" select="fn:substring-before(fn:substring-after($citeAs, 'Zdrav Vestn. '), ';')"/>

    <permissions>
      <copyright-statement xml:lang="en">
        <xsl:text>Copyright © </xsl:text>
        <xsl:value-of select="$year"/>
        <xsl:text>, Slovenian Medical Association (SZD)</xsl:text>
      </copyright-statement>
      <copyright-statement xml:lang="sl">
        <xsl:text>© </xsl:text>
        <xsl:value-of select="$year"/>
        <xsl:text>, Slovensko zdravniško društvo (SZD)</xsl:text>
      </copyright-statement>
      <copyright-year><xsl:value-of select="$year"/></copyright-year>
      <copyright-holder xml:lang="en">Slovenian Medical Association (SZD)</copyright-holder>
      <copyright-holder xml:lang="sl">Slovensko zdravniško društvo (SZD)</copyright-holder>
      <license xlink:href="https://creativecommons.org/licenses/by-nc/4.0/"
               xlink:type="simple" xml:lang="en">
        <license-p>This is an open access article distributed under the terms of the
          <ext-link ext-link-type="uri"
                    xlink:href="https://creativecommons.org/licenses/by-nc/4.0/"
                    xlink:type="simple">Creative Commons Attribution-NonCommercial
            License</ext-link>, which permits unrestricted use, distribution, and
          reproduction in any medium, provided the original author and source are
          credited and only for non-commercial purposes. </license-p>
      </license>
      <license xlink:href="https://creativecommons.org/licenses/by-nc/4.0/"
               xlink:type="simple" xml:lang="sl">
        <license-p>To je članek z odprtim dostopom, ki ga lahko uporabite pod pogoji iz
          <ext-link ext-link-type="uri"
                    xlink:href="https://creativecommons.org/licenses/by-nc/4.0/"
                    xlink:type="simple">Creative Commons Priznanje avtorstva-Nekomercialno
            licence</ext-link>. ki dovoljuje distribucijo, predelavo ali
          prilagoditev, ter gradijo na njem, v nekomercialne namene, z navedbo avtorja
          in izvirnega dela.</license-p>
      </license>
    </permissions>
  </xsl:template>

  <!--
  Output abstract and translations.  Assumes the original abstract is
  first in the html.  The abstract extends from the <h1 class="abs">
  containing the heading 'Abstract' in the body language, through all
  the <p class="abs"> paragraphs up to but excluding the
  next <h1 class="abs">.
  -->
  <xsl:template name="abstract">
    <!-- context is h:body -->
    <xsl:for-each select="h:article/h:h1[fn:tokenize(@class)='abs' and fn:empty(preceding-sibling::h:h1[fn:tokenize(@class)='abs'])]">
      <abstract>
        <xsl:call-template name="abstract-lang"/>
        <title><xsl:value-of select="."/></title>
        <xsl:apply-templates select="following-sibling::h:p[fn:tokenize(@class)='abs' and 1=fn:count(preceding-sibling::h:h1[fn:tokenize(@class)='abs'])]"/>
      </abstract>
    </xsl:for-each>
    <xsl:for-each select="h:article/h:h1[fn:tokenize(@class)='abs' and fn:exists(preceding-sibling::h:h1[fn:tokenize(@class)='abs'])]">
      <xsl:variable name="absIndex" select="1+fn:count(preceding-sibling::h:h1[fn:tokenize(@class)='abs'])"/>
      <trans-abstract>
        <xsl:call-template name="abstract-lang"/>
        <title><xsl:value-of select="."/></title>
        <xsl:apply-templates select="following-sibling::h:p[fn:tokenize(@class)='abs' and $absIndex=fn:count(preceding-sibling::h:h1[fn:tokenize(@class)='abs'])]"/>
      </trans-abstract>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="abstract-lang">
    <!-- context is <h:h1 class="abs"> -->
    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="@lang"><xsl:value-of select="fn:lower-case(@lang)"/></xsl:when>
        <xsl:when test="fn:string(.)='Izvle&#x10D;ek'">sl</xsl:when>
        <xsl:when test="fn:string(.)='Abstract'">en</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$lang">
      <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="kwd-group">
    <!-- context is h:body -->
    <xsl:for-each select="h:sidebar[@class='meta-wrapper' and position()=2]/h:p[fn:tokenize(@class) = 'keywords']">
      <xsl:variable name="lang" select="fn:substring-after(@class, 'lang-')"/>
      <kwd-group>
        <xsl:attribute name="xml:lang" select="fn:lower-case($lang)"/>
        <xsl:for-each select="fn:tokenize(., '; ')">
          <kwd><xsl:value-of select="."/></kwd>
        </xsl:for-each>
      </kwd-group>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="body">
    <!-- context is h:body -->
    <body>
      <!-- for each h1 with no class -->
      <xsl:for-each select="h:article/h:h1[fn:empty(@class)]">
        <xsl:call-template name="sec"/>
      </xsl:for-each>
    </body>
  </xsl:template>

  <!--
      Emit a tree of JATS sec sections starting at an html heading and include the following
      paragraphs and subheadings with higher level.
      Input headings h1,h2,h3, etc, and paragraphs p, must be siblings (same parent element).
      Heading levels in use must not be skipped. (Bad: h1 followed by h3 followed by h2.  
      Ok: h1 followed by h3 if h2 is never used.)
    -->
  <xsl:template name="sec">
    <!-- Context is an html heading h element such as h:h1, h:h2, .. etc. -->
    <!-- The expression fn:replace(local-name(), '^[Hh](\d)$', '$1') 
         matches the local tag name to (H or h) followed by a digit, 
         and extracts the digit, the '2' in 'h2' -->
    <xsl:variable name="level" select="fn:number(fn:replace(local-name(), '^[Hh](\d)$', '$1'))"/>
    <xsl:variable
       name="nextHSameOrOuter"
       select="(following-sibling::*[fn:number(fn:replace(local-name(), '^[Hh](\d)$', '$1')) le $level])[1]"/>
    <xsl:variable
       name="nextInner"
       select="(following-sibling::*[fn:number(fn:replace(local-name(), '^[Hh](\d)$', '$1')) gt $level
                                    and (. &lt;&lt; $nextHSameOrOuter or not(fn:exists($nextHSameOrOuter)))])[1]"/>
    <xsl:variable
       name="nextInnerLevel" select="fn:number(fn:replace(local-name($nextInner), '^[Hh](\d)$', '$1'))"/>

    <xsl:if test="$nextInnerLevel gt $level + 1">
      <xsl:message>Warning: skipped heading level - <xsl:value-of select="fn:concat(./name(), ' [', .,']')"/> is followed by <xsl:value-of select="fn:concat($nextInner/name(), ' [', $nextInner, ']')"/></xsl:message>
    </xsl:if>
    <xsl:variable
       name="hInners"
       select="following-sibling::*[fn:number(fn:replace(local-name(), '^[Hh](\d)$', '$1')) = $nextInnerLevel
                                    and (. &lt;&lt; $nextHSameOrOuter or not(fn:exists($nextHSameOrOuter)))]"/>
    <sec>
      <xsl:choose>
        <xsl:when test="fn:matches(., '\d+([.]\d+)*[ ].*')">
          <!-- Title starts with section number, so use parts in id and secType -->
          <xsl:variable name="secNumber" select="fn:substring-before(., ' ')"/>
          <xsl:variable name="title" select="fn:substring-after(., ' ')"/>
          <xsl:attribute name="id" select="fn:concat('s', fn:translate($secNumber, ' :', '__'))"/>
          <xsl:attribute name="sec-type" select="$title"/>
          <label><xsl:value-of select="$secNumber"/></label>
          <title><xsl:value-of select="$title"/></title>
        </xsl:when>
        <xsl:otherwise><!-- No section number, so use whole title in id and sec-type -->
          <xsl:attribute name="id" select="fn:concat('s', fn:translate(., ' :', '__'))"/>
          <xsl:attribute name="sec-type" select="."/>
          <title><xsl:value-of select="."/></title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="fn:exists($hInners[1])">
          <xsl:apply-templates select="following-sibling::*[. &lt;&lt; $hInners[1]]"/>
          <xsl:for-each select="$hInners">
            <xsl:call-template name="sec"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="fn:exists($nextHSameOrOuter)">
          <xsl:apply-templates select="following-sibling::*[. &lt;&lt; $nextHSameOrOuter]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="following-sibling::*"/>
        </xsl:otherwise>
      </xsl:choose>              
    </sec>
  </xsl:template>

  <!--
      Translate series of references:
      * single: from <span class="xref">(1)</span> 
        to (<xref ref-type="bibr" rid="b1">1</xref>)
      * range: from <span class="xref">(1-3)</span>
        to (<xref ref-type="bibr" rid="b1">1</xref>-<xref ref-type="bibr" rid="b3">3</xref>)
      * series: from <span class="xref">(1-3,5)</span>
        to (<xref ref-type="bibr" rid="b1">1</xref>-<xref ref-type="bibr" rid="b3">3</xref>,<xref ref-type="bibr" rid="b3">5</xref>)
    -->
  <xsl:template match="h:span[@class='xref']">
    <!-- Remove parentheses around series -->
    <xsl:variable name="series" select="fn:translate(., '( )', '')"/>
    <!-- Emit preceding parentheses -->
    <xsl:value-of select="fn:substring-before(., $series)"/>
    <!-- For each numeral or numeric-range in a comma-separated series -->
    <xsl:for-each select="fn:tokenize($series, '\s*,\s*')">
      <xsl:if test="position() gt 1">,</xsl:if>
      <xsl:variable name="numeralOrRange" select="fn:string(.)"/>
      <xsl:choose>
        <xsl:when test="fn:number($numeralOrRange) gt 0">
          <xref ref-type="bibr">
            <xsl:attribute name="rid" select="fn:concat('b', $numeralOrRange)"/>
            <xsl:value-of select="$numeralOrRange"/>
          </xref>
        </xsl:when>
        <xsl:otherwise>
          <!-- Extract first numeral if there are a series and/or range. -->
          <xsl:variable name="beginNumeral" select="fn:replace($numeralOrRange, '^(\d+)\D.*', '$1')"/>
          <!-- Extract last numeral if there are a series and/or range. -->
          <xsl:variable name="endNumeral" select="fn:replace($numeralOrRange, '.*\D(\d+)$', '$1')"/>
          <xsl:choose>
            <xsl:when test="fn:number($beginNumeral) gt 0 and fn:number($endNumeral) gt 0">
              <xref ref-type="bibr">
                <xsl:attribute name="rid" select="fn:concat('b', $beginNumeral)"/>
                <xsl:value-of select="$beginNumeral"/>
              </xref>
              <xsl:value-of select="fn:substring-before(fn:substring-after(., $beginNumeral), $endNumeral)"/>
              <xref ref-type="bibr">
                <xsl:attribute name="rid" select="fn:concat('b', $endNumeral)"/>
                <xsl:value-of select="$endNumeral"/>
              </xref>
            </xsl:when>
            <xsl:when test="fn:number($beginNumeral) gt 0">
              <xref ref-type="bibr">
                <xsl:attribute name="rid" select="fn:concat('b', $beginNumeral)"/>
                <xsl:value-of select="$beginNumeral"/>
              </xref>
            </xsl:when>
            <xsl:when test="fn:number($endNumeral) gt 0">
              <xref ref-type="bibr">
                <xsl:attribute name="rid" select="fn:concat('b', $endNumeral)"/>
                <xsl:value-of select="$endNumeral"/>
              </xref>
            </xsl:when>
            <xsl:otherwise> <!-- did not begin or end with a numeral, show but no xref -->
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <!-- Emit following parentheses -->
    <xsl:value-of select="fn:substring-after(., $series)"/>
  </xsl:template>

  <!--
     Emit a reference to a table.  If this is the first reference to the table,
     and the html table is after the article element, then also emit the table float.
  -->
  <xsl:template match="h:span[@class='ref-table']">
    <!-- InDesign might divide reference into 2 or 3 contiguous spans like
         <span class="ref-table">Tabel</span><span class="ref-table">a</span><span class="ref-table"> 1</span>
         So run only when matched the first span, and combine the text of them all. -->
    <xsl:if test="not(preceding-sibling::node()[1]/@class='ref-table')">
      <xsl:variable name="span2"
                    select="./following-sibling::node()
                            [position()=1 and self::h:span and @class='ref-table']"/>
      <xsl:variable name="span3"
                    select="$span2/following-sibling::node()
                            [position()=1 and self::h:span and @class='ref-table']"/>
      <xsl:variable name="text"
                    select="fn:normalize-space(fn:concat(., $span2, $span3))"/>
      <xsl:variable name="tableNumber" select="fn:replace($text, '\D', '')"/> <!-- rm nondigits -->
      <xsl:variable name="tableId" select="fn:concat('table', $tableNumber)"/>
      <!-- emit table float only if this is first reference (no previous reference exists) -->
      <xsl:if test="fn:empty(ancestor-or-self::*/preceding-sibling::*/descendant::h:span
                             [@class='ref-table' and 
                              $tableNumber = fn:replace(., '\D', '')])"><!--assumeNumberNotDivided-->
        <!-- emit table if div after article, where table number = digits in bold part of caption -->
        <xsl:apply-templates
           select="ancestor::h:article/following-sibling::h:div
                   [@class = 'table-wrapper' and 
                    $tableNumber = fn:replace(h:p[@class = 'caption']/h:bold, '\D', '')]">
          <xsl:with-param name="position" select="'float'"/>
        </xsl:apply-templates>
      </xsl:if>
      <!-- xref at end so following punctuation stays near -->
      <xref ref-type="table">
        <xsl:attribute name="rid" select="$tableId"/>
        <xsl:value-of select="$text"/>
      </xref>
    </xsl:if>
  </xsl:template>

  <xsl:template match="h:div[@class='table-wrapper']">
    <xsl:param name="position" select="'anchor'"/>
    <xsl:variable name="labelAndCaption" select="h:p[@class='caption'][1]"/>
    <xsl:variable name="labelAndCaptionMerged" as="node()*">
      <xsl:call-template name="mergeAbuttingElements">
        <xsl:with-param name="seq" select="$labelAndCaption/node()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="label" select="fn:head($labelAndCaptionMerged)"/>
    <xsl:variable name="tableNumber" select="fn:replace($label, '\D', '')"/><!-- rm nondigits -->
    <xsl:variable name="tableId" select="fn:concat('table', $tableNumber)"/>
    <xsl:variable name="caption" select="fn:tail($labelAndCaptionMerged)"/>
    <xsl:variable name="table" select="h:table"/>
    <xsl:variable name="legends" select="h:p[@class='legend']"/>
    <table-wrap position="{$position}">
      <xsl:attribute name="id" select="$tableId"/>
      <label><xsl:value-of select="$label"/></label>
      <caption>
        <p><xsl:apply-templates select="$caption"/></p>      
        <xsl:apply-templates select="h:p[@class='caption'][position() gt 1]"/>
      </caption>
      <xsl:apply-templates select="$table"/>
      <xsl:if test="fn:exists($legends)">
        <table-wrap-foot>
          <xsl:apply-templates select="$legends"/>
        </table-wrap-foot>
      </xsl:if>
    </table-wrap>
  </xsl:template>

  <!--
     Emit a reference to a figure.  If this is the first reference to the figure, 
     and the html figure is after the article element, then also emit the fig float.
  -->
  <xsl:template match="h:span[@class='ref-fig']">
    <!-- InDesign might divide reference into 2 or 3 contiguous spans like
         <span class="ref-fig">Slik</span><span class="ref-fig">a</span><span class="ref-fig"> 1</span>
         So run only when matched the first span, and combine the text of them all. -->
    <xsl:if test="not(preceding-sibling::node()[1]/@class='ref-fig')">
      <xsl:variable name="span2"
                    select="./following-sibling::node()
                            [position()=1 and self::h:span and @class='ref-fig']"/>
      <xsl:variable name="span3"
                    select="$span2/following-sibling::node()
                            [position()=1 and self::h:span and @class='ref-fig']"/>
      <!-- Omit span3 if it has uppercase, looks like start of next ref -->
      <xsl:variable name="text" select="fn:normalize-space(fn:concat(., $span2, $span3))"/>
      <xsl:variable name="figureNumber" select="fn:replace($text, '\D', '')"/> <!-- rm nondigits -->
      <xsl:variable name="figureId" select="fn:concat('fig', $figureNumber)"/>
      <!-- emit figure float only if this is first reference (no previous reference exists) -->
      <xsl:if test="fn:empty(ancestor-or-self::*/preceding-sibling::*/descendant::h:span
                             [@class='ref-fig' and 
                              $figureNumber = fn:replace(., '\D', '')])"><!--assumeNumberNotDivided-->
        <!-- div after article where figure number = digits in bold part of caption -->
        <xsl:apply-templates
           select="ancestor::h:article/following-sibling::h:div
                   [@class = 'figure-wrapper' and 
                    $figureNumber = fn:replace(h:p[@class = 'caption']/h:bold, '\D', '')]">
          <xsl:with-param name="position" select="'float'"/>
        </xsl:apply-templates>
      </xsl:if>
      <!-- xref at end so following punctuation stays near -->
      <xref ref-type="fig">
        <xsl:attribute name="rid" select="$figureId"/>
        <xsl:value-of select="$text"/>
      </xref>
    </xsl:if>
  </xsl:template>

  <xsl:template match="h:div[@class='figure-wrapper']">
    <xsl:param name="position" select="'anchor'"/>
    <xsl:variable name="labelAndCaption" select="h:p[@class='caption'][1]"/>
    <xsl:variable name="labelAndCaptionMerged" as="node()*">
      <xsl:call-template name="mergeAbuttingElements">
        <xsl:with-param name="seq" select="$labelAndCaption/node()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="label" select="fn:head($labelAndCaptionMerged)"/>
    <xsl:variable name="figureNumber" select="fn:replace($label, '\D', '')"/> <!-- rm nondigits -->
    <xsl:variable name="figureId" select="fn:concat('fig', $figureNumber)"/>
    <xsl:variable name="caption" select="fn:tail($labelAndCaptionMerged)"/>
    <xsl:variable name="figure" select="p[h:img or @class='pic-placeholder']"/>
    <fig position="{$position}">
      <xsl:attribute name="id" select="$figureId"/>
      <label><xsl:value-of select="$label"/></label>
      <caption>
        <p><xsl:apply-templates select="$caption"/></p>      
        <xsl:apply-templates select="h:p[@class='caption'][position() gt 1]"/>
      </caption>
      <xsl:apply-templates select="h:p[h:img or @class='pic-placeholder' or @class='legend']"/>
    </fig>
  </xsl:template>

  <!-- emit wrapper after article only if it was never referenced (and thus inserted) in article -->
  <xsl:template name="orphan-wrappers">
    <!-- context is h:body -->
    <xsl:for-each select="h:article/following-sibling::h:div[@class='table-wrapper' or @class='figure-wrapper']">
      <xsl:variable name="number"
                    select="fn:replace(h:p[@class='caption']/h:bold, '\D', '')"/><!--rmNonDigits-->
      <xsl:if test="(@class='table-wrapper' and 
                     fn:empty(../h:article//h:span
                              [@class='ref-table' and $number = fn:replace(., '\D', '')]))
                    or
                    (@class='figure-wrapper' and 
                     fn:empty(../h:article//h:span
                              [@class='ref-fig' and $number = fn:replace(., '\D', '')]))">
        <sec>
          <label><xsl:value-of select="h:p[@class='caption']/h:bold"/></label>
          <xsl:apply-templates select="."/>
        </sec>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- omit extra wrapper around table-wrapper or figure-wrapper -->
  <xsl:template match="h:div[fn:count(*)=1 and fn:exists(h:div[@class='table-wrapper' or @class='figure-wrapper'])]">
    <xsl:apply-templates select="h:div[@class='table-wrapper' or @class='figure-wrapper']"/>
  </xsl:template>

  <!-- h1 class="ack" includes any paragraphs up to next h1 or article end -->
  <xsl:template name="ack">
    <!-- context is h:body -->
    <xsl:for-each select="h:article/h:h1[@class='ack']">
      <xsl:variable name="nextH1" select="fn:head(following-sibling::h:h1)"/>
      <ack>
        <xsl:choose>
          <xsl:when test="fn:matches(., '\d+([.]\d+)*[ ].*')">
            <label><xsl:value-of select="fn:substring-before(., ' ')"/></label>
            <title><xsl:value-of select="fn:substring-after(., ' ')"/></title>
          </xsl:when>
          <xsl:otherwise>
            <title><xsl:value-of select="."/></title>
          </xsl:otherwise>
        </xsl:choose>
        <!-- assume no subsections -->
        <xsl:for-each select="following-sibling::*[$nextH1 = fn:head(following-sibling::h:h1) or fn:empty($nextH1)]">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </ack>          
    </xsl:for-each>
  </xsl:template>

  <!-- ref-list is copied as-is from $reflistDoc -->
  <xsl:template name="ref-list">
    <xsl:if test="$reflistDoc/article/back/ref-list">
      <xsl:copy-of select="$reflistDoc/article/back/ref-list"/>
    </xsl:if>
  </xsl:template>

  <!--
      Emit a <list> of <list-items> only if this is the first p of series of <p class="ul">.
      Emit nested <list> for a group of <p class="ul2"> among the <p class="ul">.
    -->
  <xsl:template match="h:p[@class='ul']">
    <xsl:call-template name="list">
      <xsl:with-param name="class1">ul</xsl:with-param>
      <xsl:with-param name="class2">ul2</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="h:p[@class='ul2']"/><!-- nested list handled by outer -->

  <!--
      Emit a <list> of <list-items> only if this is the first p of series of <p class="ol">.
      Emit nested <list> for a group of <p class="ol2"> among the <p class="ol">.
    -->
  <xsl:template match="h:p[@class='ol' or @class='ol-restart']">
    <xsl:call-template name="list">
      <xsl:with-param name="class1">ol</xsl:with-param>
      <xsl:with-param name="class2">ol2</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="h:p[@class='ol2']"/><!-- nested list handled by outer -->

  <xsl:template name="list">
    <xsl:param name="class1"/> <!-- paragraph class for outer list list-item -->
    <xsl:param name="class2"/> <!-- paragraph class for nested list list-item-->
    <xsl:variable name="previousElement" select="preceding-sibling::*[1]"/>
    <xsl:variable name="prevElClass" select="$previousElement/@class"/>
    <xsl:if test="fn:empty($previousElement) or 
                  not($previousElement[self::h:p] and
                      ($prevElClass = $class1 or 
                       $prevElClass = $class2 or
                       (fn:starts-with($prevElClass, $class1) and
                        fn:substring-after($prevElClass,$class1)='-restart')))">
      <xsl:variable name="elementAfterList"
                    select="fn:head(following-sibling::*[not(self::h:p and (@class=$class1 or @class=$class2))])"/>
      <list>
        <xsl:for-each select=". union 
                              following-sibling::h:p
                              [@class=$class1 and 
                               $elementAfterList = 
                               fn:head(following-sibling::*[not(self::h:p and (@class=$class1 or @class=$class2))])]">
          <list-item>
            <xsl:call-template name="list-item-label-and-p"/>
            <xsl:if test="following-sibling::*[1]/self::h:p and 
                          following-sibling::*[1]/@class = $class2">
              <xsl:call-template name="list2">
                <xsl:with-param name="class1" select="$class1"/>
                <xsl:with-param name="class2" select="$class2"/>
                <xsl:with-param name="elementAfterList" select="$elementAfterList"/>
              </xsl:call-template>
            </xsl:if>
          </list-item>
        </xsl:for-each>          
      </list>
    </xsl:if>
  </xsl:template>
  <xsl:template name="list2">
    <!-- context is 'parent' p[@class=$class1] 
         where next sibling p[@class=$class2] exists-->
    <xsl:param name="class1"/>
    <xsl:param name="class2"/>
    <xsl:param name="elementAfterList"/>
    <!-- next item of outer list -->
    <xsl:variable name="nextItem"
                  select="fn:head(following-sibling::h:p[@class=$class1 and
                                                         $elementAfterList = fn:head(following-sibling::*[not(self::h:p and (@class=$class1 or @class=$class2))])])"/>
    <!-- List of adjacent p[@class=$class2].  End cutoff condition varies. -->
    <list>
      <xsl:choose>
        <xsl:when test="fn:exists($nextItem)">
          <xsl:for-each select="following-sibling::h:p[@class=$class2 and $nextItem = fn:head(following-sibling::h:p[@class=$class1])]">
            <xsl:call-template name="list2-item"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="fn:exists($elementAfterList)">
          <xsl:for-each select="following-sibling::h:p[@class=$class2 and $elementAfterList = fn:head(following-sibling::*[not(self::h:p and (@class=$class1 or @class=$class2))])]">
            <xsl:call-template name="list2-item"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="following-sibling::h:p[@class=$class2]">
            <xsl:call-template name="list2-item"/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </list>
  </xsl:template>
  <xsl:template name="list2-item">
    <list-item>
      <xsl:call-template name="list-item-label-and-p"/>
    </list-item>
  </xsl:template>
  <xsl:template name="list-item-label-and-p">
    <label><xsl:value-of select="./h:span[1]"/></label>
    <p><xsl:apply-templates select="./h:span[1]/following-sibling::node()"/></p>
  </xsl:template>

  <xsl:template match="h:p">
    <p>
      <xsl:apply-templates select="*|text()"/>
    </p>
  </xsl:template>

  <xsl:template match="h:b|h:strong">
    <bold>
      <xsl:apply-templates select="*|text()"/>
    </bold>
  </xsl:template>

  <xsl:template match="h:italic|h:i|h:em">
    <italic>
      <xsl:apply-templates select="*|text()"/>
    </italic>
  </xsl:template>

  <xsl:template match="h:sub">
    <sub>
      <xsl:apply-templates select="*|text()"/>
    </sub>
  </xsl:template>

  <xsl:template match="h:sup">
    <sup>
      <xsl:apply-templates select="*|text()"/>
    </sup>
  </xsl:template>

  <xsl:template match="h:tt|h:kbd|h:samp|h:var">
    <monospace>
      <xsl:apply-templates select="*|text()"/>
    </monospace>
  </xsl:template>

  <xsl:template match="h:u">
    <underline>
      <xsl:apply-templates select="*|text()"/>
    </underline>
  </xsl:template>

  <xsl:template match="h:br">
    <break>
      <xsl:apply-templates select="*|text()"/>
    </break>
  </xsl:template>

  <xsl:template match="h:table">
    <table>
      <xsl:apply-templates select="*"/>
    </table>
  </xsl:template>

  <xsl:template match="h:colgroup">
    <colgroup>
      <xsl:apply-templates select="*"/>
    </colgroup>
  </xsl:template>

  <xsl:template match="h:col">
    <col>
      <xsl:apply-templates select="*"/>
    </col>
  </xsl:template>

  <xsl:template match="h:thead">
    <thead>
      <xsl:apply-templates select="*"/>
    </thead>
  </xsl:template>

  <xsl:template match="h:tbody">
    <tbody>
      <xsl:apply-templates select="*"/>
    </tbody>
  </xsl:template>

  <xsl:template match="h:tr">
    <tr>
      <xsl:apply-templates select="*"/>
    </tr>
  </xsl:template>

  <!-- emit th for html th, or for html td with a class 'th' or 'th-...' -->
  <xsl:template match="h:th|h:td[fn:tokenize(@class, '[- ]')='th']">
    <th>
      <xsl:call-template name="align-or-content-type-attribute"/>
      <xsl:apply-templates select="@colspan|@rowspan"/>
      <xsl:call-template name="td-or-th-content"/>
    </th>
  </xsl:template>

  <xsl:template match="h:td">
    <td>
      <xsl:call-template name="align-or-content-type-attribute"/>
      <xsl:apply-templates select="@colspan|@rowspan"/>
      <xsl:call-template name="td-or-th-content"/>
    </td>
  </xsl:template>

  <xsl:template name="align-or-content-type-attribute">
    <xsl:if test="fn:exists(@class)">
      <xsl:variable name="classes" select="fn:tokenize(@class)"/>
      <xsl:variable name="isLoneP" as="xs:boolean"
                    select="fn:count(*)=1 and fn:exists(h:p) and
                            fn:normalize-space(.)=fn:normalize-space(h:p)"/>
      <xsl:variable name="pClasses" select="fn:tokenize(h:p[1]/@class)"/>
      <!-- align attribute -->
      <xsl:choose>
        <xsl:when test="$classes='td-center' or $classes='th-center' or 
                        ($isLoneP and $pClasses='center')">
          <xsl:attribute name="align" select="'center'"/>
        </xsl:when>
        <xsl:when test="$classes='td-right' or $classes='th-right' or
                        ($isLoneP and $pClasses='right')">
          <xsl:attribute name="align" select="'right'"/>
        </xsl:when>
        <xsl:when test="$classes='td-left' or $classes='th-left' or
                        ($isLoneP and $pClasses='left')">
          <xsl:attribute name="align" select="'left'"/>
        </xsl:when>
      </xsl:choose>        
      <!-- content-type attribute -->
      <xsl:choose>
        <xsl:when test="$classes='td-indent'">
          <xsl:attribute name="content-type" select="'table-subdata'"/>
        </xsl:when>
        <xsl:when test="$classes='th-sub'">
          <xsl:attribute name="content-type" select="'table-subhead'"/>
        </xsl:when>
        <xsl:when test="$classes='td-ul'">
          <xsl:attribute name="content-type" select="'table-item'"/>
        </xsl:when>
        <xsl:when test="$classes='td-ul2'">
          <xsl:attribute name="content-type" select="'table-item2'"/>
        </xsl:when>
      </xsl:choose>      
    </xsl:if>
  </xsl:template>

  <xsl:template name="td-or-th-content">
    <xsl:choose>
      <!-- Unwrap if just one child, an h:p with no attributes
           or just a class 'tbl-fig_th', 'left', 'center', or 'right'.
           ('tbl-fig_th' is ignored.  'left', 'center', 'right' are
            handled by align-or-content-type-attribute.) -->
      <xsl:when test="fn:count(*)=1 and fn:exists(h:p) and 
                      (fn:empty(h:p/@*) or 
                       (fn:count(h:p/@*)=1 and 
                        h:p/@class=('tbl-fig_th','tbl-fig_tr','left','center','right'))) and
                      fn:normalize-space(.)=fn:normalize-space(h:p)">
        <xsl:apply-templates select="h:p/node()"/>
      </xsl:when>
      <xsl:otherwise> <!-- otherwise multiline so keep paragraphs -->
        <xsl:apply-templates select="*"/>
      </xsl:otherwise>          
    </xsl:choose>
  </xsl:template>

  <xsl:template match="h:img">
    <graphic>
      <xsl:attribute name="xlink:href" select="@src"/>
      <xsl:if test="@alt != ''">
        <xsl:attribute name="alt-text" select="@alt"/>
      </xsl:if>
    </graphic>
  </xsl:template>

  <xsl:template match="@colspan|@rowspan">
    <xsl:attribute name="{name(.)}" select="."/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:copy/>
  </xsl:template>

</xsl:transform>
