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
Usage: $0 <JSON_FILE> [-c CSS_FILE] [-P]

Options:
    -c     css for table
    -P     don't run pp.awk for pretty print (merge the same type of <td>),
           so that you can use your own script to decorate the html table
EOF
}

JSON_FILE=
CSS_FILE=
PRETTY_PRINT=true

if [ -z "$1" ] || [ "$1" = "-h" ]; then
	usage
	exit 1
fi

while [ -n "$1" ]; do
	if [ "$1" = "-c" ]; then
		shift
		CSS_FILE="$1"
		shift
	fi

	if [ "$1" = "-P" ]; then
		PRETTY_PRINT=false
		shift
	fi

	if [ -n "$1" ]; then
		JSON_FILE="$1"
		shift
	fi
done

if [ -z "$CSS_FILE" ]; then
	CSS_FILE=$P/default.css
fi

if $PRETTY_PRINT ;then
	$P/html_gen.lua $JSON_FILE $CSS_FILE > /tmp/json2html.tmp
	$P/pp.awk /tmp/json2html.tmp /tmp/json2html.tmp
else
	$P/html_gen.lua $JSON_FILE $CSS_FILE
fi
