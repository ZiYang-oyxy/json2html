# json2html pretty print module

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
#		print $0
		col_count++

		if ( $0 ~ /^<td>#[[:digit:]]# @....@<\/td>$/ ) {
			if ( concise != "no" ) {
				hide_this_col[col_count] = 1
			}
		} else if ( $0 ~ /^<td>.+ @....@<\/td>$/ ) {
			# if it is a table(has "@....@" in the tail), we will count rowspan number
			curr_row_col[col_count] = gensub(/<td>(.*)<\/td>/, "\\1", "", $0)

			# compare the corresponding column of previous row
			if ( prev_row_col[col_count] == curr_row_col[col_count] ) {
				if ( rowspan[curr_row_col[col_count]] == 0 ) {
					rowspan[curr_row_col[col_count]] = 1
				}
				rowspan[curr_row_col[col_count]]++
			#	print "get here!!"
			#	print rowspan[curr_row_col[col_count]]
			}

			# save current row for later use
			prev_row_col[col_count] = curr_row_col[col_count]
		}
	}

	next
}

# second scan
( FNR == 1 ) {
	for ( i in hide_this_col )
		hided_col_num++
	col_max = col_max - hided_col_num
}

{
	if ( $0 ~ /^<tr>$/ ) {
		col_counter_toggle = 1
		col_count = 0
		true_col_num = 0
	}

	if ( $0 ~ /^<\/tr>$/ ) {
		col_counter_toggle = 0

		# pad empty cell if the row did not has enough column number
		if ( regular != "no" ) {
			empty_column_count = col_max - true_col_num
			while ( empty_column_count > 0 ) {
				print "<td>N/A</td>"
				empty_column_count--
			}
		}
	}

	if ( $0 ~ /<td>.*<\/td>/ && col_counter_toggle == 1 ) {
		col_count++
		true_col_num++

		if ( hide_this_col[col_count] == 1 ) {
			true_col_num--
			next
		}

		#
		# modify the cell which is:
		# 	1. the rowspan type
		# 	2. has not been modified
		#

		cell = gensub(/<td>(.*)<\/td>/, "\\1", "", $0)
		if ( rowspan[cell] != 0 ) {
			if ( modified[cell] == 0 ) {
				# trim table id at the tail
				tmp = gensub(/(.*)( @....@)$/, "\\1", "", cell)

				printf("<td rowspan=%d>%s</td>\n", rowspan[cell], tmp)
				modified[cell] = 1
			}
			next
		} else {
			$0 = gensub(/(.*)( @....@)(<\/td>)/, "\\1\\3", "", $0)
		}
	}

	print
}

END {
}
