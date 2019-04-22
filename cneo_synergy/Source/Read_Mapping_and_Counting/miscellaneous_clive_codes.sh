list_of_numbers=`qstat | cut -f 1 -d'.' | grep '^[[:digit:]]'`
qdel $list_of_numbers