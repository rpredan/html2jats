@ECHO OFF
REM This command file runs jats2idrefs to convert
REM a JATS article xml <ref-list> of <mixed-citation>s to
REM - id-refs-print.txt (without doi and pubmed URLs) 
REM - id-refs-web.txt (with doi and pubmed URLs)
REM
REM SAXON_HOME must be set to the folder containing saxon9he.jar.
REM SET "SAXON_HOME=%USERPROFILE%\SaxonHE9-8-0-14J"
REM
REM RESOLVER_HOME must be set to the folder containing resolver.jar.
REM SET "RESOLVER_HOME=%USERPROFILE%\xml-commons-resolver-1.2"

REM jats2idrefs.cmd must be in the same folder as jats2idrefs.xsl
REM and jats-dtd-catalog.xml (from html2jats).
SET HTML2JATS_HOME=%0\..

REM parameters: path-to/NNNN_edifiX_JATSXML.xml
REM This will write output files in same folder.

SET DIR=%~f1\..

java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
  net.sf.saxon.Transform^
  "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
  "-xsl:%HTML2JATS_HOME%/jats2idrefs.xsl"^
  "-s:%1" ^
  "-o:%DIR%/idrefs-print.txt"^
  "forWeb=false"

java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
  net.sf.saxon.Transform^
  "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
  "-xsl:%HTML2JATS_HOME%/jats2idrefs.xsl"^
  "-s:%1" ^
  "-o:%DIR%/idrefs-web.txt"^
  "forWeb=true"
