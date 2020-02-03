Jats2idrefs converts a JATS article xml <ref-list> of <mixed-citation>s to text:
- id-refs-print.txt (without doi and pubmed URLs) 
- id-refs-web.txt (with doi and pubmed URLs)
It is used with html2jats to convert edifiX JATS output.

Installation:

Install jats2idrefs.xsl, jats2idrefs.cmd, and jats2idrefs.sh in the
same folder as the jats-dtd-catalog.xml from HTML2JATS.

jats2idrefs also depends on the same SAXON_HOME and RESOLVER_HOME
variables as html2jats.  See Html2jats-readme.txt.

Run

BASH:
  cd html2jats/
  bin/jats2idrefs.sh path-to/reference-examples.xml

CMD:
  cd html2jats\
  bin\jats2idrefs.cmd path-to\reference-examples.xml

The jats2idrefs scripts will write the output to the same folder as the input.




