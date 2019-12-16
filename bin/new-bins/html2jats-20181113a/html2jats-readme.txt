html2jats transforms an xhtml file (from a specific journal article
xhtml format exported from InDesign) to JATS Journal Publishing 1.1
format acceptable to the PubMedCentral Style Checker.

Sample files

  Input files
  - NNNN.html : Optional exported Slovenian article xhtml file format.
  - NNNN-en.html : Optional exported English article xhtml file format.
  - NNNN_edifiX_JATSXML.xml
    A reference list file exported from edifiX JATS plugin.
    The DOCTYPE line has been removed

  Output files
  - NNNN-sl.xml : Slovenian output file produced by html2jats.xsl
  - NNNN-en.xml : English output file produced by html2jats.xsl

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

- Download the Saxon-HE Java imlementation of XSLT 3.0 from
  saxon.sourceforge.net
  Unzip the file to a folder of your choice.
  (Tested with SaxonHE-9-8-0-14J.) 

- Set the SAXON_HOME command line environment variable to the path to the
  installed Saxon folder containing saxon9he.jar .
  (in bash, also 'export SAXON_HOME' so the script can see it.)

- Unzip the html2jats zip file if you have not done so already.

Run:

Depending on your command shell, you should now be able to run
html2jats on the 2660 folder as follows.

BASH:
  cd html2jats/
  bin/html2jats.sh 2660
  bin/html2jats.sh 2660 all
  bin/html2jats.sh 2660 sl
  bin/html2jats.sh 2660 en

CMD:
  cd html2jats\
  bin\html2jats.cmd 2660
  bin\html2jats.cmd 2660 all
  bin\html2jats.cmd 2660 sl
  bin\html2jats.cmd 2660 en

The optional second parameter selects which pass will run.  Default is
all, which, if the required input file is present, can transform both
Slovenian 2660.html to 2660-sl.xml and also transform English
2660-en.xml to 2660-en.xml.

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
