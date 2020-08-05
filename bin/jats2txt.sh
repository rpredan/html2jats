#!/bin/sh
# This command file runs jats2txt to convert
# a JATS article xml <ref-list> of <mixed-citation>s to
# - id-refs-print.txt (without doi and pubmed URLs) 
# - id-refs-web.txt (with doi and pubmed URLs)
#
# SAXON_HOME must be set to the folder containing saxon9he.jar.
# export SAXON_HOME=~/SaxonHE9-8-0-14J
#
# RESOLVER_HOME must be set to the folder containing resolver.jar.
# export RESOLVER_HOME=~/xml-commons-resolver-1.2

# jats2txt.sh must be in the same folder as jats2txt.xsl
# and jats-dtd-catalog.xml (from html2jats).
HTML2JATS_HOME=$(realpath --relative-to=. $(dirname $0))

# parameter: path-to/NNNN      (for path-to/NNNN/NNNN_edifiX_JATSXML.xml), or
# parameter: path-to/NNNN_edifiX_JATSXML.xml
# This will write output files in same folder.

if [[ -f $1/$(basename $1)_edifiX_JATSXML.xml ]];
then
    DIR=$(realpath --relative-to=. $1)
    FILE=$(basename $1)_edifiX_JATSXML.xml
else
    DIR=$(realpath --relative-to=. $(dirname $1))
    FILE=$(basename $1)
fi

java -cp "$SAXON_HOME/saxon9he.jar;$RESOLVER_HOME/resolver.jar" \
  net.sf.saxon.Transform \
  "-catalog:$HTML2JATS_HOME/jats-dtd-catalog.xml" \
  "-xsl:$HTML2JATS_HOME/jats2txt.xsl" \
  "-s:$DIR/$FILE"  \
  "-o:$DIR/idrefs-print.txt" \
  "forWeb=false"

java -cp "$SAXON_HOME/saxon9he.jar;$RESOLVER_HOME/resolver.jar" \
  net.sf.saxon.Transform \
  "-catalog:$HTML2JATS_HOME/jats-dtd-catalog.xml" \
  "-xsl:$HTML2JATS_HOME/jats2txt.xsl" \
  "-s:$DIR/$FILE"  \
  "-o:$DIR/idrefs-web.txt" \
  "forWeb=true"
