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
	# For untouched data to combine later
	cov_st_ind=$(awk -F "\t" '{print $1"\t"$2"\t"$3"\t"$4}' $file)
	cov_st_ind_head=$(echo "$cov_st_ind" | head -n1)
	cov_st_ind_data=$(echo "$cov_st_ind" | tail -n+2)

	# Take out relevant data
	date_breach=$(awk -F "\t" '{print $4"\t"$5}' $file)
	data=$(echo "$date_breach" | tail -n+2)

	# Preprocess to get the month and dates out
	dates=$(echo "$data" | awk -F "\t" '{print $1}')
	# standardise dates from hyphens to slashes, then take only data before the 3rd slash
	datesstd=$(echo "$dates" | sed -e 's.-./.g' -e 's/ //g' -e 's%\([^/]*/[^/]*/[^/]*\).*%\1%g')
	# Extract the months, but first convert all the months to single digit if 1-9:
	month=$(echo "$datesstd" | sed -e 's/^0//g' -e 's%\(^[^/]*\)/.*%\1%g')
	# Extract the years, take after last slash, then if 2 digit year, assume '20' in front
	years=$(echo "$datesstd" | sed -e 's%.*/.*/\(.*\)%\1%g' -e 's%\(^[0-9][0-9]$\)%20\1%g')
	
	# Preprocessing the crime type:
	breach=$(echo "$data" | awk -F "\t" '{print $2}')
	# Takes the crime column, matches any first comma or slash and removes all after
	init_breach=$(echo "$breach" | sed -e 's#[,/].*##g')
	
	# Combining the breach, month and year
	breach_mth_yr=$(paste -d'\t' <(echo "$init_breach") <(echo "$month") <(echo "$years"))

	#preparing the full clean file:
	full_headers=$(paste -d'\t' <(echo "$cov_st_ind_head") <(echo "Type_of_Breach") <(echo "Month") <(echo "Year"))
	full_data=$(paste -d'\t' <(echo "$cov_st_ind_data") <(echo "$breach_mth_yr"))

	preprocessed=$(paste -sd'\n' <(echo "$full_headers") <(echo "$full_data"))
	echo "$preprocessed"
fi
