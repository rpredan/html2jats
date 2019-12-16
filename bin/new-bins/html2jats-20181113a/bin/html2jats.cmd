@ECHO OFF
REM This command file runs html2jats.xsl to convert xhtml (from a
REM specific journal article xhtml format exported from InDesign) to
REM JATS format for PubMedCentral.
				   
REM SAXON_HOME must be set to the folder containing saxon9he.jar.
REM SET "SAXON_HOME=%USERPROFILE%\SaxonHE9-8-0-14J"

REM html2jats.cmd must be in the same folder as html2jats.xsl
SET HTML2JATS_HOME=%0\..

REM parameters: path-to/NNNN [pass]
REM where NNNN is a folder containing NNNN.html and NNNN_edifiX_JATSXML.xml
REM where [pass] is optional, may be "sl" or "en" (default is all).
REM
REM For example, suppose NNNN is '2660', then the folder may contain
REM   path-to/2660/2660.html
REM   path-to/2660/2660-en.html
REM   path-to/2660/2660_edifiX_JATSXML.xml (with doctype removed)
REM Output is written to
REM   path-to/2660/2660-sl.xml
REM   path-to/2660/2660-en.xml

SET DIR=%~f1
SET FILE=%~n1

IF "%2"=="" SET RUN_EN=TRUE
IF "%2"=="" SET RUN_SL=TRUE
IF "%2"=="all" SET RUN_EN=TRUE
IF "%2"=="all" SET RUN_SL=TRUE
IF "%2"=="en" SET RUN_EN=TRUE
IF "%2"=="sl" SET RUN_SL=TRUE

IF DEFINED RUN_SL IF EXIST "%DIR%\%FILE%.html"^
  java -jar "%SAXON_HOME%/saxon9he.jar"^
    "-xsl:%HTML2JATS_HOME%/html2jats.xsl"^
    "-s:%DIR%/%FILE%.html" ^
    "-o:%DIR%/%FILE%-sl.xml"^
    "+reflistDoc=%DIR%/%FILE%_edifiX_JATSXML.xml"

IF DEFINED RUN_EN IF EXIST "%DIR%\%FILE%-en.html"^
  java -jar "%SAXON_HOME%/saxon9he.jar"^
    "-xsl:%HTML2JATS_HOME%/html2jats.xsl"^
    "-s:%DIR%/%FILE%-en.html"^
    "-o:%DIR%/%FILE%-en.xml"^
    "+reflistDoc=%DIR%/%FILE%_edifiX_JATSXML.xml"
