#!/bin/awk -f

BEGIN {
	total = 0 
	print "pkgname\t\tsecs\t\tsbu"
}

{
	pkgtime = $4 * 60 * 60 + $6 *60 + $8
	if (NR == 1) {
		sbutime = pkgtime
	}
	sbu = pkgtime / sbutime
	print $1, "\t\t", pkgtime, "\t\t", sbu
	total += pkgtime
}

END {
	hours = total / 3600;
	print "Total time: ", hours, "hrs"
}	

