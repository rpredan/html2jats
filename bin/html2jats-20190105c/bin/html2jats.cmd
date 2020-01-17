@ECHO OFF
REM This command file runs html2jats.xsl to convert 
REM original Slovenenian xhtml and translated English xhtml
REM (from a specific journal article xhtml format exported from InDesign)
REM to JATS format for PubMedCentral.
				   
REM SAXON_HOME must be set to the folder containing saxon9he.jar.
REM SET "SAXON_HOME=%USERPROFILE%\SaxonHE9-8-0-14J"
REM
REM RESOLVER_HOME must be set to the folder containing resolver.jar.
REM SET "RESOLVER_HOME=%USERPROFILE%\xml-commons-resolver-1.2"

REM html2jats.cmd must be in the same folder as html2jats.xsl
SET HTML2JATS_HOME=%0\..

REM parameters: path-to/NNNN [pass]
REM where NNNN is a folder containing NNNN.html and NNNN_edifiX_JATSXML.xml
REM where [pass] is optional, may be "sl", "en", "combine", or "all" (default).
REM
REM For example, suppose NNNN is '2660', then the folder may contain
REM   path-to/2660/2660.html
REM   path-to/2660/2660-en.html
REM   path-to/2660/2660_edifiX_JATSXML.xml
REM Output may be written to
REM   path-to/2660/2660-sl.xml
REM   path-to/2660/2660-en.xml
REM   path-to/2660/2660-all.xml

SET DIR=%~f1
SET FILE=%~n1

IF "%2"=="" SET RUN_EN=TRUE
IF "%2"=="" SET RUN_SL=TRUE
IF "%2"=="" SET RUN_COMBINE=TRUE
IF "%2"=="all" SET RUN_EN=TRUE
IF "%2"=="all" SET RUN_SL=TRUE
IF "%2"=="all" SET RUN_COMBINE=TRUE
IF "%2"=="en" SET RUN_EN=TRUE
IF "%2"=="sl" SET RUN_SL=TRUE
IF "%2"=="combine" SET RUN_COMBINE=TRUE

IF DEFINED RUN_SL IF EXIST "%DIR%\%FILE%.html"^
  java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
    net.sf.saxon.Transform^
    "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
    "-xsl:%HTML2JATS_HOME%/html2jats.xsl"^
    "-s:%DIR%/%FILE%.html" ^
    "-o:%DIR%/%FILE%-sl.xml"^
    "+reflistDoc=%DIR%/%FILE%_edifiX_JATSXML.xml"

IF DEFINED RUN_EN IF EXIST "%DIR%\%FILE%-en.html"^
  java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
    net.sf.saxon.Transform^
    "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
    "-xsl:%HTML2JATS_HOME%/html2jats.xsl"^
    "-s:%DIR%/%FILE%-en.html"^
    "-o:%DIR%/%FILE%-en.xml"^
    "+reflistDoc=%DIR%/%FILE%_edifiX_JATSXML.xml"

IF DEFINED RUN_COMBINE IF EXIST "%DIR%\%FILE%-sl.xml" IF EXIST "%DIR%\%FILE%-en.xml"^
  java -cp "%SAXON_HOME%/saxon9he.jar;%RESOLVER_HOME%/resolver.jar"^
    net.sf.saxon.Transform^
    "-catalog:%HTML2JATS_HOME%/jats-dtd-catalog.xml"^
    "-xsl:%HTML2JATS_HOME%/combinejats.xsl"^
    "-s:%DIR%/%FILE%-sl.xml"^
    "-o:%DIR%/%FILE%-all.xml"^
    "+translatedDoc=%DIR%/%FILE%-en.xml"
