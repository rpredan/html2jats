#!/bin/sh
# This command file runs jats2idrefs to convert
# a JATS article xml <ref-list> of <mixed-citation>s to
# - id-refs-print.txt (without doi and pubmed URLs) 
# - id-refs-web.txt (with doi and pubmed URLs)
#
# SAXON_HOME must be set to the folder containing saxon9he.jar.
# export SAXON_HOME=~/SaxonHE9-8-0-14J
#
# RESOLVER_HOME must be set to the folder containing resolver.jar.
# export RESOLVER_HOME=~/xml-commons-resolver-1.2

# jats2idrefs.sh must be in the same folder as jats2idrefs.xsl
# and jats-dtd-catalog.xml (from html2jats).
HTML2JATS_HOME=$(realpath --relative-to=. $(dirname $0))

# parameters: path-to/NNNN_edifiX_JATSXML.xml
# This will write output files in same folder.

DIR=$(realpath --relative-to=. $(dirname $1))

java -cp "$SAXON_HOME/saxon9he.jar;$RESOLVER_HOME/resolver.jar" \
  net.sf.saxon.Transform \
  "-catalog:$HTML2JATS_HOME/jats-dtd-catalog.xml" \
  "-xsl:$HTML2JATS_HOME/jats2idrefs.xsl" \
  "-s:$1"  \
  "-o:$DIR/idrefs-print.txt" \
  "forWeb=false"

java -cp "$SAXON_HOME/saxon9he.jar;$RESOLVER_HOME/resolver.jar" \
  net.sf.saxon.Transform \
  "-catalog:$HTML2JATS_HOME/jats-dtd-catalog.xml" \
  "-xsl:$HTML2JATS_HOME/jats2idrefs.xsl" \
  "-s:$1"  \
  "-o:$DIR/idrefs-web.txt" \
  "forWeb=true"
