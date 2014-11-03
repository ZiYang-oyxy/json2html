#!/bin/bash
#
# convert json to html table
#
# Author: OuyangXY <oywymail@163.com>
#
# Changes:
#       OuyangXY: Create file, 2014-11-01

ME=`readlink -f $BASH_SOURCE`
P=`dirname $ME`

export LUA_PATH="$P/?.lua;$P/lib/?.lua;;"
export LUA_CPATH="$P/lib/?.so;;"

usage() {
	cat <<EOF
Usage: $0 [-c CSS_FILE] [-H] [-P] <JSON_FILE>

Options:
    -c     css for table
    -H     don't output other HTML elements, just output HTML table elements
    -P     don't run pp.awk for pretty print (this script will use rowspan
           to merge the same type of <td> elements), so that you can use
           your own script to decorate the table or just import it to excel
EOF
}

JSON_FILE=
CSS_FILE=
PRETTY_PRINT=true
PURE_TBL="0"

[ -z "$1" ] && usage && exit 1

while getopts ":PHc:h" opt
do
  case $opt in
	h ) usage; exit 0;;

	P ) PRETTY_PRINT=false;;

	H ) PURE_TBL="1";;

	c ) echo "$OPTARG";CSS_FILE="$OPTARG";;

	\? ) echo -e "\n  Option does not exist : $OPTARG\n"
			usage; exit 1;;
  esac
done
shift $(($OPTIND-1))

JSON_FILE=$1

if [ -z "$CSS_FILE" ]; then
	CSS_FILE=$P/default.css
fi

if $PRETTY_PRINT ;then
	$P/html_gen.lua $JSON_FILE $CSS_FILE $PURE_TBL > /tmp/json2html.tmp
	$P/pp.awk /tmp/json2html.tmp /tmp/json2html.tmp
	rm /tmp/json2html.tmp
else
	$P/html_gen.lua $JSON_FILE $CSS_FILE $PURE_TBL
fi
