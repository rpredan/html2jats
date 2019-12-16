#!/bin/sh
# This command file runs html2jats.xsl to convert xhtml (from a
# specific journal article xhtml format exported from InDesign) to
# JATS format for PubMedCentral.

# SAXON_HOME must be set to the folder containing saxon9he.jar.
# SAXON_HOME=~/SaxonHE9-8-0-14J
# export SAXON_HOME

# html2jats.sh must be in the same folder as html2jats.xsl
HTML2JATS_HOME=$(realpath --relative-to=. $(dirname $0))

# parameters: path-to/NNNN [pass]
# where NNNN is both a folder name and part of file names.
# where [pass] is optional, may be "sl" or "en" (default is "all")
#
# For example, suppose NNNN is '2660', then the folder may contain
#   path-to/2660/2660.html
#   path-to/2660/2660-en.html
#   path-to/2660/2660_edifiX_JATSXML.xml (with doctype removed)
# Output is written to
#   path-to/2660/2660-sl.xml
#   path-to/2660/2660-en.xml

DIR=$(realpath --relative-to=. $1)
FILE=$(basename $DIR)

if [[ ( -z "$2" || "$2" = "all" || "$2" = "sl") && -f $DIR/$FILE.html ]];
then
    java -jar "$SAXON_HOME/saxon9he.jar" \
	 "-xsl:$HTML2JATS_HOME/html2jats.xsl" \
	 "-s:$DIR/$FILE.html" \
	 "-o:$DIR/$FILE-sl.xml" \
	 "+reflistDoc=$DIR/${FILE}_edifiX_JATSXML.xml"
fi

if [[ ( -z "$2" || "$2" = "all" || "$2" = "en") && -f $DIR/$FILE-en.html ]];
then
    java -jar "$SAXON_HOME/saxon9he.jar" \
	 "-xsl:$HTML2JATS_HOME/html2jats.xsl" \
	 "-s:$DIR/$FILE-en.html" \
	 "-o:$DIR/$FILE-en.xml" \
	 "+reflistDoc=$DIR/${FILE}_edifiX_JATSXML.xml"
fi
