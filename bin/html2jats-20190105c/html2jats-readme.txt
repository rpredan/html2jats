html2jats transforms an xhtml file (from a specific journal article
xhtml format exported from InDesign) to JATS Journal Publishing 1.1
format acceptable to the PubMedCentral Style Checker.

Sample files

  Input files
  - NNNN.html : Optional exported Slovenian article xhtml file format.
  - NNNN-en.html : Optional exported English article xhtml file format.
  - NNNN_edifiX_JATSXML.xml
    A reference list file exported from edifiX JATS plugin.

  Output files
  - NNNN-sl.xml : Slovenian output file produced by html2jats.xsl
  - NNNN-en.xml : English output file produced by html2jats.xsl
  - NNNN-all.xml : Combined output file produced by combinejats.xsl

  NNNN matches the parent folder, one of following:
  - 1670/     (Some figures have two numbers, requires manual fix.)

  - 2484/     (Text with bibliograhic references)

  - 2523/     (Text with refs, bullet list, end tables and figures) 
	      (A fake reference list added to validate bib xrefs.)

  - 2619/     (Authors with same last name from two institutions.)

  - 2634/     (Authors from two institutions.  Subsections,
               bullet list, inline figures and tables)

  - 2637/     (Short article with references, bullet list, and
               an inline figure and an inline table.)

  - 2638/     (Figure 2 has two paragraphs.)

  - 2659/     (Text with references, inline tables and figures)

  - 2660/     (With translation.  Text with references, no figures or tables.)

  - 2668/     (English article, 2 inline figures)

  - 2673/     (Text with references, subsections, inline figures.)

  - 2674/     (Text with references, figures, bullet list.)

  - 2705/     (Text with references, subsections, two figures.)

Installation:

o Saxon-HE (Java implementation of XSLT 3.0)
  - Download Saxon-HE 9.8 from
    saxon.sourceforge.net
  - Unzip the file to a folder of your choice.
    (Tested with SaxonHE-9-8-0-14J.  With SaxonHE-9-9-02J, "+param=doc" failed.)
  - Set the SAXON_HOME command line environment variable to the path to the
    installed Saxon folder containing saxon9he.jar .
    (in bash, also 'export SAXON_HOME' so the script can see it.)

o Apache XML-Commons-Resolver (Entity resolver for using a local DTD catalog)
  - Downloads Apache XML-Commons-Resolver from
    http://xerces.apache.org/xml-commons/
  - Unzip the file to a folder of your choice.
    (Tested with Xml-Commons-Resolver 1.2)
  - Set the RESOLVER_HOME command line environment variable to the path to the
    installed folder containing resolver.jar .
    (in bash, also 'export RESOLVER_HOME' so the script can see it.)

o JATS DTD Schemas (Schemas needed to parse xml with these DTDs in DOCTYPE)
  - Download jats-archiving-dtd-1.0.zip from
    ftp://ftp.ncbi.nih.gov/pub/jats/archiving/1.0/
    (This schema is needed to parse NNNN_edifiX_JATSXML.xml files.)
  - Download JATS-Publishing-1-1-OASIS-MathML3-DTD.zip from
    ftp://ftp.ncbi.nih.gov/pub/jats/publishing/1.1/
    (This schema is needed to parse JATS files to be combined.)
  - Unzip each schema zip file under a folder of your choice.

o HTML2JATS
  - Unzip the html2jats zip file under the same folder as the schemas.

If you unzipped the zip files under a folder called "myjats" then 
"myjats" should now have at least the following subfolders:

  myjats/
  - html2jats-YYYYMMDDx/
  - jats-archiving-dtd-1.0/
  - JATS-Publishing-1-1-MathML3-DTD/

(These folders are siblings because 
   html2jats-YYYYMMDDx/bin/jats-dtd-catalog.xml
 refers to the DTD schemas via relative paths starting from the bin folder.
   xml:base="file:../../jats-archiving-dtd-1.0/"
   xml:base="file:../../JATS-Publishing-1-1-MathML3-DTD/"
 This structure was chosen so the DTD folders remain in the same place when
 a new html2jats version is installed.
)


Run:

Depending on your command shell, you should now be able to run
html2jats on the 2660 folder as follows.

BASH:
  cd html2jats/
  bin/html2jats.sh 2660
  bin/html2jats.sh 2660 all
  bin/html2jats.sh 2660 sl
  bin/html2jats.sh 2660 en
  bin/html2jats.sh 2660 combine

CMD:
  cd html2jats\
  bin\html2jats.cmd 2660
  bin\html2jats.cmd 2660 all
  bin\html2jats.cmd 2660 sl
  bin\html2jats.cmd 2660 en
  bin\html2jats.cmd 2660 combine

The html2jats script runs 3 transforms.
- sl: html2jats.xsl on X.html and X_edifiX_JATSXML.xml producing X-sl.xml.
- en: html2jats.xsl on X-en.html and X_edifiX_JATSXML.xml producing X-en.xml.
- combine: combinejats.xsl on X-sl.xml and X-en.xml producing X-all.xml

The optional second parameter selects which pass will run.  Default is
all, which will run all passes for which required inputs are present.

2660-sl.xml and 2660-en.xml may be used for OpenJournalSystem JATS.
2660-all.xml may be uploaded to PubMedCentral.  (If there is no
translation, then 2660-sl.xml or 2660-en.xml may be uploaded to
PubMedCentral.)

Replace 2660 with another sample number to run the other examples.


Validate format:

  Open the following page, upload an output file, and press check file.
  https://www.ncbi.nlm.nih.gov/pmc/tools/stylechecker/

  (Note: if an <xref @rid="ABC"/> exists, then a valid document must
   have exactly one element with @id="ABC".  The PMC Style Checker will
   report there is an error but might not explain or locate it.
   Other DTD validation tools may produce a more informative error.)

Current results:

All but 1670-sl.xml passed DTD validation and PMC style checker, similar to the following.

  Style Check Results
  File: 2484.xml
  DTD Validation: OK
  PMC Style Check: OK

Exception: 1670-sl.xml did not pass.  1670-sl_fixed-manually.xml passes.

1670.html contains figures with two figure numbers.  So 1670.xml needs
to be fixed manually, so that both references will refer to the same
fig.  1670_fixed-manually.xml shows one approach, which is to

1. Set a combined fig id
  <fig id="fig4and5">...</fig> and

2. Use the combined fig id in both xref rid
  <xref rid="fig4and5">Slika 4</xref>, <xref rid="fig4and5">Slika 5</xref>

3. Fix the misparsed label and caption.
