<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="3.0" 
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:h="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xsl:output method="text"/>

  <xsl:param name="forWeb" select="'true'"/>

  <xsl:template match="article">
    <xsl:apply-templates select="back/ref-list/ref"/>
  </xsl:template>

  <xsl:template match="ref[mixed-citation]">
    <!-- label -->
    <xsl:choose>
      <xsl:when test="label">
        <xsl:value-of select="normalize-space(label)"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@id">
        <xsl:value-of select="concat(substring-after(@id, 'b'), '. ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(position(), '. ')"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- citation -->
    <xsl:apply-templates select="mixed-citation"/>
    <!-- line terminator -->
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation">
    <xsl:message>
      <xsl:text>Skipping ref id="</xsl:text>
      <xsl:value-of select="../@id"/>
      <xsl:text>" because its mixed-citation has unknown publication-type="</xsl:text>
      <xsl:value-of select="@publication-type"/>
      <xsl:text>". </xsl:text>
    </xsl:message>
  </xsl:template>    

  <xsl:template match="mixed-citation[empty(@publication-type)]">
    <xsl:message>
      <xsl:text>Skipping ref id="</xsl:text>
      <xsl:value-of select="../@id"/>
      <xsl:text>" because its mixed-citation has no publication-type.</xsl:text>
    </xsl:message>
  </xsl:template>    

  <xsl:template match="mixed-citation[@publication-type=('journal','book','book-chapter','webpage', 'conference', 'thesis') or @publicate-format='web']">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- Persons -->

  <xsl:template match="person-group">
    <xsl:apply-templates select="*"/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="name">
    <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="surname"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="given-names"/>
  </xsl:template>

  <xsl:template match="etal">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::name]">, </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::collab]">; </xsl:when>
    </xsl:choose>
    <xsl:text>et al</xsl:text>
    <xsl:if test="position() &lt; last()">
      <xsl:text>.</xsl:text>
    </xsl:if><!-- else share dot after person-group -->
  </xsl:template>

  <xsl:template match="role">
    <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="'editors' = normalize-space(.)">eds</xsl:when>
      <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="collab">
    <xsl:if test="position() &gt; 1">
      <xsl:text>; </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <!-- Journal Article -->

  <xsl:template match="article-title">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:call-template name="title-end-punctuation"/>
  </xsl:template>

  <xsl:template match="source"> <!-- book, journal, or webpage title -->
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:call-template name="title-end-punctuation"/>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type='journal']/year">
    <xsl:if test="preceding-sibling::year">
      <xsl:text>; </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="not(following-sibling::*[self::year or self::volume or self::issue or self::fpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="volume">
    <xsl:text>;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="not(following-sibling::*[self::volume or self::issue or self::fpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="issue">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>)</xsl:text>
    <xsl:if test="not(following-sibling::*[self::issue or self::fpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="mixed-citation[@publication-type='journal']/fpage">
    <xsl:choose>
      <xsl:when test="empty(preceding-sibling::*[self::fpage or self::lpage])">
        <xsl:text>:</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="normalize-space(.) != normalize-space(preceding-sibling::*[1][self::fpage or self::lpage])">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(following-sibling::*[self::fpage or self::lpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lpage">
    <xsl:if test="preceding-sibling::*[1][self::fpage] and
                  normalize-space(preceding-sibling::*[1]) != normalize-space(.)">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:if>
    <xsl:if test="not(following-sibling::*[self::fpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="pub-id[@pub-id-type='doi']">
    <xsl:if test="$forWeb='true'">
      <xsl:text>https://doi.org/</xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="pub-id[@pub-id-type='pmid']">
    <xsl:if test="$forWeb='true'">
      <xsl:text>https://pubmed.ncbi.nlm.nih.gov/</xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- book -->

  <xsl:template match="edition">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="publisher-loc">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>: </xsl:text>
  </xsl:template>

  <xsl:template match="publisher-name">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>; </xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type=('book','book-chapter')]/year">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type=('book','book-chapter')]/fpage">
    <xsl:choose> <!-- pp. for page range or series, p. for single page. -->
      <xsl:when test="preceding-sibling::*[1][self::fpage or self::lpage]">
        <xsl:if test="normalize-space(preceding-sibling::*[1]) != normalize-space(.)">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:if>
      </xsl:when>
      <xsl:when
         test="following-sibling::*[(self::fpage or self::lpage) and 
                                    normalize-space(.) != normalize-space(current())]">
        <xsl:text>pp. </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>p. </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="empty(following-sibling::*[self::fpage or self::lpage])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type='book']/series">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>). </xsl:text>
  </xsl:template>

  <!-- book-chapter -->

  <xsl:template match="chapter-title">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:call-template name="title-end-punctuation"/>
    <xsl:text>In: </xsl:text>
  </xsl:template>

  <!-- webpage -->

  <xsl:template match="mixed-citation[@publication-type='webpage']/year">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="not(following-sibling::date-in-citation[@content-type='access-date'])">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="date-in-citation[@content-type='access-date']">
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="starts-with($text, '[cited ')">
        <xsl:value-of select="$text"/>
      </xsl:when>
      <xsl:when test="starts-with($text, 'cited ')">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$text"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[cited </xsl:text>
        <xsl:value-of select="$text"/>
        <xsl:text>]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="date-in-citation[@content-type='copyright-year']">
    <xsl:text>&#xA9;</xsl:text><!--&copy; is copyright symbol (c) -->
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="comment[uri]">
    <xsl:apply-templates select="uri"/>
  </xsl:template>

  <xsl:template match="uri">
    <xsl:text>Available from: </xsl:text>
    <xsl:value-of select="normalize-space(translate(., '&quot;', ''))"/>
    <xsl:text> </xsl:text> <!-- omit final period, easily mistaken for part of uri -->
  </xsl:template>

  <!-- conference -->

  <xsl:template match="mixed-citation[@publication-type='conference']/article-title">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:call-template name="title-end-punctuation"/> 
    <xsl:text>In: </xsl:text>
  </xsl:template>

  <xsl:template match="conf-name">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:call-template name="title-end-punctuation"/>
  </xsl:template>

  <xsl:template match="conf-date">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>; </xsl:text>
  </xsl:template>

  <xsl:template match="conf-loc">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type='conference']/year">
    <xsl:value-of select="."/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type='conference']/fpage"/><!-- omit -->
  <xsl:template match="mixed-citation[@publication-type='conference']/lpage"/><!-- omit -->

  <!-- thesis -->

  <xsl:template match="mixed-citation[@publication-type='thesis']/year">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation[@publication-type='thesis']/comment">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>]. </xsl:text>
  </xsl:template>

  <!-- nothing else -->

  <xsl:template match="node()|text()"/>

  <!-- aux -->

  <xsl:template name="title-end-punctuation">
    <!-- add '.' unless ends with '.' or '!' or '?' -->
    <xsl:choose>
      <xsl:when test="matches(normalize-space(.), '[.!?][&quot;]?$')">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
