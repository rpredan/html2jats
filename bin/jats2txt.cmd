@ECHO OFF
REM This command file runs jats2txt to convert
REM a JATS article xml <ref-list> of <mixed-citation>s to
REM - id-refs-print.txt (without doi and pubmed URLs) 
REM - id-refs-web.txt (with doi and pubmed URLs)
REM
REM SAXON_HOME must be set to the folder containing saxon9he.jar.
REM SET "SAXON_HOME=%USERPROFILE%\SaxonHE9-8-0-14J"
REM
REM RESOLVER_HOME must be set to the folder containing resolver.jar.
REM SET "RESOLVER_HOME=%USERPROFILE%\xml-commons-resolver-1.2"

REM jats2txt.cmd must be in the same folder as jats2txt.xsl
REM and jats-dtd-catalog.xml (from html2jats).
SET HTML2JATS_HOME=%0\..

REM parameter: path-to/NNNN      (for path-to/NNNN/NNNN_edifiX_JATSXML.xml), or
REM parameter: path-to/NNNN_edifiX_JATSXML.xml
REM This will write output files in same folder.

IF EXIST %1\%~n1_edifix_JATSXML.xml (
  SET DIR=%~f1
  SET FILE=%~n1%~x1_edifix_JATSXML.xml
) else (
  SET DIR=%~f1\..
  SET FILE=%~n1%~x1
)

java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
  net.sf.saxon.Transform^
  "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
  "-xsl:%HTML2JATS_HOME%/jats2txt.xsl"^
  "-s:%DIR%/%FILE%" ^
  "-o:%DIR%/idrefs-print.txt"^
  "forWeb=false"

java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
  net.sf.saxon.Transform^
  "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
  "-xsl:%HTML2JATS_HOME%/jats2txt.xsl"^
  "-s:%DIR%/%FILE%" ^
  "-o:%DIR%/idrefs-web.txt"^
  "forWeb=true"
