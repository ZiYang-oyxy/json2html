# json2html pretty print

awk --re-interval '
BEGIN {
}

# first scan
( NR==FNR ) {
	if ( $0 ~ /^<tr>$/ ) {
		# start td number counting
		col_counter_toggle = 1
		col_count = 0
	}

	if ( $0 ~ /^<\/tr>$/ ) {
		# stop td number counting
		col_counter_toggle = 0
		col_max = col_count > col_max ? col_count : col_max
	}

	if ( $0 ~ /<td>.*<\/td>/ && col_counter_toggle == 1 ) {
		col_count++
	}

	# count multi-row number
	multi_row_name = gensub(/^<td>(.+) #[[:digit:]]<\/td>$/, "\\1", "", $0)
	if ( multi_row_name != $0 ) {
		multi_row_count[multi_row_name]++
	}

	next
}

# second scan
{
	#
	# pad empty cell if the row did not has enough column number
	#

	if ( $0 ~ /^<tr>$/ ) {
		col_counter_toggle = 1
		col_count = 0
	}

	if ( $0 ~ /^<\/tr>$/ ) {
		col_counter_toggle = 0

		empty_column_count = col_max - col_count
		while ( empty_column_count > 0 ) {
			print "<td>N/A</td>"
			empty_column_count--
		}
	}

	if ( $0 ~ /<td>.*<\/td>/ && col_counter_toggle == 1 ) {
		col_count++
	}

	#
	# modify the cell which is:
	# 	1. the multi-row type
	# 	2. has not been modified
	#

	res = gensub(/^<td>(.+) #[[:digit:]]<\/td>$/, "\\1", "", $0)

	# not match, print entire line immdiately
	if ( res == $0 ) {
		print
		next
	}

	# do not print this type of line anymore if rowspan has been setted
	if ( mark[res] == 0 ) {
		mark[res] = 1
		printf("<td rowspan=%d>%s</td>\n", multi_row_count[res], res)
	}
}

END {
}
' $1 $1
