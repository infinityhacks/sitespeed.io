#! /bin/bash

command -v xsltproc  >/dev/null 2>&1 || { echo >&2 "Missing xsltproc, please install it to be able to run sitespeed-junit.io"; exit 1; }

#*******************************************************
# Help function, call it to print all different usages.
#
#*******************************************************
help()
{
cat << EOF
usage: $0 options

sitespeed-juni.io is a tool that will convert your sitespeed result into a junit.xml file. Read more at http://sitespeed.io

OPTIONS:
   -h      Help
   -r      The result base directory, default is sitespeed-result [optional]
   -l      The page score limit. Below this page score it will be a failure. Default is 90. [optional]
   -a      The average score limit for all tested pages, below this score it will be a failure. Default is 90. [optional]	
   -s      Skip these tests. A comma separeted list of the key name of the tests, for example "ycsstop,yjsbottom" [optional]   
   -o      Outputs to the given file instead of outputting to stdout [optional]
   -c      Copy the summary.xml file to this given dir
 
EOF
}

REPORT_BASE_DIR=sitespeed-result
PAGE_LIMIT=90
AVERAGE_LIMIT=90
SKIP_TESTS=
OUTPUT_FILENAME=
OUTPUT=
SUMMARY_XML_DIR=

# Set options
while getopts “hr:l:s:o:a:c:” OPTION
do
     case $OPTION in
         h)
             help
             exit 1
             ;;
         r)REPORT_BASE_DIR=$OPTARG;;
         l)PAGE_LIMIT=$OPTARG;;
         s)SKIP=$OPTARG;;
         o)OUTPUT_FILENAME=$OPTARG;;
         a)AVERAGE_LIMIT=$OPTARG;;
	 c)SUMMARY_XML_DIR=$OPTARG;;
         ?)
             help
             exit
             ;;
     esac
done

if [ "$SKIP" != "" ]
then
    SKIP_TESTS="--stringparam skip $SKIP"
fi

if [ "$OUTPUT_FILENAME" != "" ]
then
    OUTPUT="--output $OUTPUT_FILENAME"
fi


# Switch to my dir
cd "$(dirname ${BASH_SOURCE[0]})"
HOME="$(pwd)"

cd $REPORT_BASE_DIR
HOST_DIR="$(\ls -1dt */ | head -n 1)"
cd $HOST_DIR
DATE_DIR="$(\ls -1dt */ | head -n 1)"
cd $DATE_DIR
ABSOLUTE_ANALYZE_DIR=$(pwd)

if [ "$" != "SUMMARY_XML_DIR"  ]
then
    cp "$ABSOLUTE_ANALYZE_DIR/data/summary.xml" $SUMMARY_XML_DIR/summary.xml
fi


## TODO the dependency of the file name is not so good!
RULES_FILE="$ABSOLUTE_ANALYZE_DIR/data/pages/1.xml"
XSL_FILE=$HOME/report/xslt/junit.xsl
RESULT_XML=$ABSOLUTE_ANALYZE_DIR/data/result.xml

xsltproc --stringparam page-limit $PAGE_LIMIT --stringparam avg-limit $AVERAGE_LIMIT $OUTPUT --stringparam rules-file $RULES_FILE $SKIP_TESTS $XSL_FILE $RESULT_XML 