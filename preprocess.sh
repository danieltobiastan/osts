#!/bin/bash

# Take in the input file, check that the file is valid
#
if [[ -z $1 ]]
then 
	1>&2 echo "Filename is missing, check inputs"
	exit 2

elif [[ ! -f $1 ]] # check if the file exists in the directory given
then
    1>&2 echo "The tsv/csv file is not found, check inputs"
    exit 1

elif [[ $# -ne 1 ]] # check if exactly 1 input given
then
	1>&2 echo "Please only input 1 arguments"
	exit 1

else
	file=$1

	# Preprocess the file, with the relevant columns needed
	relevant=$(awk -F "\t" '{print $1"\t"$2"\t"$3"\t"$4"\t"$5}' $file)
        headers=$(echo "$relevant" | head -n1)
	data=$(echo "$relevant" | tail -n+2)

	# Preprocess to get the month and dates out
	dates=$(echo "$data" | awk -F "\t" '{print $4}')
	# standardise dates from hyphens to slashes, then take only data before the 3rd slash
	datesstd=$(echo "$dates" | sed -e 's.-./.g' -e 's/ //g' -e 's%\([^/]*/[^/]*/[^/]*\).*%\1%g')
	# Extract the months, but first convert all the months to single digit if 1-9:
	month=$(echo "$datesstd" | sed -e 's/^0//g' -e 's%\(^[^/]*\)/.*%\1%g')
	years=$(echo "$datesstd" | sed -e 's%.*/.*/\(.*\)%\1%g' -e 's%\(^[0-9][0-9]$\)%20\1%g')
	echo "$years"
fi
